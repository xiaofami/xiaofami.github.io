---
title: NFC标签写入NDEF数据探究
date: 2023-02-09 10:58:10
tags:
- NFC
- NDEF
index_img: /img/m1card.jpg
---
最近看到有人将网易云歌曲链接写入NFC标签，实现手机触碰播放音乐的功能，于是自己也动手试了试，基本达到了预期效果。

# 标签选择
常用的NFC标签主要有两类。一类是 **NTAG21X** ，包括 **NTAG213**， **NTAG215** 和 **NTAG216**，可用容量分别为144，504和888字节，技术规格参考 [NTAG213/215/216](https://www.nxp.com/docs/zh/data-sheet/NTAG213_215_216.pdf)。 另一类是 **MIFARE Classic 1K**， 多用于门禁卡，卡片总容量1k，技术规格参考[MF1S50YYX_V1](https://www.nxp.com/docs/zh/data-sheet/MF1S50YYX_V1.pdf)。对于这两类标签，主要从以下方面进行比较。
## 功能
这两类标签在功能上是否通用？从本人试验结果来看，两类标签提供了等价功能，在用nfc tools写入网易音乐连接、执行nfc task等方面没有展示出区别。不过 **MIFARE Classic 1K** 还可以用来制作门禁卡。
## 容量
**NTAG21X** 和 **MIFARE Classic 1K** 的存储结构并不相同。**NTAG21X**按照页面组织，每页4字节。 **MIFARE Classic 1K** 按扇区和块组织，不过我们不需要关注这些底层实现。**NTAG21X**的容量已经十分明确，**MIFARE Classic 1K** 实际可用容量又有多少呢？
参考[Mifare card memory space?](https://stackoverflow.com/questions/26343357/mifare-card-memory-space)提供了解答。**MIFARE Classic 1K** 卡片总容量1k，去掉UID、厂商信息、Key、访问位等占用，存储 **NDEF** 信息最大容量716字节，再减去header、length等占用位，实际可用容量710字节，居于**NTAG215** 和 **NTAG216** 之间。
## 价格
在PDD随机搜了几家店，每百张价格如下：

* NTAG213 			： 45.5元；
* NTAG215 			： 83元；
* NTAG216 			： 260元；
* MIFARE Classic 1K ： 48.25元！

三番比较下来，自然是便宜大碗的**MIFARE Classic 1K**中标，PDD搜索 **M1 标签**即可。

# 将网易云音乐链接写入标签实操
参考了这篇酷安教程： [NFC音乐相册（安卓版）制作工序](https://www.coolapk.com/feed/41272230)，作者使用的是 **NTAG216**，实测使用 **MIFARE Classic 1K** 在过程上没有不同，结果也一致。

# 关于手机写卡的避坑提示
我最初使用 **vivo iQOO Neo7** 写卡，但是总是提示写入失败，而且读卡结果显示容量为零，换用小米11写卡成功。经过分析，**vivo iQOO Neo7** 的NFC读写逻辑有问题，面对新卡时认为卡片容量为零，导致写入失败。经过小米11写过1次后的卡片，用 **vivo iQOO Neo7** 能够正常识别容量并覆盖写入，可以支持上述观点。关于vivo手机的这一bug已反馈给官方，能否修复就不好说了。