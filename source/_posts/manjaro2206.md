---
title: R3300-M运行Manjaro ARM Vim2 22.06
date: 2022-08-04 8:45:48
tags:
- Manjaro
- arm64
- aarch64
---
Manjaro ARM 22.06已经发布一段时间，刚好我们需要重新刷系统，镜像还是选用Vim2： https://github.com/manjaro-arm/vim2-images/releases
在最近的几个版本中，系统的启动方式经历了几次变化。在Vim2 22.06镜像中，boot分区只包含下述文件/目录：
```bash
$ ls -l /boot
drwxr-xr-x 8 root root     8192 Aug  3 22:49 dtbs
drwxr-xr-x 2 root root     8192 Jun  4 05:03 extlinux
-rw-r--r-- 1 root root 24730112 Jul 12 23:44 Image
-rw-r--r-- 1 root root  8382621 Aug  3 22:50 initramfs-linux.img
-rw-r--r-- 1 root root  1363968 Feb 12 00:11 u-boot.bin
```
需要稍加变动以支持R3300-M启动：
```bash
-rw-r--r-- 1 root root      713 Jul 28 15:17 aml_autoscript
-rw-r--r-- 1 root root      463 Jul 28 15:17 aml_autoscript.zip
drwxr-xr-x 8 root root     8192 Aug  3 22:49 dtbs
drwxr-xr-x 2 root root     8192 Jun  4 05:03 extlinux
-rw-r--r-- 1 root root 24730112 Jul 12 23:44 Image
-rw-r--r-- 1 root root  8382621 Aug  3 22:50 initramfs-linux.img
-rw-r--r-- 1 root root      537 Aug  4 06:34 s905_autoscript
-rw-r--r-- 1 root root  1363968 Feb 12 00:11 u-boot.bin
-rw-r--r-- 1 root root   609247 Aug  4 06:30 u-boot.ext
```
注意补充的几个文件，u-boot.bin可以删掉。这几个文件我已经打包好： [bootfiles.tgz](/manjaro2206/bootfiles.tgz)，注意你需要选择合适的u-boot文件，然后重命名为u-boot.ext。

