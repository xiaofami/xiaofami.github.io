---
title: GXBB S905从EMMC启动Linux研究
date: 2021-12-08 16:05:17
tags:
- R3300-M
- AARCH64
- Manjaro
---

# 回顾
过去在R3300-M上进行过几次不成功的试验。无论是balbes150的Armbian 20.10还是目前使用的Manjaro Linux ARM，使用所提供的安装脚本均无法启动。最近发现论坛上名为pista一网友遇到类似问题并成功解决，看看我们能不能成功复现。

https://forum.armbian.com/topic/18902-s905-failed-to-boot-from-emmc/
# 设备
Minix Neo U1 ... S905, 2GB RAM / 16GB Flash ，搭配meson-gxbb-vega-s95-meta.dtb运行Armbian_20.10_Arm-64_bullseye_current_5.9.0.img。既然和R3300-M同为GXBB S905，那么如果Minix Neo U1可以从emmc启动linux，R3300-M也没有问题。
# 默认安装脚本从EMMC启动Armbian_20.10遇到的问题
```bash
** No partition table - mmc 2 **
```
与R3300-M当时遇到的问题一致。
# 妥协方案
emmc分区保留前700MB，剩余空间分给ROOTFS，然后利用TF卡启动。在R3300-M上也曾试验成功，但我们的目的是完全脱离TF卡，于是pista开始了深入研究。
# 纯emmc方案
pista成功从EMMC分区启动了Armbian 20.10。关键所在是使用 **mmc read** 而不是 **load/fatload** 来加载 ***kernel**， **ramdisk** ，以及 **dtb** 。检查了Manjaro Linux ARM， **/boot/boot.ini** 内容如下：
```ini
ODROIDN2-UBOOT-CONFIG
#ODROIDC2-UBOOT-CONFIG

if test "${devtype}" = ""; then setenv devtype "mmc"; fi

if fatload ${devtype} ${devnum} 0x1000000 u-boot.ext; then go 0x1000000; fi;
```
看来需要想办法用 **mmc read** 替换 **load/fatload** 。
# 深入研究
## emmc分区理论
首先对emmc分区进行描述，pista的看起来这样：
```bash
blkdevparts=mmcblk1:209715200@1463812096(boot),-@1673528320(root)
```
209715200Byte对应200MByte，1463812096Byte对应1396MByte，1673528320约合1596MByte，并非精确匹配。

查询可知blkdevparts命令用法： https://www.kernel.org/doc/html/latest/block/cmdline-partition.html

通过学习，可知pista的分区描述为boot分区大小200MB（offset为1396MB，即emmc的前1396MB跳过，保留给为Amlogic的老uboot），这样EMMC的前1596MB就分配完毕了，209715200加上1463812096等于1673527296，比1673528320刚好小了1024。至此分区全貌一目了然：

```txt
1 - 1463812096 (前1396MB) 预留
1463812097 - 1673527296 boot分区，大小200MB
1673527297 - 1673528320 预留，大小1MB
1673528321 -           root分区，占据剩余空间
```

pista为了保险起见，在EMMC分区头部保留了足足1396MB大小的空间。我们的R3300-M的EMMC容量总共才3728MB，可以适当减小预留空间，比如700MB。这样root分区大概有2.5GB空间可用，可以装下Manjaro ARM Minimal或者openwrt等无GUI界面的Linux发行版了。
## emmc实际分区操作

pista没有给出具体命令，只是介绍了大概过程：

1. 预留出 **/dev/mmcblk1** 头部1396MB空间；
2. 新建 **/dev/mmcblk1p1** 和 **/dev/mmcblk1p2**两个分区，分别对应boot和root分区。root分区内容直接复制过去即可，重点是boot分区，需要使用dd命令，将 **mainline uboot** 、 **kernel** 、 **ramdisk** 和 **dtb** 写入预定义的区块位置，例如：
```bash
dd if=zImage of=/dev/mmcblk1p2 bs=512 seek=2859008 count=54841'
```
3. 对于Amlogic的uboot，使用 **mmc read** 替代 **fatload** 来加载全部文件，例如： 
```bash
mmc read 0x08080000 0x2BA3FC 0xD639
```
4. 在被链式启动的Mainline uboot中，使用 **booti 0x08080000 0x13000000 0x08008000** 替代 **bootcmd** 来启动系统。
# 重现流程
pista并没有给出可无脑照抄的流程，所以我们试着重现具体过程。
## 建立分区
### 目标
保留EMMC分区前700MB，创建200MB的 **BOOT_MNJRO** 分区，然后剩余空间创建 **ROOT_MNJRO** 分区。分区名称来自在Manjaro ARM Minimal中用 **e2label** 查看的结果。fdisk结果如下：
```bash
Device         Boot  Start       End   Sectors   Size Id Type
/dev/mmcblk0p1       62500    500000    437501 213.6M  c W95 FAT32 (LBA)
/dev/mmcblk0p2      500001 250347519 249847519 119.1G 83 Linux
```
利用 **df -h** 查看，**BOOT_MNJRO** 使用了54MB大小空间，故分配200MB应该够用。（Manjaro ARM分配了214MB）
### 操作
然后就不会了 XD 求指点
