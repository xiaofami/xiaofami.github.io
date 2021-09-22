---
title: R3300-M Android6.0试验
date: 2021-09-18 09:36:04
tags:
- R3300-M
- Android 6.0
---
恩山上看到有人在R3300-L上刷入Android 6.0后，成功将openwrt刷入emmc并启动成功。或许R3300-M也可以？

R3300-M使用meson-gxbb-p201.dtb，搜索外网固件基本上锁定MXQ P201关键词，于是搜到了这个帖子：

[Ugoos Android 6.0.1 port MXQ S905 P201](https://forum.freaktab.com/forum/tv-player-support/amlogic-based-tv-players/s905/others-ac/firmware-roms-tools-bj/789645-ugoos-android-6-0-1-port-mxq-s905-p201)

有网友在MXQ P201上测试，WIFI正常，有线网卡不工作。不过我们现在只关心BootLoader，Amlogic设备的分区表都在BootLoader里，如果这个BootLoader比较新，可以小小期待下从emmc启动。

从上面帖子追踪到原贴，某位俄国人基于UGOS做的改版固件：  https://4pda.to/forum/index.php?showtopic=760441&st=1320

固件下载地址： https://drive.google.com/drive/folders/1ECX6Peu5tELNMbLKo5_dBJN76DlvuX6L

其中：（谷歌渣翻译加猜测，原文俄文看不懂）

1. ugos7 wifi.img ： 只有 WIFI 工作
2. ugos9 wifi s pdu.img ： Wifi 工作和远程控制
3. ugos10 wifi s pdu ckear.img ：Wifi 工作正常，删除了一些 ugos预装应用和启动器（作者说这个最精简，最快）

ugos10应该最适合，如果这个固件内核版本高于3.14，那么从emmc启动openwrt（5.4内核）就很有希望。Manjaro主线内核已经滚到了5.14.2，不抱希望。（如果没记错，恩山Flippy在某帖子中提到5.10内核后Amlogic都无法从emmc启动linux）有空时候测试下。

更新：去Coreelec又看了下关于内核的讨论，GXBB S905只有3.14内核，无缘4.9，所以emmc启动没戏了。
