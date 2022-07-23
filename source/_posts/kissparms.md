---
title: kissparams简介
date: 2022-7-23 17:23:04
tags:
- ax25
- tnc
---
Direwolf配合Pat使用时遇到了一点小小的问题，Direwolf提示以下信息：

```bash
<<< Data frame from KISS client application, port 8, total length = 18
  000:  80 84 90 64 ac 94 ae e0 84 90 64 ac 94 ae 61 3f  ...d......d...a?
  010:  0a d0                                            ..
Invalid transmit channel 2 from KISS client app.

Are you using AX.25 for Linux?  It might be trying to use a modified
version of KISS which uses the channel field differently than the
original KISS protocol specification.  The solution might be to use
a command like "kissparms -c 1 -p radio" to set CRC none mode.
Another way of doing this is pre-loading the "kiss" kernel module with CRC disabled:
sudo /sbin/modprobe -q mkiss crc_force=1
```
Direwolf已经给出了提示，修复方式也很简单：
```bash
sudo kissparms -c 1 -p wl2k
```

kissparams是用来配置KISS TNC的工具。具体言之，用来配置通过kissattach命令连接到AX.25 端口的KISS TNC。kissparam通过packet接口与KISS TNC通讯，不干涉AX.25数据流，所以在对AX.25端口进行操作时，可以通过kissparam随时改变KISS TNC的配置，而不需要重新绑定端口与TNC（很方便！）。

-c为crc类型。0 = auto, 1 = none, 2 = flexnet, 3 = smack
-p为端口，同kissattach

其他几个选项自行查看man文档吧。让人介意的是-e选项，即 **FEC error correction level** 。具体如下：

```conf
Sets the FEC error correction level in a DSP card based modem (KISS parameter 8). Larger correction level means better noise resistance, but slower  throughput  on  a good connection. This is an experimental feature found in a QPSK modem for the Motorola DSP56001 based DSP4 and EVM cards only.
```

FEC，顾名思义 Forward Error Correction，Direwolf文档中在FX.25中有所提及。通过FEC技术，可以显著提升抗干扰能力，缺点是干扰较小传输良好时，通信速率比不使用FEC的连接慢，这是传输冗余信息作为纠正码的代价。可惜这个特性目前仅支持基于摩托罗拉DSP56001的DSP4和EVM，而且局限于QPSK调制。看来目前只能借助Direwolf来实现FX.25。
