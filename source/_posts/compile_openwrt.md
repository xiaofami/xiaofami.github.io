---
title: Manjaro中搭建openwrt编译环境
date: 2022-07-04 13:59:47
tags:
- openwrt
- Manjaro
---
原本用于编译openwrt的Deepin在一次升级中挂掉了，于是尝试在Manjaro下编译。


```bash
sudo pacman -S base-devel asciidoc binutils bzip2 gawk gettext git ncurses zlib patch unzip lib32-glibc subversion flex gcc-multilib p7zip msmtp lib32-openssl texinfo xmlto qemu upx libelf autoconf automake libtool gettext
```
比ubuntu下的依赖项少了一些，不过用默认配置跑了一遍正常生成镜像。