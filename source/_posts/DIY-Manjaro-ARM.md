---
title: 自制Manjaro ARM启动TF卡/U盘
date: 2021-10-21 10:29:18
tags:
- Manjaro
- ARM
- aarch64
---
Manjaro ARM官方制作维护了许多开箱即用的镜像，不过同时提供了打包工具，可以用来自行制作镜像包或启动TF卡/U盘。

Manjaro提供了2个工具，manjaro-arm-tools和manjaro-arm-installer。manjaro-arm-tools可生成镜像包，目前仅支持Manjaro。manjaro-arm-installer用于直接制作启动盘，可运行在任意发行版。也可以通过创建loop设备方式，将镜像写入磁盘，方便分发使用。

本例中，在deepin上配置使用manjaro-arm-installer。

# 下载manjaro-arm-installer
`manjaro-arm-installer`就是一个bash脚本，下载地址： https://gitlab.manjaro.org/manjaro-arm/applications/manjaro-arm-installer/-/tags 选择最新的即可。

# 安装依赖
该脚本依赖：
```bash
"git" "parted" "systemd-nspawn" "wget" "dialog" "bsdtar" "openssl" "awk" "btrfs" "mkfs.vfat" "mkfs.btrfs" "cryptsetup"
```

大部分依赖系统已预装，或者直接按包名安装即可，注意在deepin中，`systemd-nspawn`由`systemd-container`提供。

另外`qemu-user-static`也要安装。装好后，进入`/usr/lib/binfmt.d`。这个目录下针对不同架构有许多文件，我们的盒子是aarch64架构，所以将`qemu-aarch64-static.conf`复制一份，改名为`qemu-static.conf`。

# 执行脚本
按提示进行选择机型、版本、设置用户名密码、时区等操作即可。建议全程出国上网，直连下载rootfs很慢（约170.11M）。完成后，对应TF卡/U盘存在fat与ext4两分区，用过Armbian的应该很熟悉下步配置了。