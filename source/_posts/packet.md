---
title: Packet Radio科普系列笔记
date: 2022-7-26 9:55:04
tags:
- packet radio
---
# 前言
packet radio由于年代久远，国内相关讨论几乎不存在，偶见只言片语也无法形成体系。今天偶然之间读到了 **WB9LOZ** 成文于上世纪的 packet radio 专栏 [INTRODUCTION TO PACKET RADIO](https://www.choisser.com/packet/)。整个系列由十八篇文章构成，涵盖了packet radio的方方面面，是不可多得的高价值资料，强烈建议对packet radio感兴趣的爱好者阅读。

# 第一篇 什么是Packet Radio （最后修订于1997年2月8日）
## Packet Radio的起源
Packet Radio起源于1980年。1983年11月，大名鼎鼎的AX.25协议发布，同年TAPR TNC1发布。到1984年，基于Packet Radio的BBS等应用在美国、加拿大等地已经很流行。
## Packet Radio的林林总总
你是否已经厌倦了HF频段上的他台干扰？是否想在FM上尝试新玩法？是否想体验比RTTY更快、更好的信息传输方式？那么你应该尝试下Packet Radio。

在上个世纪，Packet Radio硬件一般有以下几个类型：
1. 电台 - TNC - 电脑
2. 电台 - TNC - 哑终端
3. 电台 - 调制解调器 - 电脑（电脑上同时运行特殊软件，比如Baycom）

所谓的TNC（terminal node controller） 实现了 **ASCII字符 - AFSK语音** 之间的转换，和过去电话线拨号上网很类似。比较经典的硬件TNC包括TAPR出品的TNC-1和TNC-2，以及它们的仿制品。

# 第二篇 实现Pakcet Radio发射接收

这篇详细介绍了TNC的使用方式。简言之，硬件连接妥当后，电脑上用terminal连接到TNC,然后进入TNC的命令模式进行交互式操作。

编者按：我们没有这种老式的全功能硬件TNC，所以作者苦心教授的各类 TNC 命令就没用了 。。。 我们用direwolf模拟的只是 **KISS TNC** 。

关于传统TNC与KISS TNC的比较可以参考这篇文章：[Keep It Simple Stupid -- KISS](http://tarpn.net/t/faq/faq_kiss_mode.html) ，文章摘要如下：

1. KISS协议是电脑与TNC通信的一种协议。TNC在KISS模式下，电脑接管了绝大部分工作。这种模式中，TNC并不关心数据包的来源和目的地（呼号），而是无差别解码收到的全部数据包，由主控电脑决定如何呈现或者处理这些信息。
2. KISS 模式并没有将PTT控制移交给电脑，PTT仍然由TNC控制。
3. 有的TNC支持传统与KISS两种模式，文中同时介绍了切换办法。

[The KISS TNC: A simple Host-to-TNC communications protocol](http://www.ax25.net/kiss.aspx)同样参考阅读。传统的TNC强调与人的交互性，缺点是对人可读性好的格式，对于电脑控制并不友好，反之亦然。KISS TNC完全移除了AX.25以及前一篇文章中介绍的命令解释器，由主控电脑来实现AX.25并运行各种命令。由于AX.25以及控制命令与各种程序运行在一台电脑上，系统整体的耦合型更好了。

值得玩味的是，这篇文章虽然最初发布于1987年，但是作者已经明确指出KISS TNC也只是权宜之计，理想条件下电脑应该有HDLC接口，这样独立的TNC硬件就全无必要了。目前我们 **电脑 + 声卡 + Direwolf** 的方案，是否实现了作者35年前的设想？

回到第二篇文章本身。虽然TNC命令没有参考价值了，不过几十年来信息呈现方式几乎没有变化：

```bash
WB9LOZ > W6PW-3: The meeting will be held at 8:00 pm.
WB9LOZ > W6PW-3,W6PW-1*: The meeting will be held at 8:00 pm.
```
假设这是作者在频率上收到的信息。WB9LOZ 发送给 W6PW-3 “The meeting will be held at 8:00 pm”，区别在于第一个为直频连接，第二个经过了 W6PW-1 的中转。这个W6PW-1就是所谓的 **digipeater**，扮演中继作用。

这里引入两个概念： **别名** 和 **SSID**