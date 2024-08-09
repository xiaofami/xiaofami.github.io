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
9. [Gnuk on the ST-LINK v2](https://nx3d.org/gnuk-st-link-v2/)

以下内容均梳理自上述资料。
# 硬件
## ST-LINK V2 MCU类型
MCU须为 **STM32F103C8T6** ，其具备128kb Flash。其他型号不能保障FLASH大小为128KB，如果不幸买到64kb版本就**不能刷**最新版Gnuk。至少需要购买两只ST-LINK V2，一只作为编程器，另一只作为刷Gnuk的对象。
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

如果不需要确认按钮就不要打补丁。
```bash
sudo apt-get install gcc-arm-none-eabi picolibc-arm-none-eabi
git clone --recursive https://salsa.debian.org/gnuk-team/gnuk/gnuk.git gnuk
cd gnuk/src
curl -O https://techie-s.work/shares/gnuk/0001-add-pa5-as-switch-pin-for-st-dongle.patch
patch ../chopstx/contrib/ackbtn-stm32f103.c < ./0001-add-pa5-as-switch-pin-for-st-dongle.patch
./configure --vidpid=234b:0000 --target=ST_DONGLE
make build/gnuk-vidpid.bin
```

执行结束后，在build目录下得到 **gnuk-vidpid.bin** 文件，它便是待烧录的固件文件。 我编译得到的固件大小为89KB。

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
set WORKAREASIZE 0x20000 #设置Flash可用大小为128KB
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

# 小结
总体而言全流程最大难度在于买对硬件，我从淘宝下单的2只ST-LINK V2还在路上，客服承诺MCU为STM32F103C8T6而且内部主板具备CLK和DIO接口，有一点小小期待。编译和烧录在Windows平台即可完成，无需用到Linux物理机。

# 8月9日更新
2只ST-LINK V2到货。各家外观基本一致，金属外壳靠静摩擦力固定，稍用力就可以取下，内部主板各有差别。我的这个MCU型号为**STM32F103C8T6**，具备GND、CLK、DIO、3.3V四个触点。有条件建议买开洞的，方便用钩子固定，免去焊接的麻烦。


实验步骤记录如下：

## 固件编译
在Windows 11 WSL2，Ubuntu 24.04中进行：

```bash
sudo apt-get install gcc-arm-none-eabi picolibc-arm-none-eabi
git clone --recursive https://salsa.debian.org/gnuk-team/gnuk/gnuk.git gnuk
cd gnuk/src

./configure --vidpid=234b:0000 --target=ST_DONGLE
make build/gnuk-vidpid.bin
```
**gnuk-vidpid.bin** 即为准备烧录的固件。
## 烧录环境搭建
在Windows 11中进行，需要安装ST-Link V2驱动、openocd和telnet客户端。其中ST-Link V2驱动可以到ST官网免费下载（需注册），telnet客户端我用的是Mobaxterm。此二者无需赘言，重点在于openocd的安装配置。

访问 https://gnutoolchains.com/arm-eabi/openocd/ ， 下载压缩包后解压缩。将编译得到的 **gnuk-vidpid.bin** 文件放在 **OpenOCD-20231002-0.12.0\bin** 目录下，并在该目录下创建 **openocd.cfg** 文件，内容如下：

```openocd.cfg*
telnet_port 4444
source [find interface/stlink-v2.cfg]
source [find target/stm32f1x.cfg]
set WORKAREASIZE 0x20000
```

配置文件不难理解。硬件连接好后运行openocd，openocd会监听4444端口，可通过telnet访问，用户名与密码均为空，通过telnet对MCU进行固件烧录。 **set WORKAREASIZE 0x20000** 将MCU可用FLASH大小设置为128KB。**STM32F103C8T6**虽然官方标定FLASH大小为64KB，不过实际有128KB可用，这样设置可以确保我们89KB大小的固件顺利写入。

## 硬件连接

两只ST-LINK V2分别以A和B称谓，A为烧录器，B为拟写入Gnuk固件。连接方式如下：

A-尾插GND————杜邦线母头————杜邦线母头——B-尾插GND
A-尾插3.3V————杜邦线母头————杜邦线母头——B-尾插3.3V
A-尾插DIO————杜邦线母头————针头————B-主板DIO触点
A-尾插CLK————杜邦线木头————针头————B-主板CLK触点

这里没必要焊接，用手指按住就可顺利完成固件烧录。

## 烧录固件

打开cmd，cd进入到 **OpenOCD-20231002-0.12.0\bin** 中，运行 **openocd**，然后打开telnet客户端，通过127.0.0.1地址和4444端口访问，执行如下操作：

```telnet
> stm32f1x unlock 0
stm32x unlocked.
INFO: a reset or power cycle is required for the new settings to take effect.
> reset halt
[stm32f1x.cpu] halted due to debug-request, current mode: Thread
xPSR: 0x01000000 pc: 0xfffffffe msp: 0xfffffffc
> flash write_bank 0 ./gnuk-vidpid.bin 0
wrote 91136 bytes from file ./gnuk-vidpid.bin to flash bank 0 at offset 0x00000000 in 2.801311s (31.771 KiB/s)
> stm32f1x lock 0
stm32x locked
> reset halt
```

这样一个烧录了Gnuk的智能卡就做好了。

## 优化调整
新人上路难免把卡片玩坏，比如说输错三次pin码导致卡片锁死。。。重刷在原理上很简单，但是对于不想焊接的懒人又要按着DIO和CLK针脚，又要腾出手来短接 MCU 7 (NRST) 和 8 (VSSA) 针脚 属实折磨人。所以为了在玩坏情况下有后悔药可吃，在编译时应当加入factory reset功能：

```bash
export kdf_do=optional  # recommended(?) for v1.2.19
./configure --enable-factory-reset --target=ST_DONGLE --vidpid=234b:0000 --enable-certdo
```

