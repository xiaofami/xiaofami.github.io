---
title: ST-LINK V2 刷 Gnuk 资料整理（施工中）
date: 2024-8-5 10:12:03
tags:
- Gnuk
- ST-LINK V2
index_img: /img/pair.jpg
---
最近看到几篇用ST-LINK V2 刷 Gnuk的文章很感兴趣。在实际动手之前，先搜罗整理一些资料：
# 参考文献
1. [超省资安强化方案 - 比鸡排便宜的自制 USB 实体密钥](https://blog.darkthread.net/blog/low-cost-diy-usb-security-key/)
2. [按钮版 Gnuk 实体密钥刻录笔记](https://blog.darkthread.net/blog/flash-gnuk-notes/)
3. [ST-LINK V2 刷 Gnuk 拾遗](https://blog.dylanwu.space/2020/01/24/stm32-gnuk.html)
4. [用 ST-Link 自制 GnuK](https://techie-s.work/posts/2021/04/homemade-gnuk/)
5. [ST-Link v2 刷写 GNUK，年轻人的第一个 OpenPGP 智能卡！](https://www.cnblogs.com/tibrella/p/17816505.html)
6. [Homemade GnuK with ST-Dongle](https://techie-s.work/posts/2021/05/homemade-gnuk-with-stdongle/)
7. [DIY 一个 Gnuk Token](https://blog.indexyz.me/diy-gnuk-token/)
8. [ST-LINK V2 刷 Gnuk](https://kgame.tw/gnupg/stm32-gnuk/)

以下内容均梳理自上述资料。
# 硬件
## ST-LINK V2 MCU类型
MCU须为 **STM32F103C8T6** ，其具备128kb Flash。其他型号不能保障FLASH大小为128kb，如果不幸买到64kb版本就**不能刷**最新版Gnuk。至少需要购买两只ST-LINK V2，一只作为编程器，另一只作为刷Gnuk的对象。
## 接口
ST-LINK V2外部接口基本一致，重点在于内部。内部主板必须引出**DIO**和**CLK**否则**不能刷**。
## 接线
电脑连接作为编程器的ST-LINK V2无需赘言，USB直连即可。两只ST-LINK V2需要连接四条线：

* SWDIO : 尾插连接主板对应触点
* SWCLK : 尾插连接主板对应触点
* GND : 尾插直连即可
* 3.3v : 尾插直连即可

## 确认开关
将鼠标微动开关焊接在尾插CLK与3.3V之间即可。
# 固件编译
以下操作在 **Ubuntu 24.04** 中进行。

```bash
sudo apt-get install gcc-arm-none-eabi picolibc-arm-none-eabi
git clone --recursive https://salsa.debian.org/gnuk-team/gnuk/gnuk.git gnuk
cd gnuk/src
curl -O https://techie-s.work/shares/gnuk/0001-add-pa5-as-switch-pin-for-st-dongle.patch
patch ../chopstx/contrib/ackbtn-stm32f103.c < ./0001-add-pa5-as-switch-pin-for-st-dongle.patch
./configure --vidpid=234b:0000 --target=ST_DONGLE
make build/gnuk-vidpid.bin
```

执行结束后，在build目录下得到 **gnuk-vidpid.bin** 文件，它便是待烧录的固件文件。 

    ./configure --vidpid=234b:0000 --target=ST_DONGLE 输出内容：
    Header file is: board-st-dongle.h
    Configured for bare system (no-DFU)
    CERT.3 Data Object is NOT supported
    Life cycle management is NOT supported
    Acknowledge button is supported
    KDF DO is required before key import/generation


# 固件烧录
```bash
sudo apt-get install openocd
cd ~/gnuk
vi openocd.cfg
```
openocd.cfg内容如下：

```cfg
telnet_port 4444
source [find interface/stlink-v2.cfg]
source [find target/stm32f1x.cfg]
set WORKAREASIZE 0x10000
```

执行openocd，然后执行如下命令：
```telnet
stm32f1x unlock 0
reset halt
flash write_bank 0 ./src/build/gnuk-vidpid.bin 0
stm32f1x lock 0
reset halt
```

# Gnuk卡使用
```bash
sudo apt-get install scdaemon pcscd
```
安装必要工具后参照教程使用。

# Gnuk重新写入
按照相同方式连线，并短接MCU 7 (NRST) 和 8  (VSSA) 针脚，然后进入openocd执行以下命令：
```telnet
reset halt
stm32f1x unlock 0
reset halt
stm32f1x mass_erase 0
flash write_bank 0 ./src/build/gnuk-vidpid.bin 0
stm32f1x lock 0
reset halt
```