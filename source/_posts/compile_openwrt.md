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

# 7月11日更新

由于众所周知的原因golang在编译时会提示 `dial tcp 172.217.160.113:443: i/o timeout` 并导致编译失败。可以通过使用代理解决：

```bash
export GO111MODULE=on
export GOPROXY=https://goproxy.cn
make download -j8
make -j2 V=s
```
如此之后顺利编译：

```bash
ls lede/build_dir/target-mipsel_24kc_musl/linux-ramips_mt76x8/tmp/

openwrt-ramips-mt76x8-glinet_vixmini-initramfs-kernel.bin
openwrt-ramips-mt76x8-glinet_vixmini-squashfs-sysupgrade.bin
openwrt-ramips-mt76x8-glinet_vixmini-squashfs-sysupgrade.bin.sig
openwrt-ramips-mt76x8-glinet_vixmini-squashfs-sysupgrade.bin.ucert
````