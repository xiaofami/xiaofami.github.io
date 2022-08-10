---
title: FT-8900R操作Packet Radio教程——By BH2VJW
date: 2022-08-10 16:23:12
tags:
packet radio
---
# 前言
当初买FT-8900R时笔者还是纯纯的小白，买它的原因之一是《业余无线电通信（第五版）》的推荐，其二是电台支持四频段双工操作，其三是DATA插孔具有极强的迷惑性。我一度以为只要用数据线连接电台和电脑，就能传输数字信息，当然实际上并非如此。后来读了几遍手册，说是要用到TNC这个东西，然而国内根本没得卖，资料也近乎为零，ham群里大多在讨论mmdvm和FT8，没有人在玩Packet Radio。经过一段时间摸索，笔者终于验证出FT-8900R进行Packet Radio操作的一套可行方案。
# Packet Radio沿革
讨论Packet Radio无法跳过它的发展历史，否则许多疑惑就很难解答。一个比较系统的介绍是 **WB9LOZ** 成稿于上世纪九十年代的[INTRODUCTION TO PACKET RADIO](https://www.choisser.com/packet/)，里面详细介绍了硬件构成、TNC命令、中继与节点的区别、BBS使用等内容。简而言之，Packet Radio起源于1980年的加拿大，并迅速在美国、西欧等地流行。那时Packet Radio的硬件系统一般为 **电台-TNC-电脑/哑终端** ，也有 **电台-调制解调器-电脑（运行软件充当软TNC）** 这种比较少见的形式。TNC实现了 **ASCII字符 - AFSK语音** 之间的转换，是一种硬件设备，比较经典的TNC有TAPR出品的TNC-1和TNC-2，当年售价大概100美元。同时期国内爱好者能凑齐电台、电脑、TNC的恐怕凤毛麟角，这解释了为什么许多国内爱好者对Packet Radio、TNC之类名词毫无概念。
# 2022年利用FT-8900R操作Packet Radio所需的软硬件
## 硬件
1. FT-8900R电台。
2. 马工盒子，充当电台连接器，同时提供PTT控制。对于八重洲那些采用6 PIN mini-DIN接口（笔者按:貌似就是PS/2接口）的车台，国外的成品连接器[Dinah](https://hamprojects.info/dinah/)提供了更简洁的接口。Dinah使用CM119声卡方案，利用CM119的GPIO针脚实现了PTT控制功能，这样连接器只需要通过一个6 PIN mini-DIN接口连接电台，一个USB接口连接电脑就可以了，不再需要额外的声卡，也不需要额外的USB接口提供PTT控制。动手能力强的爱好者可以购买CM108/CM119方案的USB声卡自行改造。
3. USB声卡，9.9元包邮款即可，需要Speaker与MIC有独自接口。高级一些的还会有Line IN接口不过非必需。
4. 电脑。为降低成本，我在一个40元的电视盒子上运行Manjaro ARM系统，充当电脑主机。这个盒子具备4核2GHz的处理器，令当年专门用来搭建Node、BBS的奔腾处理器电脑望尘莫及，所以不需要担心硬件性能不够。
## 软件
1. [Direwolf](https://github.com/wb2osz/direwolf)
我们用它来充当软件KISS TNC。通过KISS OVER TCP功能可以方便地进行远程连接，即运行Direwolf和与电台直接连接的电脑，与我们运行客户端软件用来收发消息的电脑不必是同一台，这为远程使用提供了便利。Direwolf也可以创建伪终端设备（编者按：该特性仅对Linux有效）供老式程序使用。此外Direwolf还可以提供APRS GPS Tracker、Digipeater、IGate、APRStt gateway等功能，有兴趣的可以深入了解。
Direwolf的编译毫无难度，拉取Github源码后编译即可，需要的依赖Manjaro仓库中都有提供。
2. [LinBPQ](https://www.cantab.net/users/john.wiseman/Documents/LinBPQGuides.html)
LinBPQ可以在一台电脑上同时提供Node、BBS、聊天服务器、WinLink网关等功能，支持KISS OVER TCP。编译和配置稍显麻烦，方法可以参考[Manjaro ARM编译LinBPQ](https://tccmu.com/2022/07/25/linbpq/)和[LinBPQ配置](https://tccmu.com/2022/07/28/linbpq-config/)。
3. [ax25tools](https://github.com/ve7fet/linuxax25/releases/tag/ax25tools-1.0.4)
**ax25tools** 提供了ax25apps， ax25tools和libax25，需要分别编译安装。注意对于ax25app，需要将**linuxax25-ax25tools-1.0.4/ax25apps/call/call.c**中第45行 **#include <ncursesw/ncurses.h>** 修改为 **#include <ncurses.h>** 才能顺利编译。可以参考[在Manjaro ARM中编译运行Pat](https://tccmu.com/2022/07/21/pat/)。
4. [Pat](https://github.com/la5nta/pat)
Pat是一个跨平台的 Winlink 客户端，提供了命令行界面和网页界面，特性和编译使用方法可以参考[在Manjaro ARM中编译运行Pat](https://tccmu.com/2022/07/21/pat/)。
# 系统测试
## 硬件连接
电视盒子1号USB连接USB声卡，2号USB口连接马工盒子。马工盒子Data口连接电台，speaker与mic分别连接声卡的speaker与mic。
## 编解码测试
测试了1200与9600两种模式，经测试PTT控制正常，1200模式下能够清楚收听到经过调制的音频信号，编码解码正常。packet-1200对设备的要求很小，甚至用喇叭对着麦克风也能工作。
9600模式不经历 **数字信号-调制语音**之间的转换，通过FSK方式调制，听起来就像沙沙的噪音，无法分辨细节。Direwolf提供了几个便利的小工具用于测试：
```bash
$ gen_packets -o x.wav -B 9600 #生成音频
$ atest -B 9600 x.wav # 对音频解码
44100 samples per second.  16 bits per sample.  1 audio channels.
32576 audio bytes in file.  Duration = 0.4 seconds.
Fix Bits level = 0
Channel 0: 9600 baud, K9NG/G3RUH,  , 44100 sample rate x 3.
The ratio of audio samples per sec (44100) to data rate in baud (9600) is 4.6
This is on the low side for best performance.  Can you use a higher sample rate?
For example, can you use 48000 rather than 44100?

DECODED[1] 0:00.091 WB2OSZ-15 audio level = 50(+33/-33)
[0] WB2OSZ-15>TEST:,The quick brown fox jumps over the lazy dog!  1 of 4

DECODED[2] 0:00.183 WB2OSZ-15 audio level = 50(+33/-33)
[0] WB2OSZ-15>TEST:,The quick brown fox jumps over the lazy dog!  2 of 4

DECODED[3] 0:00.275 WB2OSZ-15 audio level = 50(+33/-33)
[0] WB2OSZ-15>TEST:,The quick brown fox jumps over the lazy dog!  3 of 4

DECODED[4] 0:00.368 WB2OSZ-15 audio level = 50(+33/-33)
[0] WB2OSZ-15>TEST:,The quick brown fox jumps over the lazy dog!  4 of 4


4 from x.wav
4 packets decoded in 0.014 seconds.  25.8 x realtime
```
在另一台笔记本电脑上使用gen_packets生成音频，笔记本speaker输出口连接运行Direwolf主机的USB声卡MIC口，测试解码效果。经过测试音频中包含的4条信息在95%以上的情况下只能解码出前3条，最后一条消失不见。调整输出音频与声卡音量后，问题无改善。或许是USB声卡的带宽不够？这说明9600对系统硬件的要求更高。
## Node，BBS，聊天服务器测试
由于附近没有操作Packet Radio的爱好者故未能完成测试，不过不连接电台直接通过AX.25本地连接测试没问题，推测运行正常。另外LinBPQ的管理页面Bug较多，如需修改配置请直接改动配置文件，在网页修改容易报错崩溃。
## Pat测试
国内没有2米段的节点所以无法测试通过电波访问情况，不过使用telnet收发信正常，AX.25支持正常，推断无问题。

