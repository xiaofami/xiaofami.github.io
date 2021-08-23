---
title: Manjaro ARM镜像制作
date: 2021-08-23 16:03:53
tags:
- Manjaro
- ARM
---
本文主要参考自[[Wiki] How to contribute to Manjaro ARM](https://forum.manjaro.org/t/wiki-how-to-contribute-to-manjaro-arm/35461)

# 编译平台
运行Manjaro的x86_64或aarch64设备，需要安装Manjaro-arm-tools。鉴于R3300-M已经运行了Manjaro ARM 21.08，所以以下用盒子制作盒子镜像。
``` bash
sudo pacman -S manjaro-arm-tools
```
# 获取配置文件
``` bash
sudo getarmprofiles -f
```
# 修改配置文件
manjaro-arm-tool会从服务器下载现成的rootfs压缩包（大概160MB），然后以此为基础根据配置文件进行额外的包安装及配置，最终生成压缩镜像。笔者以vim2为模板进行修改：

1. 进入配置文件目录：`/usr/share/manjaro-arm-tools/profiles/arm-profiles/devices`

2. 复制vim2配置文件：`cp vim2 vim2m`

3. 修改vim2m：

``` bash
## Maintained by Spikerguy ##

# Kernel and bootloader stuff
linux-aml
boot-vim2
plymouth
plymouth-theme-manjaro

# Video driver

# Other device specific packages
crda
btrfs-progs
#bluetooth-vim3
#khadas-utils
fbset
#kvim1-firmware
#kvim2-firmware
#ap6398s-firmware
vim2-post-install
```
最主要的修改是把内核从linux换成了linux-aml，之前实测过5.13版本主线内核无法启动R3300-M，linux-aml正常。其他几个固件估计R3300-M也用不上，故注释掉。

4. 生成镜像

``` bash
sudo buildarmimg -d vim2m -e minimal -v 21.08 -n
```
基本参数解释：
``` bash
Usage: buildarmimg [options]
    -d <device>        Device the image is for. [Default = rpi4. Options = oc2, on2, on2-plus, pbpro, pine64, pine64-lts, pinebook, pinephone, pinetab, rock64, rockpi4, rockpro64, rpi3, rpi4, vim1, vim2, vim3]
    -e <edition>       Edition of the image. [Default = minimal. Options = cubocore, gnome, i3, kde-plasma, lxqt, mate, minimal, plasma-mobile, server, wayfire, xfce]
    -v <version>       Define the version the resulting image should be named. [Default is current YY.MM]
    -i <package>       Install local package into image rootfs.
    -b <branch>        Set the branch used in the image. [Default = stable. Options = stable, testing or unstable]
    -n                 Force download of new rootfs.
    -x                 Don't compress the image.
    -h                 This help
```
本例用刚才制作的vim2m配置文件生成了minimal镜像。

生成镜像不会耗时很多，因为涉及的主要是打包和镜像构建，不需要从源码开始编译。我这里测试是16.58分钟，建议优化网络否则下载**Manjaro-ARM-aarch64-latest.tar.gz**(约160M)这一步会耗时很久。

5. 复制镜像到电脑

进入镜像目录：`cd /var/cache/manjaro-arm-tools/img`

复制镜像到本地家目录：`scp Manjaro-ARM-minimal-vim2m-2108img.xz tccmu@192.168.1.221:/home/tccmu`

tccmu是电脑上当前用户名，替换成自己的即可。192.168.1.221是自己电脑的IP（不是盒子），同样要替换。

6. 写入镜像到TF卡：
``` bash
xz -dc Manjaro-ARM-minimal-vim2m-2108.img.xz | dd of=/dev/sdX bs=1M status=progress conv=fsync
```
写入设备名自己替换。

之后的配置没有任何难度了，修改**extlinux.conf**使用合适dtb,修改u-boot-s905为u-boot.ext就完事大吉。

# 备注
目前镜像已生成完毕，但未经实机测试。
