---
title: Cloudflare Tunnel 探索
date: 2021-10-29 15:12:56
tags:
- Manjaro
- ARM
- aarch64
- Cloudflare
---
# 运行环境
某S905机顶盒 + TF卡 + Manjaro ARM 21.10

# 示例说明
假设我们有一个`marly.com`的域名，且已经使用`cloudflare`进行解析。在家里的电视盒子上运行了一个http服务:`http://localhost:3000`，登录linux系统的用户为marly，我们想在外网通过`https://world.marly.com`访问这个服务，还要有正规证书。通过`Cloudflare Tunnel`可以方便实现。

如果有公网IP，上通过端口转发 + 调用API自动更新A记录 + `Let's Encrypt`也可以实现。

1. 端口转发。本地路由器配置。
2. 调用API自动更新A记录。GitHub上找到一个看起来不错的项目：[NewFuture DDNS](https://github.com/NewFuture/DDNS)。支持DNSPOD，阿里 DNS，DNS.COM，DNSPOD 国际版，CloudFlare，HE.net(不支持自动创建记录)，华为云。
3. 签发`Let's Encrypt`证书 + 续期。使用[ACME](https://github.com/acmesh-official/acme.sh)即可。

此外还发现[ehang-io/nps](https://github.com/ehang-io/nps)，不过没完整折腾过。
# 安装cloudflared
可以直接下载官方预编译的二进制执行文件或者安装包，地址 https://github.com/cloudflare/cloudflared/releases/ ，或者使用`yay`根据当前最新源码编译安装：

```bash
$ yay -s 
```
如果半天没进度，请检查网络状况。

使用yay安装的cloudflared包含三部分：

> /usr/bin/cloudflared /etc/cloudflared /usr/share/man/man1/cloudflared.1.gz

日志文件为`/var/log/cloudflared.log`，默认文件权限640。cloudflared以普通用户权限运行所以没法读写这个日志文件，可以手动把它改成666：
```bash
$ sudo chmod 666 /var/log/cloudflared.log
```
# 登录授权
```bash
$ cloudflared tunnel login
```
复制终端上的网址，在浏览器中打开，选择`marly.com`。认证完成后，cloudflared会生成`~/.cloudflared/cert.pem`。
# tunnel创建
```bash
$ cloudflared tunnel create hello
```
上述命令产生如下后果：

* 根据提供的name，cloudflared会生成一个UUID，与name唯一对应；
* 在`~/.cloudflared/`中，cloudflared会生成<UUID>.json文件；

最后使用`$ cloudflared tunnel list`查看tunnel是否创建成功。

# DNS记录生成
## 连接到应用
```bash
$ cloudflared tunnel route dns hello world.marly.com
```
此步骤在cloudflare后台创建了`world.marly.com`的CNAME。
## 连接到网络
```bash
$ cloudflared tunnel route ip add <IP/CIDR> <UUID or NAME>
```
可以使用
```bash
$ cloudflared tunnel route ip show
```
查看是否路由成功。
# 配置文件创建
`cloudflared`的配置文件为`config.yml`，遵循Linux传统，全局文件路径`/etc/cloudflared/config.yml`，用户文件路径`~/.cloudflared/config.yml`。

全局文件默认内容：
```yaml
---
logfile: /var/log/cloudflared.log
proxy-dns: true
proxy-dns-address: 127.0.0.1
proxy-dns-port: 5300
proxy-dns-upstream:
        - https://1.1.1.1/dns-query
        - https://1.0.0.1/dns-query
```

在`~/.cloudflared/`中，创建`config.yml`文件：

## 连接到应用
> url: http://localhost:8000
tunnel: <Tunnel-UUID>
credentials-file: /root/.cloudflared/<Tunnel-UUID>.json

根据自身情况修改，比如应用端口，UUID，以及credentials-file位置。
## 连接到网络
tunnel: <Tunnel-UUID>
credentials-file: /root/.cloudflared/<Tunnel-UUID>.json

# tunnel运行
```bash
$ cloudflared tunnel run <UUID or NAME>
```
如果存在多个配置文件（比如同时运行了多条tunnel），建议通过`--config`指定路径：
```bash
$ cloudflared tunnel --config path/config.yaml run
```
最好使用绝对路径。
# 检查tunnel状况
## 列出所有
```bash
$ cloudflared tunnel list
```
## 检查单个
```bash
$ cloudflared tunnel info <UUID or NAME>
```
# 运行
## 调试
```bash
cloudflared tunnel run --url http://localhost:3000 hello
```
## 作为服务运行
首先准备好config.yml文件：
```yaml
tunnel: hello
credentials-file: /home/marly/.cloudflared/fe63bc80-7123-65a4-e516-e125b06f0a12.json

ingress:
  - hostname: world.marly.com
    service: http://localhost:3000
  - service: http_status:404
```

然后将该文件移动到`/etc/cloudflare`目录下，原有的文件提前改名或删除。

安装服务：`sudo cloudflared service install` 。cloudflare文档说明此步骤会自动将`~/.cloudflared/config.yml`复制到`/etc/cloudflared`中，但实际测试找不到配置文件，故手动复制。

启动服务：
```bash
sudo systemctl enable cloudflared
sudo systemctl start cloudflared
```
