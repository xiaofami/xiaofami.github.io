---
title: Manjaro ARM重新配置内核并打包
date: 2022-07-22 09:46:47
tags:
- Manjaro
- ARM
---
linux-odroid内核没有预编译AX25模块，无法正常使用 **kissattach** 。主线内核预编译了这些模块，可惜与我的电视盒子兼容性不佳，无法正常重启，对于远程使用而言无法接受。于是只好自己编译内核了。

# 获取内核软件包并修改配置文件
```bash
git clone https://gitlab.manjaro.org/manjaro-arm/packages/core/linux-odroid.git
cd linux-odroid
vim config # 修改 # CONFIG_AX25 is not set
```
以下配置供参考：
```conf
1732 CONFIG_HAMRADIO=y
1733 
1734 #
1735 # Packet Radio protocols
1736 #
1737 CONFIG_AX25=m
1738 CONFIG_AX25_DAMA_SLAVE=y
1739 CONFIG_NETROM=m
1740 CONFIG_ROSE=m
1741 
1742 #
1743 # AX.25 network device drivers
1744 #
1745 CONFIG_MKISS=m
1746 CONFIG_6PACK=m
1747 CONFIG_BPQETHER=m
1748 CONFIG_BAYCOM_SER_FDX=m
1749 CONFIG_BAYCOM_SER_HDX=m
1750 CONFIG_YAM=m
1751 # end of AX.25 network device drivers
```
# 开始打包
```bash
makepkg --skipchecksums # 刚才修改了config文件所以无法通过校验，索性就不校验了
==> Making package: linux-odroid 5.18.12-1 (Fri 22 Jul 2022 10:10:46 AM CST)
==> Checking runtime dependencies...
==> Checking buildtime dependencies...
==> Retrieving sources...
  -> Found 65a1da3b24ddcf7e4ddc52357d6f22d62ba441ad.tar.gz
  -> Found 0065-add-ugoos-device.patch
  -> Found config
  -> Found linux.preset
  -> Found 60-linux.hook
  -> Found 90-linux.hook
==> WARNING: Skipping verification of source file checksums.
==> Extracting sources...
  -> Extracting 65a1da3b24ddcf7e4ddc52357d6f22d62ba441ad.tar.gz with bsdtar
# 以下省略
```
# 2000 YEARS LATER
若干小时后编译还没有完成的迹象，还是找开发者吧 😂 已经私信了linux-odroid管理员，如果一切顺利linux-odroid 5.18.12即可支持AX25。

# 再更新
发现编译已完成，R3300-M四核马力全开足足跑了5个小时。编译完成前的输出如下：

```bash
==> Tidying install...
  -> Removing libtool files...
  -> Purging unwanted files...
  -> Removing static library files...
  -> Compressing man and info pages...
==> Checking for packaging issues...
==> Creating package "linux-odroid"...
  -> Generating .PKGINFO file...
  -> Generating .BUILDINFO file...
  -> Adding install file...
  -> Generating .MTREE file...
  -> Compressing package...
==> Starting package_linux-odroid-headers()...
Removing scripts/dtc/include-prefixes/openrisc
Removing scripts/dtc/include-prefixes/nios2
Removing scripts/dtc/include-prefixes/mips
Removing scripts/dtc/include-prefixes/arm64
Removing scripts/dtc/include-prefixes/microblaze
Removing scripts/dtc/include-prefixes/arm
Removing scripts/dtc/include-prefixes/arc
Removing scripts/dtc/include-prefixes/h8300
Removing scripts/dtc/include-prefixes/powerpc
Removing scripts/dtc/include-prefixes/sh
Removing scripts/dtc/include-prefixes/xtensa
==> Tidying install...
  -> Removing libtool files...
  -> Purging unwanted files...
  -> Removing static library files...
  -> Compressing man and info pages...
==> Checking for packaging issues...
==> Creating package "linux-odroid-headers"...
  -> Generating .PKGINFO file...
  -> Generating .BUILDINFO file...
  -> Generating .MTREE file...
  -> Compressing package...
==> Leaving fakeroot environment.
==> Finished making: linux-odroid 5.18.12-1 (Fri 22 Jul 2022 02:14:03 PM CST)
```

```bash
marly@manjaro-minimal  /linux-odroid   master   ls
Permissions Size User  Group Date Modified Name
drwxr-xr-x     - marly marly 21 Jul 20:42   .git
.rw-r--r--   241 marly marly 21 Jul 20:42   .gitlab-ci.yml
.rw-r--r--  4.3k marly marly 22 Jul 10:04   0065-add-ugoos-device.patch
.rw-r--r--   282 marly marly 21 Jul 20:42   60-linux.hook
.rw-r--r--  207M marly marly 22 Jul 10:04   65a1da3b24ddcf7e4ddc52357d6f22d62ba441ad.tar.gz
.rw-r--r--   229 marly marly 21 Jul 20:42   90-linux.hook
.rwxr-xr-x  228k marly marly 22 Jul  9:58   config
.rw-r--r--   68M marly marly 22 Jul 14:12   linux-odroid-5.18.12-1-aarch64.pkg.tar.zst
.rw-r--r--   12M marly marly 22 Jul 14:14   linux-odroid-headers-5.18.12-1-aarch64.pkg.tar.zst
.rw-r--r--   239 marly marly 21 Jul 20:42   linux-odroid.install
.rw-r--r--   234 marly marly 21 Jul 20:42   linux.preset
drwxr-xr-x     - marly marly 22 Jul 14:12   pkg
.rwxr-xr-x  7.0k marly marly 21 Jul 20:42   PKGBUILD
.rw-r--r--  2.1k marly marly 21 Jul 20:42   s912-dmip-mhz.patch
drwxr-xr-x     - marly marly 22 Jul 10:14   src
```
成功编译了内核和headers，运行 `sudo pacman -U ./linux-odroid-5.18.12-1-aarch64.pkg.tar.zst ./linux-odroid-headers-5.18.12-1-aarch64.pkg.tar.zst` 即可安装：