Manjaro ARM Mininal 22.06非常简洁，总共占用空间1.5GB，提供了206个软件包：
```bash
$ df -h
Filesystem      Size  Used Avail Use% Mounted on
dev             331M     0  331M   0% /dev
run             465M  7.5M  457M   2% /run
/dev/mmcblk0p2  115G  1.4G  109G   2% /
tmpfs           465M     0  465M   0% /dev/shm
tmpfs           465M     0  465M   0% /tmp
/dev/mmcblk0p1  458M   45M  413M  10% /boot
tmpfs            93M     0   93M   0% /run/user/1000

$ pacman -Q | wc
206     412    3746
```
软件包还可以继续精简，比如 **ap6398s-firmware** 显然可以删掉因为R3300-M使用的是RTL8189ETV。另外经过测试，主线内核在22.06中支持良好，关机重启都正常，没必要使用odroid内核了。不过Vim2镜像自带的 **linux-khadas** 内核简单使用也没发现问题，根据个人喜好选用吧。
另外之前将Manjaro ARM安装到emmc分区的试验没有成功：
```bash
U-Boot 2015.01-gf813653 (Oct 30 2015 - 09:47:48)

DRAM:  1 GiB
Relocation Offset is: 36ed6000
register usb cfg[0][1] = 0000000037f62b98
register usb cfg[0][2] = 0000000037f62bb8
register usb cfg[2][0] = 0000000037f62bd8
vpu detect type: 5
vpu clk_level = 7
set vpu clk: 666667000Hz, readback: 666660000Hz(0x300)
boot_device_flag : 1
Nand PHY Ver:1.01.001.0006 (c) 2013 Amlogic Inc.
init bus_cycle=6, bus_timing=8, system=5.0ns
reset failed
get_chip_type and ret:fffffffe
get_chip_type and ret:fffffffe
chip detect failed and ret:fffffffe
nandphy_init failed and ret=0xfffffff1
MMC:   aml_priv->desc_buf = 0x0000000033ec6770
aml_priv->desc_buf = 0x0000000033ec8900
SDIO Port B: 0, SDIO Port C: 1
[mmc_init] mmc init success
mmc read lba=0x14000, blocks=0x400
start dts,buffer=0000000033ecad70,dt_addr=0000000033ecad70
parts: 11
00:      logo   0000000002000000 1
01:  recovery   0000000002000000 1
02:       rsv   0000000000800000 1
03:       tee   0000000000800000 1
04:     crypt   0000000002000000 1
05:      misc   0000000002000000 1
06: instaboot   0000000020000000 1
07:      boot   0000000002000000 1
08:    system   0000000050000000 1
09:     cache   0000000020000000 2
10:      data   ffffffffffffffff 4
get_dtb_struct: Get emmc dtb OK!
[mmc_get_partition_table] skip cache partition.
Partition table get from SPL is :
        name                        offset              size              flag
===================================================================================
   0: bootloader                         0            400000                  0
   1: reserved                     2400000           4000000                  0
   2: cache                        6c00000          20000000                  2
   3: env                         27400000            800000                  0
   4: logo                        28400000           2000000                  1
   5: recovery                    2ac00000           2000000                  1
   6: rsv                         2d400000            800000                  1
   7: tee                         2e400000            800000                  1
   8: crypt                       2f400000           2000000                  1
   9: misc                        31c00000           2000000                  1
  10: instaboot                   34400000          20000000                  1
  11: boot                        54c00000           2000000                  1
  12: system                      57400000          50000000                  1
  13: data                        a7c00000          41400000                  4
mmc read lba=0x12000, blocks=0x1
mmc read lba=0x12001, blocks=0x1
mmc_read_partition_tbl: mmc read partition OK!
eMMC/TSD partition table have been checked OK!
mmc env offset: 0x27400000
In:    serial
Out:   serial
Err:   serial
[store]To run cmd[emmc dtb_read 0x1000000 0x40000]
read emmc dtb
Net:   Meson_Ethernet
wipe_data=successful
wipe_cache=successful
upgrade_step=2
reboot_mode=normal
hpd_state=0
[CANVAS]addr=0x3f800000 width=3840, height=2160

Not find '576cvbs' mapped VIC
Err imgread(L315):Logo header err.
There is no valid bmp file at the given address
amlkey_init() enter!
[EFUSE_MSG]keynum is 4
[KM]Error:f[key_manage_query_size]L504:key[usid] not programed yet
[KM]Error:f[key_manage_query_size]L504:key[deviceid] not programed yet
gpio: pin GPIOAO_3 (gpio 122) value is 1
Hit any key to stop autoboot:  0
ret = 1 .(Re)start USB...
USB0:   dwc_usb driver version: 2.94 6-June-2012
USB (0) peri reg base: c0000000
USB (0) use clock source: XTAL input, div: 1
USB (0) base addr: 0xc9000000
Force id mode: Host
dwc_otg: No USB device found !
lowlevel init failed
USB1:   dwc_usb driver version: 2.94 6-June-2012
USB (1) peri reg base: c0000020
USB (1) use clock source: XTAL input, div: 1
USB (1) base addr: 0xc9100000
Force id mode: Host
dwc_otg: No USB device found !
lowlevel init failed
USB error: all controllers failed lowlevel init
** Bad device usb 0 **
** Bad device usb 1 **
** Bad device usb 2 **
** Bad device usb 3 **
[mmc_init] mmc init success
switch to partitions #0, OK
mmc1(part 0) is current device

MMC read: dev # 1, block # 8192, count 3 ... 3 blocks read: OK
## Executing script at 01020000
########## cmd=    echo "Select EMMC"
    mmc dev 1
    sleep 3
    echo "Set env variables"
    setenv dtb_addr 0x1000000
    setenv dtb_sector 0x2003
    setenv dtb_block_cnt 0x47
    setenv env_addr 0x1040000
    setenv env_sector 0x204a
    setenv env_block_cnt 0x1
    setenv env_size 329
    setenv kernel_addr 0x11000000
    setenv kernel_sector 0x204b
    setenv kernel_block_cnt 0xbcae
    setenv initrd_addr 0x13000000
    setenv initrd_sector 0x32000
    setenv initrd_block_cnt 0x3fe7
    setenv boot_start booti ${kernel_addr} ${initrd_addr} ${dtb_addr}
    setenv addmac 'if printenv mac; then setenv bootargs ${bootargs} mac=${mac}; elif printenv eth_mac; then setenv bootargs ${bootargs} mac=${eth_mac}; elif printenv ethaddr; then setenv bootargs ${bootargs} mac=${ethaddr}; fi'

    echo "Read mmc partitions"
    echo "Read /boot/uEnv_emmc.txt from EMMC"
    if mmc read ${env_addr} ${env_sector} ${env_block_cnt}; then env import -t ${env_addr} ${env_size};setenv bootargs ${APPEND};printenv bootargs;echo "Read zImage from EMMC";if mmc read ${kernel_addr} ${kernel_sector} ${kernel_block_cnt}; then echo "Read uInitrd from EMMC";if mmc read ${initrd_addr} ${initrd_sector} ${initrd_block_cnt}; then echo "Read FDT from EMMC";if mmc read ${dtb_addr} ${dtb_sector} ${dtb_block_cnt}; then run addmac;echo "Start booting system...";run boot_start;fi;fi;fi;fi

Select EMMC
[mmc_init] mmc init success
switch to partitions #0, OK
mmc1(part 0) is current device
Set env variables
Read mmc partitions
Read /boot/uEnv_emmc.txt from EMMC

MMC read: dev # 1, block # 8266, count 1 ... 1 blocks read: OK
bootargs=root=/dev/mmcblk1p1 rootflags=data=writeback rw console=ttyAML0,115200n8 console=tty0 no_console_suspend consoleblank=0 fsck.fix=yes fsck.repair=yes net.ifnames=0 quiet splash plymouth.ignore-serial-consoles blkdevparts=mmcblk1:-@116M(rootfs)
Read zImage from EMMC

MMC read: dev # 1, block # 8267, count 48302 ... 48302 blocks read: OK
Read uInitrd from EMMC

MMC read: dev # 1, block # 204800, count 16359 ... 16359 blocks read: OK
Read FDT from EMMC

MMC read: dev # 1, block # 8195, count 71 ... 71 blocks read: OK
mac=76:f1:6c:90:00:03
Start booting system...
"Synchronous Abort" handler, esr 0x96000010
ELR:     37ee00cc
LR:      37ee00c0
x0 : 0000000037f73a00 x1 : 0000000000000000
x2 : 0000000001830000 x3 : 0000000001830000
x4 : 0000000000000086 x5 : 0000000011000000
x6 : 0000000037f455c0 x7 : 0000000000000044
x8 : 0000000000000001 x9 : 0000000000000002
x10: 8c400409c940146c x11: a850c8189a6e9ad0
x12: 0000000000000000 x13: 0000000000000000
x14: 0000000000000000 x15: 0000000037ed70d0
x16: 0000000037ed72b4 x17: 0000000000000000
x18: 0000000033ec5e28 x19: 0000000037f738c0
x20: 0000000000000003 x21: 0000000033ed1068
x22: 0000000037f73000 x23: 0000000037f738c0
x24: 0000000000000000 x25: 0000000033ed1060
x26: 0000000037f685e0 x27: 0000000033ed1090
x28: 0000000000000000 x29: 0000000033ec4ca0

Resetting CPU ...
```
虽说没成功，但是从UART输出来看已经很接近，而且盒子也没变砖，还是可以从TF卡启动，感兴趣的可以继续研究，我不缺TF卡就不折腾了。
