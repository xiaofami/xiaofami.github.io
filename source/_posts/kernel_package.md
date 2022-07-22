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
HAMRADIO内核模块。可以直接编译进内核，也可以编译成内核模块，需要时再加载。
```bash
*
* Amateur Radio support
*
Amateur Radio support (HAMRADIO) [Y/n/?] y
  *
  * Packet Radio protocols
  *
  Amateur Radio AX.25 Level 2 protocol (AX25) [Y/n/m/?] y
    AX.25 DAMA Slave support (AX25_DAMA_SLAVE) [Y/n/?] (NEW) y
    Amateur Radio NET/ROM protocol (NETROM) [N/m/y/?] (NEW) y
    Amateur Radio X.25 PLP (Rose) (ROSE) [N/m/y/?] (NEW) y
    *
    * AX.25 network device drivers
    *
    Serial port KISS driver (MKISS) [N/m/y/?] (NEW) y
    Serial port 6PACK driver (6PACK) [N/m/y/?] (NEW) y
    BPQ Ethernet driver (BPQETHER) [N/m/y/?] (NEW) y
    BAYCOM ser12 fullduplex driver for AX.25 (BAYCOM_SER_FDX) [N/m/y/?] (NEW) y
    BAYCOM ser12 halfduplex driver for AX.25 (BAYCOM_SER_HDX) [N/m/y/?] (NEW) y
    BAYCOM picpar and par96 driver for AX.25 (BAYCOM_PAR) [N/m/?] (NEW) y
```
# 2000 YEARS LATER
若干小时后编译还没有完成，还是找开发者吧 😂 已经私信了linux-odroid管理员，如果一切顺利linux-odroid 5.18.12即可支持AX25。