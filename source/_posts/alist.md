---
title: Manjaro ARM安装运行alist并通过webdav挂载到本地目录
date: 2023-03-27 15:42:32
tags:
- alist
- Manjaro ARM
- webdav
- dlna
index_img: /img/alist.jpg
---
最近解决了Manjaro ARM在R3300-M上频繁死机的问题，经查阅系统日志，基本可以推定是8189es内核模块的问题，禁用后再未死机。于是R3300-M又可以拿来跑一些服务了（这个盒子不会用到2030年吧 ... ）
# 安装
alist作为网盘聚合工具相当好用，特别是把别人分享的文件挂载到本地实现资源整合。利用官方脚本安装十分简单：

```bash
curl -fsSL "https://alist.nn.ci/v2.sh" | bash -s install
```

结束后终端界面会输出页面地址、账号信息等内容，浏览器中打开管理页面进行设置即可。
# 使用
使用浏览器即可实现阅读电子书、播放视频等功能。值得一提，alist通过302重定向使客户端获取到文件的真实地址，所以文件传输流量不经过alist服务器。
alist还支持webdav，在PotPlayer、RaiDrive、nplayer、Kodi中可以方便挂载，Windows系统本身也支持通过webdav将网盘挂载成为本地硬盘。不过在Manjaro ARM中，应该如何操作呢？

# Manjaro ARM 挂载webdav
参考[archlinux wiki](https://wiki.archlinux.org/title/Davfs2)，该功能由davfs2软件包提供，位于AUR中。通过yay安装即可，安装选项全为默认：
```bash
yay -S davfs2
```
完成后进行挂载：

```bash
[marly@manjaro alist]$ sudo mount -t davfs http://127.0.0.1:5244/dav /opt/alist/mnt
Please enter the username to authenticate with server
http://127.0.0.1:5244/dav or hit enter for none.
  Username: admin
Please enter the password to authenticate user admin with server
http://127.0.0.1:5244/dav or hit enter for none.
  Password:
```

**/opt/alist/mnt** 目录是我自己建立的，用于本地挂载。命令执行后会提示输入用户名密码，确认后挂载成功。
每次开机手动挂载比较麻烦，可以通过 **Systemd** 自动化。

首先修改 **davfs2** 配置文件添加webdav登录网址、用户名以及密码：
```bash
sudo vim /etc/davfs2/secrets
```

加入 **http://127.0.0.1:5244/dav admin 123456** 一行。登录地址、用户名、密码请自行替换。

下一步来创建Systemd单元文件。参考[How to mount WebDAV share using systemd](https://sleeplessbeastie.eu/2017/09/25/how-to-mount-webdav-share-using-systemd/)一文，创建以下2个unit文件。 **注意，unit文件命名必须遵从挂载目录名称，例如，我想挂载到/opt/alist/mnt目录下，那么两个unit文件命名就必须为opt-alist-mnt.mount和opt-alist-mnt.automount** ，如果不遵从该原则，启动服务时就会提示 **Where= setting doesn't match unit name. Refusing.** 错误。

```bash
# /etc/systemd/system/opt-alist-mnt.mount
[Unit]
Description=Mount alist webdav share
After=network-online.target
Wants=network-online.target

[Mount]
What=http://127.0.0.1:5244/dav/
Where=/opt/alist/mnt
Options=noauto,user,uid=marly,gid=marly
Type=davfs
TimeoutSec=60

[Install]
WantedBy=remote-fs.target
```

```bash
# /etc/systemd/system/opt-alist-mnt.automount
[Unit]
Description=Mount alist webdav share
After=network-online.target
Wants=network-online.target

[Automount]
Where=/opt/alist/mnt
TimeoutIdleSec=300

[Install]
WantedBy=remote-fs.target
```

```bash
sudo systemctl daemon-reload
sudo systemctl enable opt-alist-mnt.mount
sudo systemctl enable opt-alist-mnt.automount
sudo systemctl start opt-alist-mnt.automount
```
至此alist共享就通过webdav挂载到了本地目录，可以正常访问。
# 密码找回
忘记密码是常有的事。进入一键脚本默认安装目录执行命令查看密码：

```bash
cd /opt/alist/
sudo ./alist admin
```

执行后admin的密码就在终端中打印出来啦！
# 与DLNA的结合
```bash
sudo pacman -S minidlna #安装
```
然后参照 [ReadyMedia](https://wiki.archlinux.org/title/ReadyMedia) 对 **/etc/minidlna.conf** 进行修改，按照音乐，视频，图片等分类进行共享。

```bash
media_dir=A,/opt/alist/mnt/alist/xiaoya/音乐
media_dir=PV,/opt/alist/mnt/xiaoya/资料/素材
media_dir=V,/opt/alist/mnt/alist/xiaoya/动漫/姬路白雪
```

最后重启服务即大功告成： `sudo systemctl restart minidlna.service` 。前文已提到，alist的WebDAV策略为302重定向到真实链接，所以理论上播放速度并不受R3300-M的百兆网口限制。但是通过davfs2挂载后重定向能否生效还有待考察，晚些时候拿小米电视播放器试试效果。

# 测试
使用小米电视自带的视频播放器测试，列出目录正常，速度也很快，但是看不到文件。后来检查配置文件，发现提示媒体路径不存在。将

```bash
media_dir=A,/opt/alist/mnt/alist/xiaoya/音乐
media_dir=PV,/opt/alist/mnt/xiaoya/资料/素材
media_dir=V,/opt/alist/mnt/alist/xiaoya/动漫/姬路白雪
```

修改为

```bash
media_dir=/opt/alist/mnt/alist/xiaoya/
```

后重启服务，未再报错，晚些时候再测试一次。另外我发现了一款支持webdav的安卓平台视频播放器  [NOVA: opeN sOurce Video plAyer](https://github.com/nova-video-player/aos-AVP) 。目前作者已在测试版中加入了webdav支持，（[点我进入下载页面](https://github.com/nova-video-player/aos-AVP/releases)） ，正式版估计也快更新了。播放器界面适配了手机、平板和电视，支持音频直通，功能丰富无广告，而且支持中文。手机上测试连接webdav正常，速度也很快，电影刮削效果很满意。可惜动漫刮削效果不理想，希望未来予以改进。