---
title: LCMP搭建WordPress
date: 2021-11-09 11:02:11
tags:
- Manjaro
- arm64
- aarch64
- Caddy
- PHP
- MariaDB
- wordpress
---
# 简介
**LAMP**和**LNMP**许多人不会陌生。L代表Linux，P代表PHP，M以前指代MySQL，如今换成了MariaDB，用法大体相同。至于server本身也有很多选择。Apache和Nginx之外，Caddy现在也很流行，具备反代和自动获取证书等许多使用功能。本文介绍搭建**LCMP**以及安装**WordPress**过程，希望对潜在的读者有所帮助。

# 硬件平台
还是**R3300-M**盒子哈哈，4核2GHz加上1G内存配置足够了，TF卡选择三星128G，IO性能不是瓶颈。
# 网络环境
我有公网IPv6地址，使用**cloudflare**做AAAA记录，本地运行[NewFuture DDNS](https://github.com/NewFuture/DDNS)自动更新IP地址。为了隐藏真实IP + 提供IPv4接入，cloudflare那边请打开Proxy。
# Linux
## 系统
使用**Manjaro ARM 21.10 minimal vim2**镜像。为了关机重启正常请使用vim内核。emmc安卓底包为ATV，可提升CPU频率至2016MHz，约提升19%性能。刷机、换国内软件源、换内核等可参考本人之前的文章。
## 清理无用软件包
```bash
sudo pacman -Rsu ap6398s-firmware kvim1-firmware kvim2-firmware
```
R3300-M不具备相应硬件，故其驱动可以卸载。
## 禁用SWAP
```bash
sudo systemctl stop zswap-arm.service
sudo systemctl disable zswap-arm.service
```
1G内存专门用来搭建环境运行WordPress足够了。Manjaro ARM中SWAP服务由**zswap-arm**这个包提供，如有洁癖也可以直接卸载。
## 安装配置networkmanager
```bash
sudo pacman -S networkmanager
sudo systemctl enable --now NetworkManager
sudo systemctl stop dhcpcd.service
sudo systemctl disable dhcpcd.service
sudo systemctl restart NetworkManager
```
注意一定要禁用掉**dhcpcd**服务，否则**NetworkManager**无法获取到IP地址。

为什么要安装**networkmanager**呢？因为盒子的有线网卡mac地址每次开机都变化，所以DHCP获取到的IP地址也变来变去。我知悉的唯一有效解决办法是使用**nmtui**提供的mac-address-clone功能固定mac地址，而**nmtui**由**networkmanager**提供。

# mariadb
## 安装
```bash
sudo pacman -S mariadb
sudo mariadb-install-db --user=mysql --basedir=/usr --datadir=/var/lib/mysql
sudo systemctl enable --now mysql.service
```
然后执行设置密码等步骤。网上的许多教程在执行这一步前没有打开**mysql.service**，所以此步骤会失败。
```bash
sudo mysql_secure_installation
```
至此mariadb安装完成，稍后将进行新建数据库、新建用户操作。
## 配置
首先登录到数据库：
```bash
mysql -u root -p
```
然后新建一个名为**wordpress**的数据库，字符集为**utf8mb4**；新建一个名为**wp**的用户，密码为"password"（你需要自行替换密码），赋予这个用户全部权限：
```sql
CREATE DATABASE wordpress DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
GRANT ALL ON wordpress.* TO 'wp'@'localhost' IDENTIFIED BY 'password';
FLUSH PRIVILEGES;
EXIT;
```
至此数据库配置完成。
# PHP
## 安装
```bash
sudo pacman -S php php-fpm php-gd
sudo systemctl enable --now php-fpm
```
## 配置
编辑*/etc/php/php.ini*，启用以下扩展（删掉行首的注释即可）：
```ini
extension=bz2
extension=curl
extension=gd
extension=mysqli
extension=pdo_mysql
extension=zip
```
为了方便使用，对部分参数进行修改：
```ini
memory_limit=256M
post_max_size=100M
upload_max_file_size=100M
```

编辑*/etc/php/php-fpm.d/www.conf*文件，使其以caddy身份运行：
```conf
user = http
group = http
```
修改为
```conf
user = caddy
group = caddy
```
如果不改成caddy，过一会儿试图安装WordPress时caddy会报502错误。
## 重新加载
```bash
sudo systemctl restart php-fpm
```
# WordPress
## 下载
将WordPress下载到当前用户家目录：
```bash
cd ~/
curl -O https://wordpress.org/latest.tar.gz
```
移动到**/srv/http**目录下并解压缩：
```bash
sudo mv ~/latest.tar.gz /srv/http
cd /srv/http
sudo tar -zxvf latest.tar.gz
```
然后在**/srv/http**会出现**wordpress**文件夹。

早年用过**centos**等Linux发行版的人可能对**/srv/http**不是很熟悉，在Manjaro（或者称其为Archlinux更贴切）中网站目录一般放在这里。当然放在那里都行，只要在Caddy配置文件中定义明白即可，放在这里只是遵循了Archlinux关于文件目录的设计理念。

完成后，开始调配Caddy。
# Caddy
## 安装
```bash
sudo pacman -S caddy
```
## 配置
```conf
domain.com {
    # 指向wordpress位置
    root * /srv/http/wordpress
    encode zstd gzip
    file_server

    @cache {
        not header_regexp Cookie "comment_author|wordpress_[a-f0-9]+|wp-postpass|wordpress_logged_in"
        not path_regexp "(/wp-admin/|/xmlrpc.php|/wp-(app|cron|login|register|mail).php|wp-.*.php|/feed/|index.php|wp-comments-popup.php|wp-links-opml.php|wp-locations.php|sitemap(index)?.xml|[a-z0-9-]+-sitemap([0-9]+)?.xml)"
        not method POST
        not expression {query} != ''
    }

    route @cache {
        try_files /wp-content/cache/cache-enabler/{host}{uri}/https-index.html /wp-content/cache/cache-enabler/{host}{uri}/index.html {path} {path}/index.php?{query}
    }
       
    # Change the path here according to your server
    php_fastcgi unix//run/php-fpm/php-fpm.sock
}
```
这个配置是从[Example: configure WordPress with a static cache](https://caddy.community/t/example-configure-wordpress-with-a-static-cache/8215)略微修改来的，你如果同样使用Manjaro ARM，那么只需要用自己的域名替换就行了。

在**/etc/caddy**目录中，将默认的`Caddyfile`复制一份并改名为`Caddyfile.ori`，然后清空`Caddyfile`，把自己的配置粘贴进去保存即可。
## 修改wp-content权限
```bash
sudo chown -R caddy:caddy /srv/http/wordpress/wp-content/
```
这步的操作目的是将**wp-content**目录用户和组修改为caddy。刚才解压后得到的wordpress目录中，所有文件用户和组均为**nobody**，权限大部分为644，故caddy只有可读权限，无法写入，在后续安装使用（比如安装插件）中会产生许多麻烦。网上流传的所谓`sudo chmod -R 755`甚至`sudo chmod -R 777`方法不要用，因其对linux权限系统的破坏是不可逆的。用户与组至少随时可以改回来。严格来说**wp-content**用户与组修改为**caddy**也不安全，不过在只运行一个网站的情况下，安全性应该还行？
## 启动
```bash
sudo systemctl enable --now caddy
sudo systemctl restart caddy
```
不出意外，此时访问自己的域名会看到wordpress初始化向导。
# 参考
排名不分前后：

1. [Example: configure WordPress with a static cache](https://caddy.community/t/example-configure-wordpress-with-a-static-cache/8215)
2. [在 Arch Linux 中安装 WordPress](https://rocka.me/article/wordpress-on-archlinux)
3. [PicUploader使用系列（一）——在Archlinux上使用Caddy部署PicUploader](https://blog.zhullyb.top/2021/10/21/picuploader-on-archlinux-with-caddy/)
4. [在 ArchLinux 下利用Caddy PHP-FPM MariaDB 迅速搭建 WordPress 博客](https://m0nkey.cn/2020/02/use-caddy-php-fpm-mariadb-to-quickly-build-a-wordpress-blog-under-archlinux/)
5. [NewFuture DDNS](https://github.com/NewFuture/DDNS)
6. [Can't change language (only "English (United States)")](https://wordpress.stackexchange.com/questions/217880/cant-change-language-only-english-united-states/274639)
