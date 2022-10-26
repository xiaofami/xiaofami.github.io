---
title: Manjaro ARM 22.10 发布
date: 2022-10-26 14:02:34
tags:
- Manjaro
- ARM
---
Manjaro ARM 22.10 发布啦！其亮点之一便是6.0内核的更新。我的R3300-M小红盒已更新。如果需要全新安装，可以下载GENERIC镜像： https://github.com/manjaro-arm/generic-images/releases/download/22.10/Manjaro-ARM-minimal-generic-22.10.img.xz 

对于S905盒子而言，GENERIC镜像缺失了一些必须的启动文件。这些文件我已经打包，需要下载解压缩后放到启动分区：https://tccmu.com/2022/08/04/manjaro2206/bootfiles.tgz

以R3300-M为例，将 **u-boot-s905** 重命名为 **u-boot.ext** ，然后修改 **extlinux.conf** 使用 **meson-gxbb-p201.dtb** 就可以了。镜像中的dtb文件支持allwinner、amlogic、apple、broadcom、nvidia和rockchip，有对应设备的可以自行测试。

简单测试来看，ODROID内核表现稳定（6.0.1-1-MANJARO-ARM-ODROID） ，更新后重启正常。主线内核的那个盒子更新后重启失败，可能电源管理存在一点点问题。