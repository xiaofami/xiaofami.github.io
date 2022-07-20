---
title: 搭建支持telnet和packet radio访问的BBS服务器
date: 2022-07-19 09:12:47
tags:
- bbs
- packet radio
---
# 前言
硬件平台还是运行Manjaro ARM的R3300-M盒子，之前已经编译运行了direwolf，理论上连接各组件后即可使用。不过我的FT-8900R在车上，之前的试验中在车上给盒子供电的5V转12V升压线被烧掉了，所以一时半会儿还无法完成测试，可能加上1个12V直流稳压模块比较好。于是在这个“间隙”中，研究一下BBS系统的搭建。

# BBS系统选择
之前连接到[hb1bbs](https://hb1bbs.com/)觉得还可以，这个BBS使用的是[Mystic BBS](http://www.mysticbbs.com/)系统。可惜经过测试，这个系统在Manjaro ARM上缺少 **ld-linux.so.3** 库文件所以无法运行。 AUR提供的 **arm-linux-gnueabihf-glibc** 可能提供了这个文件不过可惜这个包的依赖不支持arm64,好事者可以在X86-64电脑上安装然后提取。

迫于上述原因，我转而投向了 [LinFBB](https://sourceforge.net/projects/LinFBB/)。

# LinFBB安装
## 编译安装ax25
到 https://github.com/ve7fet/linuxax25  下载最新release然后编译。项目分三部分：ax25apps,ax25tools,libax25，分别进入目录执行

```bash
./autogen.sh
./configure
make -j4
sudo make install
````
编译过程大体上比较顺利。不过 **ax25app** 编译过程中会提示

```bash

call.c:45:10: fatal error: ncursesw/ncurses.h：No such file or directory
   45 | #include <ncursesw/ncurses.h>
      | 
```

开发者是基于Debian编译测试所以头文件名称与Manjaro有差异。按提示进入对应C文件将 `#include <ncursesw/ncurses.h>`修改为`#include <ncurses.h>`即可:
```bash
vim linuxax25-ax25tools-1.0.4/ax25apps/call/call.c #修改第45行
````

另外对于 **ax25tools**，安装后编译文件夹📁下面etc目录中的配置文件没有被复制到预期位置。比如执行

```bash
$ man axports

AXPORTS(5)                                       Linux Programmer's Manual                                       AXPORTS(5)

NAME
       /etc/ax25/axports - AX.25 port configuration file.

DESCRIPTION
……（以下省略）
```

在man文件描述的位置并没有这个配置文件，`/usr/local` 下面也没有。或许有必要手动创建`/etc/ax25`，然后把这些配置文件复制过去？

## 使libax25可被动态加载
```bash
cd /etc/ld.so.conf.d/
sudo vim userlocal.conf # 加入 /usr/local/lib 并保存
sudo ldconfig
```
这样刚才自编译安装的 **libax25** 就可以被动态加载了。一种比较古老的方式是使用 **LD_LIBRARY_PATH** 这个环境变量，不过Manjaro已经将其抛弃了，这个值默认是空的。

## 编译安装LinFBB
经过上面步骤后LinFBB编译安装水到渠成，照旧configure make make install三部曲，这个最后额外多了一步 `make installconf`。

如果刚才没有安装配置好 **libax25**，这里在configure时会提示 **configure: error: Could not find the libax25 libraries; aborting** 导致编译无法进行。

另外需要指出，我的编译环境没有X11,所以不会编译xfbbx X11客户端。
# LinFBB配置
上述编译安装步骤没有难度，从这里开始就要花一些心思了。

## 首次运行
```bash
sudo fbb
```
首次运行会提示许多文件不存在，按提示选择新建即可，然后添加呼号，姓名等必要信息。这些之后都可以在配置文件中修改，所以即便填错也没关系。

之后管理fbb应当使用 `/usr/local/share/doc/fbb/fbb.sh`这个脚本，用法如下：

```bash
fbb.sh start | stop | status | restart
```

等一切配置妥当后写一个systemd service用起来会更方便一点。

LinFBB提供了 **xfbbd** 和 **xfbbC** 。先不研究它们，当前的目的是配置端口以便能够通过telnet访问这个BBS。
## telnet配置
LinFBB虽然在持续的开发维护中，但BBS作为旧时代的遗珍，包括笔者在内的许多人对它很陌生。教人用wordpress之类东西搭建博客的教程浩如烟海，BBS的资料则只能散见于互联网的角落。 尽管搭建于上个世纪， https://www.f6fbb.org/ 仍然保留了大量价值无边的资料，可以作为配置LinFBB的指导。

此外 `/home/manjaro/fbb-7.0.11/doc/html/` 目录中也提供了帮助文档，可以阅读。

参考页面： https://www.f6fbb.org/fbbdoc/fmttelne.htm
编辑PORT.SYS:

```conf

#Ports：端口数量
#TNCs：总共有几个TNC（调制解调器）。在使用多工器的情况下，一个端口最多可以有4个TNC。
#Ports TNCs
2      2

#COM：串口序号，注意与Windows中的COM1 COM2概念不同，此处仅作为序号。
#Interface：在LinFBB中仅有9一个可选项，代表Linux，可以用于串口、AX25域套接字、Telnet端口。
# Address：设备名/端口号。需要确保合适权限使LinFBB可以访问设备。此外，当使用 AF_AX25 内核端口时，地址是不需要的；当使用Telenet时，地址是Tenlet端口的16进制形式。
# Baud：端口的波特率。BPQ，AF_AX25内核套接字，以及Telnet无视该设定所以填0即可。
# 这一栏目的行数与上面的端口数量保持一致。（本例中为2）

#Com Interface Address (device)   Baud
1    9         /dev/cua0          9600
2    9         189C               0

# TNC：使用中的TNC数量。0代表文件转发。
# NbCh：TNC使用的频道数量，上限取决于TNC固件。（编者注：对于direwolf之类soundcard modem,是否意味着一个TNC只有一个Channel？）
# Com：COM口的序号，需要与前文保持一致。
# MultCh：使用端口多工器情况下的频道数量，否则为1。对于DRSI用途，值为0～7；by KAM use 1/VHF and 2/HF；Linux中使用AF_AX25内核套接字时，MultCh为接口名称（例如：ax0）
# Paclen：TNC的Paclen（这是啥）
# Maxfr：TNC最大可以同时发送的帧数
# NbFwd：最多同时向外发送的频道数量。
# MaxBloc：forward-block的大小，单位为kb。
# M/P-Fwd：M代表每小时中开始转发的起始分钟，P-Fwd代表每次转发开始之间的时间间隔
# Mode：单个字母的组合，每个字母代表一种允许的模式，太长了不翻。以TUWR为例，T代表Ethernet/TCP-IP（host-mode），U代表正常模式（Port mode），W代表网关允许这个频率（附加内容），R代表调制解调器端口允许只读模式（附加内容）
# Freq：用于描述这个端口的字符串，长度最大为9,不允许空格（编者注：用Comment是不是更直观一点）

#TNC NbCh Com MultCh Pacln Maxfr NbFwd MxBloc M/P-Fwd Mode Freq
0    0    0   0      0     0     0     0      00/01   ----  File-fwd.
1    4    1   1      230   4     1     10     30/60   UDYL  433.650
2    8    2   0      250   2     1     10     00/60   TUWR  Telnet
```
本例中，telnet端口号为6300,转换为16进制即为 **189C**。重启fbb,通过nmap可以看到本机6300端口已打开，局域网中其他设备也可以通过telnet访问BBS。虽然我们的TNC尚未配置好，**/dev/cua0** 也不存在，不过不影响Telnet端口的使用。

（编者补充：在linux中，com设备一般被命名为cua）

# AX.25探究
`fbb-7.0.11/doc/html/tllinux.htm` 成文时间久远（1997），许多内容已经过时。不过其提及的[AX25-HOWTO](https://www.linuxdoc.org/HOWTO/AX25-HOWTO/)（成稿于2001年九月）值得阅读。如果上面链接不幸死掉了，可以访问 https://tldp.org/HOWTO/AX25-HOWTO/  。

## 加载AX25内核模块
这一部分不太乐观。简单检查了一下Manjaro系统（21.3.3）的内核模块，以下是默认具备的：

* ax25
* netrom
* rose
* slip
* mkiss
* lp
* baycom_par baycom_ser_fdx baycom_ser_hdx

关键的soundmodem（sm0）不在其中。https://github.com/VK3FNG/soundmodem 显示这个模块代码已经被开发者放弃。



1. 编译安装`linuxax25-ax25tools-1.0.4`其中的三个模块。上文中已完成。
2. 执行 `sudo modporbe ax25`

编者按：ax25这个模块貌似是系统自带的，**/lib/modules/5.16.20-2-MANJARO/kernel/net/ax25/ax25.ko.xz** 的创建时间远远早于编译时间。

如果需要系统启动时自动加载这个模块，可以利用 `/etc/modules-load.d` 实现，具体参见 `man modules-load.d`。


### 整合Direwolf
参考[XRpi interfacing with LinFBB](https://packet-radio.net/xrpi-interfacing-with-linfbb/) 一文，作者使用 **socat** 创建了虚拟COM口供 **XRouter** 和 **LinFBB** 使用。Linux中万物皆文件，所以使用socat创造的虚拟COM口也是一个文件，将这个文件提供给**XRouter** 和 **LinFBB**的配置文件，让它们都使用这个虚拟COM口，就实现了利用虚拟COM口连接**XRouter** 和 **LinFBB** 的目的。

Direwolf手册中描述了利用 **com0com** 创建虚拟COM接口以及修改Direwolf的步骤，可以作为参考。

未完待续