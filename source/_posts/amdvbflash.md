---
title: 盈通RX480显卡刷BIOS
date: 2024-8-26 09:36:29
tags:
- RX480
index_img: https://tpucdn.com/gpu-specs/images/b/4285-front.jpg
---
2016年9月时从京东买了张盈通RX480游戏显卡，出厂频率1340MHz，在[techpowerup](https://www.techpowerup.com/gpu-specs/yeston-rx-480-gameace-top.b4285)上的代号为 *Yeston RX 480 GAMEACE TOP（RX-480-8G-D5-Game-ACE-TOP）*。当时搭配 **映泰Z170W** 主板和i5-6500用着并不省心，死机是家常便饭。而且这卡的原厂BIOS不支持UEFI，所以主板的**CSM**功能一直开着。8年后的某天，我从某篇帖子中看到电脑死机很可能与显卡有关，加之我对这个显卡不支持UEFI启动一直心存芥蒂，于是打算给它刷BIOS玩一玩。
![RX-480-8G-D5-Game-ACE-TOP](https://tpucdn.com/gpu-specs/images/b/4285-front.jpg "RX-480-8G-D5-Game-ACE-TOP")
# 获取amdvbflash工具
刷BIOS首先得有合适工具，我用的是这个版本： https://github.com/stylesuxx/amdvbflash

这是一个二进制文件，版本4.71，需要在linux x86中以root权限运行，应该是AMD内部流出的：
```bash
~/amdvbflash$ sudo ./amdvbflash -v
[sudo] password for pico:
AMDVBFLASH version 4.71, Copyright (c) 2020 Advanced Micro Devices, Inc.

Format: amdvbflash -v <adapter num> <filename>
```

常用命令如下：

```bash
sudo ./amdvbflash -ai #查看显卡接口信息
sudo ./amdvbflash -s 0 <file> # 备份显卡BIOS到文件。该命令备份了整个存储芯片，没有去除末尾占位的0，所以会比GPU-Z备份的文件大。
sudo ./amdvbflash -f -p 0 <file> # 给接口编号为0的显卡强行刷入指定的BIOS文件
```

[techpowerup论坛](https://www.techpowerup.com/forums/threads/amdvbflash-4-104e-for-64-bit-linux-with-updated-support-for-vbios-flash-on-big-navi2x-gpus.313927/)上有两个版本更新的linux平台**amdvbflash**工具，为 *AMDVBFLASH version 4.104 EXTERNAL, Copyright (c) 2022 Advanced Micro Devices, Inc.* 和 *AMD IFWI Flasher Tool Version 5.0.0.638-External. Copyright© 2020-2023 Advanced Micro Devices, Inc. All rights reserved.* 。经过测试，**amdvbflash4-104E** 不支持 **-f** 选项没法无脑强刷，至于 **amdvbflash5.0.638** 直接不支持 **GCN** 架构显卡，毕竟它太新了。不过 **amdvbflash5.0.638** 可以用来读取分析已有的BIOS文件，无论新旧，这一点很便利。

**amdvbflash**也有Windows版本，但是我在Windows 11平台测试，不是报警无法加载驱动就是在已经赋予管理员权限的情况下还是提示“请以管理员权限执行”，尝试各个版本后均告失败。
# 获取合适的BIOS文件
盈通这个显卡BIOS版本号为**015.050.000.000.000000**，接口如下：
* 1x DVI
* 1x HDMI 2.0b
* 3x DisplayPort 1.4a

经过测试，[GV-RX480G1 GAMING-8GD](https://www.techpowerup.com/gpu-specs/gigabyte-rx-480-g1-gaming-8-gb.b3749)这款技嘉显卡的BIOS能够完美适配，刷好后显卡所有接口都能正常输出，GPU-Z信息也正常（Subvendor显示为Gigabyte，但是Name被识别成了ASUS，小问题~）。techpowerup上的这个BIOS是F4步进，技嘉官网上提供了F8步进下载，但我测试并不如F4稳定：
https://www.gigabyte.cn/Graphics-Card/GV-RX480G1-GAMING-8GD/support#support-dl-bios

![GV-RX480G1 GAMING-8GD](https://tpucdn.com/gpu-specs/images/b/3749-front.jpg "GV-RX480G1 GAMING-8GD")
# 稳定性测试
主板关闭CSM选项，开机画面正常，所有接口正常，电脑睡眠后能够正常唤醒，再没有遇到之前频繁出现的"一睡不醒"问题。唯一的小毛病是显示器开启FREESYNC情况下，DP接口开机一段时间后屏幕颜色会发紫，换个DP接口能好一会儿，但是最终都会变色，刷BIOS之前未遇到过此种现象。关闭显示器FREESYNC后显示立即恢复正常。目前尚不能排除显示器嫌疑，它最近出现了一条黑色横线。。。