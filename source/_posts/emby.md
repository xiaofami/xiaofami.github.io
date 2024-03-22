---
title: emby部署ssl证书
date: 2024-03-22 15:02:46
tags:
- synology
- emby
- let's encrypt
index_img: /img/emby.png
---
# 序
2022年双十一时候购买了绿联DX4600，打算替换掉运行接近十年的 HP ProLiant MicroServer Gen8 。但是绿联这个openwrt用起来真是一言难尽，体验远不及刷了黑裙的HP ProLiant MicroServer Gen8。本次emby配置在Gen8上进行。
# 申请证书
假设你有一个名为 **domain.com** 的顶级域名，并使用cloudflare解析。现在打算申请 **nas.domain.com** 的证书给群晖使用，那么可以这样操作：

```bash
acme.sh --issue -d nas.domain.com --dns  --yes-I-know-dns-manual-mode-enough-go-ahead-please
acme.sh --renew -d nas.domain.com --yes-I-know-dns-manual-mode-enough-go-ahead-please
```
**acme.sh**请提前安装。证书签发过程中会提示创建一个TXT记录用于验证域名归属，按提示操作即可。结束后，得到的证书文件保存在 `~/.acme.sh/nas.domain.com_ecc` 目录：
```bash
[marly@manjaro ~]$ ls -l ~/.acme.sh/nas.domain.com_ecc
total 40
drwxr-xr-x 2 marly marly 4096 Mar 21 15:59 backup
-rw-r--r-- 1 marly marly 2668 Mar 21 16:08 ca.cer
-rw-r--r-- 1 marly marly 4112 Mar 21 16:08 fullchain.cer
-rw-r--r-- 1 marly marly 1444 Mar 21 16:08 nas.domain.com.cer
-rw-r--r-- 1 marly marly  687 Mar 21 16:08 nas.domain.com.conf
-rw-r--r-- 1 marly marly  465 Mar 21 16:07 nas.domain.com.csr
-rw-r--r-- 1 marly marly  186 Mar 21 16:07 nas.domain.com.csr.conf
-rw------- 1 marly marly  227 Mar 21 16:06 nas.domain.com.key
```

群晖实现https登录需要导入这三个文件：

    nas.domain.com.key ，对应私钥，第一行；
    nas.domain.com.cer ，对应证书，第二行；
    ca.cer ， 对应中间证书，第三行。

此三者缺一不可。之前我只导入了前两项，结果VLC播放视频总是提示证书错误。后来导入 **ca.cer** 解决了问题。
# 为emby生成证书
emby默认用http协议通过8096端口访问，而且无法直接利用群晖系统中已经配置好的证书，需要生成pfx格式证书并在管理页面导入：
```bash
$ cd ~/.acme.sh/nas.domain.com_ecc
$ openssl pkcs12 -export -out nas.domain.com.pfx -inkey nas.domain.com.key -in nas.domain.com.cer #证书密码可自行设置或不填，如果设置密码，emby中也要对应填写
```

如此导入后重启emby套件，即可实现通过8920端口以https协议访问emby。