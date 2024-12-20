---
title: 业余无线电B证备考
date: 2022-8-1 15:11:20
tags:
- 业余无线电考试
- B
---
之前搭建packet radio节点的试验告一段落了。由于本地没有使用packet radio的ham，所以没办法测试解码效果。不过编码发送功能没有问题。另外systemd脚本也有一些问题。理想情况下ax25bind应该伴随direwolf一并重启，不过实际中虽然指定了PartOf参数，这个功能没有实现，算是小小的不完美。为了吸引到更多的爱好者参与packet radio，我计划整理出一个从理论到实操比较完整的入门教程。不过业余无线电考试快到了，B级考试还是要准备一下，packet radio暂时要放一放了。

B级考试需要记忆频率、Q短语、名词等比较琐碎的知识点。虽然有取巧记忆方法，不过为了日后规范使用频率，还是应该理解记忆。


# 频段
## 业余业务作为专用业务频段
7-7.2MHz（7.03-7.2 LSB） 14-14.25MHz（14.1 IARU, 14.1-14.35 USB） 21-21.45MHz（21.15 IARU， 21.125-21.45可USB， 除去21.1495-21.1505，即避让信标±500Hz） 28-29.7MHz（28.2 IARU, 28.3-29.3 USB， 29.51-29.7 FM） 47GHz


## 业余业务作为主要业务的频段
1.8-2MHz 3.5-3.9MHz 14.25-14.35MHz 18.068-18.168MHz （WARC, 18.11 IARU， 18.1105-18.168 USB） 24.89-24.99MHz （WARC, 24.93 IARU， 24.9305-24.99 USB） 50-54MHz 144-148MHz（144-146唯一主要，146-148共同主要，避让 144-144.035和145.8-146）

## 业余业务作为次要业务频段
135.7-137.5KHz 10.1-10.15MHz（WARC，不能用于通话） 430-440MHz（避让431.9-432.240和435-438）

LF（低频，例135.7-137.8KHz）
MF（中频，例1.8-2MHz）
HF（高频，例28-29.87MHz）
VHF（甚高频，米波，例50-54MHz）
UHF（特高频，分米波，例2300-1450MHz）
SHF（超高频，厘米波，例C、Ku波段卫星电视广播）
EHF（极高频，毫米波，例241-250GHz）

# Q简语
Q简语   问句含义   答句含义
QRA   你的电台名称是？   我的电台名称是...
QRB   你台离我台多远？   我们相距约为...
QRG   我的准确频率是多少?   你的准确频率是...
QRI   我的音调如何?   你的音调是(T1-T9)
QRJ   我的信号小吗   你的信号小
QRK   我的信号可辩度是多少?   你的信号可辩度是(R1-R5)
QRL   你忙吗？   我正忙
QRM   你受到他台干扰吗？   我正受到他台干扰 1.无 2.稍有 3.中等 4.严重 5.极端
QRN   你受到天电干扰吗？   我正受到天电干扰 1.无 2.稍有 3.中等 4.严重 5.极端
QRO   要我增加发信功率吗？   请增加发信功率
QRP   要我减低发信功率吗？   请减低发信功率
QRQ   要我发得快些吗？   请发快些
QRS   要我发得慢些吗？   请发慢些
QRT   要我停止拍发吗？   请停止拍发
QRU   你有事吗?   无事
QRV   你准备好了吗？   我已准备好了
QRW   需要我转告吗?   请转告
QRX   要我等多长时间？   请等待... ...分钟
QRZ   谁在呼叫我？   ...正在呼叫你


QSA   我的信号强度是多少?   你的信号强度是...
QSB   我的信号有衰落吗？   你的信号强度是，1.几乎不能抄收 2.弱 3.还好 4.好 5.很好
QSD   我的信号不完整吗?   你的信号不完整
QSL   你确认收妥/QSL卡片吗？   我确认收妥/QSL卡片
QSO   你能否和...直接（或转接）通信？   你能和...直接（或转接）通信？
QSP   你能中转到...吗   我能中转到...
QSU   能在这个频率(或某个频率)回复吗?   我将在此频率(或某频率)回复
QSV   有天电干扰要我在此频率发一串 V 字吗？   请在此频率发一串 V 字
QSW   你将在此频率(或某频率)发吗？   我将在此频率(或某频率)发
QSX   你将在某频率收听吗？   我将在某频率收听
QSY   要我改用其他频率拍发吗？   请改用...KHz/MHz拍发
QSZ   要我每组发两遍吗？   请每组发两遍
QTB   要我查对组数吗？   请查对组数
QTC   你有几分报要发?   我有...分报要发
QTH   你的地理位置是？   我的地理位置是...
QTR   你的标准时间是?   我的标准时间是...

# 缩写
SASE 写好收信人地址的信封
ALC  发信自动电平控制
AT   自动天线调谐
ATT  收信机自动增益衰减
AGC  收信机自动增益控制
PRE  收信机前置放大器
PROC 发信语音压缩
RIT  接收增量调谐
XIT  发射增量调谐

# 分区
## CQ分区
23 24（东沙、钓鱼） 27（黄岩岛）
## ITU分区
我国大区为3区，33 42 43 44（东沙、钓鱼） 50（黄岩岛）