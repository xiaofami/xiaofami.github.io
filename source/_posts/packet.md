---
title: Packet Radio科普系列笔记
date: 2022-7-26 9:55:04
tags:
- packet radio
---
# 前言
packet radio由于年代久远，国内相关讨论几乎不存在，偶见只言片语也无法形成体系。今天偶然之间读到了 **WB9LOZ** 成文于上世纪的 packet radio 专栏 [INTRODUCTION TO PACKET RADIO](https://www.choisser.com/packet/)。整个系列由十八篇文章构成，涵盖了packet radio的方方面面，是不可多得的高价值资料，强烈建议对packet radio感兴趣的爱好者阅读。

# 第一篇 什么是Packet Radio
## Packet Radio的起源
Packet Radio起源于1980年。1983年11月，大名鼎鼎的AX.25协议发布，同年TAPR TNC1发布。到1984年，基于Packet Radio的BBS等应用在美国、加拿大等地已经很流行。
## Packet Radio的林林总总
你是否已经厌倦了HF频段上的他台干扰？是否想在FM上尝试新玩法？是否想体验比RTTY更快、更好的信息传输方式？那么你应该尝试下Packet Radio。

在上个世纪，Packet Radio硬件一般有以下几个类型：
1. 电台 - TNC - 电脑
2. 电台 - TNC - 哑终端
3. 电台 - 调制解调器 - 电脑（电脑上同时运行特殊软件，比如Baycom）

所谓的TNC（terminal node controller） 实现了 **ASCII字符 - AFSK语音** 之间的转换，和过去电话线拨号上网很类似。比较经典的硬件TNC包括TAPR出品的TNC-1和TNC-2，以及它们的仿制品。

# 第二篇 实现Packet Radio发射接收

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

**别名** 是有别于呼号的一串由字母和数字组成的字符，常见命名规则为地名，后面可以跟SSID。对于用户而言，呼叫呼号后者呼叫别名是等价的（因为别名会被替换回呼号，比如digipeater中继数据包时，地址里的别名会被替换回呼号）。这部分也可以参考Direwolf文档 **Page 90**。

**SSID** 是呼号后面0-15的整数，例如 **WB9LOZ-5**。**WB9LOZ-0** 等价于 **WB9LOZ** 。SSID一般用于标识同一个呼号下的多个电台/端口。

# 第三篇 TNC命令（1/3）
该篇讲解了 **TNC2** 常用命令用法。虽然这些命令已经没有用武之地了，不过从中可以了解到 **Packet Radio** 应当具有那些功能，因此值得回顾。

## CONV
CONV（conversation）为会话模式，当连接到他台时自动进入此模式。在**非连接模式**下，也可以手动切换到该模式，此时发送的所有信息都会被发送到预设的 **UNPROTO** 路径，而且只发送一次且没有回执（显而易见）。这个模式一般用于CQ呼叫。

## UNPROTO
当发送BEACON或者非连接状态下CONV发送信息的目的地，默认值为CQ，不过也可以设置令其经由digipeater,或者发送给某个别名（比如本地业余无线电协会）。例子：

* CQ v WB6SDS-2,W6SG-1,AJ7L
* SFARC v W6PW-1,W6PW-4

编者按：ax25tools 提供的beacon可以实现上述无连接发射功能。

## FRACK
TNC 等待回执的最长时间，如超时则重发。
## DWAIT
TNC 在频道上收到他台数据包后，自身发射数据前的等待时间，用于避免多个电台同时发射。
## PACLEN
一个数据包中的有效字符数量，0～255，0代表256。显然，这个值越大，单个数据包发送时间越长，越容易被干扰破坏。通信距离较短，状况良好时这个值可以大一些，反之小一些较好。
## RETRY
TNC如果没有收到他台回执，重新发包的最大次数。不要将其设为0！
## MONITOR
监视模式。如果这个选项设置为 **OFF** ，那么就只能看到当你连接到其他站点时，其他站点发送给你的信息。如果这个选项打开，则可以看到其他电台之间，或者其他电台非连接模式的广播。有几个选项可用：

**MAIL**：如果打开，可以看到其他电台之间的通信，也可以看到其他电台在非连接模式下广播的数据包。如果这个选项为OFF,就只能看到其他电台在非连接模式下广播的数据包。

**MCOM**：如果打开，可以额外显示 connect <C or SABM>, disconnect <D>， acknowledge <UA> ，busy<DM> 等信息。

**MCON**：如果打开，在自身已经与其他电台建立连接的情况下，可以显示第三方电台的信息。

**MRPT**：显示数据包完整传输路径，否则只显示source和destination,不显示digipeater。

**HEADERLN**：打印每个数据包的header信息。

**MSTAMP**：显示每个数据包的时间戳。

编者按：这些功能在AX.25，Direwolf等中有类似实现。

# 第四篇 中继（Digipeater）与节点（Node）

## Digipeater与FM语音中继的区别
FM语音中继一般为双工模式，接收与转发同时进行。Digipeater一般为单工模式，收到数据包后先暂存，然后在合适时机进行转发。 TNC可以通过 **DIGIPEAT** 命令将自己的站点变成一个 Digipeater。
## Digipeater与Node的区别
常见的节点有 **Net/Rom** ，**TheNet**， **G8BPQ packet switch**，以及 **KA-Node** 。使用digipeater时，只需要将digipeater作为路径进行指定。**使用节点时，需要首先和节点建立连接。**	 通过适当配置，一个站点可以同时扮演digipeater与node的角色。

使用Node具有一些好处：

1. 连接到Node后，可以通过 **N** 命令列出当前节点可通达的全部节点，在发起DX呼叫时，就可以二次连接到距离目的地最近的节点进行呼叫

2. 使用Node进行DX QSO时，数据包回执在相邻节点之间进行，而不需要像digipeater那样跑完全程，这样可以大大减少retry次数，提升通信效率。

编者按：Direwolf提供了Digipeater功能，Node可以用LinBPQ搭建。不过我附近这两个都没有。。。看看能不能蹭蹭APRS吧。
# 第五篇 BBS介绍
连接到BBS的方式与连接到其他普通站点的方式无异，如果目标后面有SSID，不要把它忘记。

编者按：ax25apps提供的**call**即可用于连接。ax25apps同时提供了**ax25_call**。二者的显著区别之一在于，**call**会进行行尾换行符的转换，而**ax25_call**不会。在旧式系统上，换行符为<CR>，即熟悉的 **\r**。现代Linux系统的换行符为 **\n**。

支持AX.25的内核，ax25app，ax25tools再加上Direwolf即构成了使用Packet Radio的最小软件环境。通过listen监听，call建立连接，beacon发送无连接状态信息。如果熟悉APRS格式还可以手动编制信息发送。

回到文章本身。BBS系统一般不设置密码，因为业余无线电是明文传输，即便设置了密码，在连接过程中也会变得众所周知，所以毫无意义。等完成Packet Radio实操后可以拿LinFBB搭建一个玩玩，不过人们都在玩FT8，所以十有八九又会变成一个自嗨的项目 XD

# 第六篇 Packet BBS的命令
这篇介绍了BBS的常用命令。各个BBS的命令大同小异，有兴趣可以自行了解，或者自己搭建LinFBB通过telnet连接测试。

# 第七批 分层寻址

分层寻址（HIERARCHICAL ADDRESSING）这个翻译不知是否贴切。格式如下：

```
 addressee-call @ BBS-call.#local-area.state-province.country.continent
```
例子
```
WB9LOZ @ W6PW.#NCA.CA.USA.NOAM
```