```bash
 marly@manjaro-minimal  /linux-odroid   master   sudo pacman -U ./linux-odroid-5.18.12-1-aarch64.pkg.tar.zst ./linux-odroid-headers-5.18.12-1-aarch64.pkg.tar.zst 
[sudo] password for marly: 
loading packages...
resolving dependencies...
looking for conflicting packages...
:: linux-odroid and linux are in conflict. Remove linux? [y/N] y

Packages (3) linux-5.18.11-1 [removal]  linux-odroid-5.18.12-1  linux-odroid-headers-5.18.12-1

Total Installed Size:  139.23 MiB
Net Upgrade Size:        9.91 MiB

:: Proceed with installation? [Y/n] y
(2/2) checking keys in keyring                                               [###########################################] 100%
(2/2) checking package integrity                                             [###########################################] 100%
(2/2) loading package files                                                  [###########################################] 100%
(2/2) checking for file conflicts                                            [###########################################] 100%
(3/3) checking available disk space                                          [###########################################] 100%
:: Processing package changes...
(1/1) removing linux                                                         [###########################################] 100%
(1/2) installing linux-odroid                                                [###########################################] 100%
Optional dependencies for linux-odroid
    crda: to set the correct wireless channels of your country [installed]
(2/2) upgrading linux-odroid-headers                                         [###########################################] 100%
:: Running post-transaction hooks...
(1/4) Arming ConditionNeedsUpdate...
(2/4) Updating module dependencies...
(3/4) Updating linux-odroid module dependencies...
(4/4) Updating linux-odroid initcpios...
==> Building image from preset: /etc/mkinitcpio.d/linux-odroid.preset: 'default'
  -> -k 5.18.12-1-MANJARO-ARM-ODROID -c /etc/mkinitcpio.conf -g /boot/initramfs-linux.img
==> Starting build: 5.18.12-1-MANJARO-ARM-ODROID
  -> Running build hook: [base]
  -> Running build hook: [udev]
  -> Running build hook: [plymouth]
  -> Running build hook: [autodetect]
  -> Running build hook: [modconf]
  -> Running build hook: [block]
  -> Running build hook: [filesystems]
  -> Running build hook: [keyboard]
  -> Running build hook: [fsck]
==> WARNING: No modules were added to the image. This is probably not what you want.
==> Creating gzip-compressed initcpio image: /boot/initramfs-linux.img
==> Image generation successful
```
至此编译安装内核成功完成，重启盒子继续折腾。

# 内核测试
``` bash
uname -a
Linux manjaro-minimal 5.18.12-1-MANJARO-ARM-ODROID #1 SMP PREEMPT Fri Jul 22 10:17:23 CST 2022 aarch64 GNU/Linux

modinfo ax25
name:           ax25
filename:       (builtin)
alias:          net-pf-3
license:        GPL
file:           net/ax25/ax25
description:    The amateur radio AX.25 link layer protocol
author:         Jonathan Naylor G4KLX <g4klx@g4klx.demon.co.uk>

modinfo mkiss
name:           mkiss
filename:       (builtin)
alias:          tty-ldisc-5
license:        GPL
file:           drivers/net/hamradio/mkiss
description:    KISS driver for AX.25 over TTYs
author:         Ralf Baechle DL5RB <ralf@linux-mips.org>
parm:           crc_force:crc [0 = auto | 1 = none | 2 = flexnet | 3 = smack] (int)


sudo direwolf -p

Dire Wolf DEVELOPMENT version 1.7 E (Jun 29 2022)
Includes optional support for:  cm108-ptt dns-sd
Dire Wolf requires only privileges available to ordinary users.
Running this as root is an unnecessary security risk.

Reading config file direwolf.conf
Audio device for both receive and transmit: plughw:0,0  (channel 0)
Channel 0: 1200 baud, AFSK 1200 & 2200 Hz, A+, 44100 sample rate.
Ready to accept AGW client application 0 on port 8000 ...
Ready to accept KISS TCP client application 0 on port 8001 ...
DNS-SD: Avahi: Failed to create Avahi client: Daemon not running
Virtual KISS TNC is available on /dev/pts/1
Created symlink /tmp/kisstnc -> /dev/pts/1


sudo kissattach /dev/pts/1 wl2k
AX.25 port wl2k bound to device ax0
```
测试结果符合预期。