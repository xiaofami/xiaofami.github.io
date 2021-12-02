---
title: Packet Radio学习
date: 2021-11-18 14:37:29
tags:
- ham
- FM
- TNC
- Packet Radio
- Yaesu
---
# 从零开始
手里有台八重州FT-8900R，是当年对业余无线电近乎一无所知时购买的第一步电台。官方手册上说其背部的Data Port可以搭配TNC实现Packet Radio功能。由此，很自然产生了几个疑问：

1. 何为封包无线电
可以参考[业余无线分包通信DIY](https://www.qsl.net/bd6cr/prdiy.pdf)、[Packet-Radio-Modulation](http://www.symek.com/g/pacmod.html)、[Introduction to Packet Radio](https://www.bugoutbagbuilder.com/blog/introduction-packet-radio)、[Packet Radio](http://www.wattystuff.net/amateur/packet/whatispacket.htm)以及[Packet Radio](https://www.dxzone.com/catalog/Software/Packet/)几篇文章。封包无线电的概念无需赘述，这里只需要明确一点：普通的FM收发机即可使用NFM模式，在UHF/VHF频段以1200或2400bps速率进行封包无线电操作。

2. FM收发机支持哪些玩法
身边的ham圈里大家不是在玩短波就是数字+MMDVM，FM少有人涉足。刚刚通读了《业余无线电通信（第四版）》的小白可能会对语音以外的诸多通信模式跃跃欲试，不过在购买设备前最好先弄明白模式与频段对于一台收发机的意义。频段很直观，一部仅支持U/V两端的手台，当然不支持收发5MHz的短波。另一方面，电台即便支持某一频段，也未必支持特定模式。FM收发机价格便宜，不过只支持频率调制，即**Frequency Modulation**的字面含义，没有办法进行CW、PSK31等操作。具体可以参考[2m or 70cm FM mobile radio for digital mode operation](https://ham.stackexchange.com/questions/464/2m-or-70cm-fm-mobile-radio-for-digital-mode-operation)和[PSK and FSK over NBFM](https://jontio.zapto.org/hda1/psk-and-fsk-over-fm.html)。举个例子，FM收发机连接电脑可以用类似cw player软件在439.500MHz“发电报”，在其他电台里守听可以听到滴滴哒哒的摩斯码声音，不过这和真正的全模式电台在439.500MHz进行CW操作存在本质区别，其核心就是电台调制解调方式。CW最大带宽不超过150Hz，NFM则要占用3KHz，是CW的20倍，遑论能效比的差距。

所以总结下来，FM收发机除了语音通联/中继，貌似只有封包无线电一路可走。

3. TNC是什么
TNC，Terminal Node Controller，中文翻译终端节点控制器。淘宝搜索零条匹配 …… 请教了群里大佬，大佬在指出封包无线电与TNC是上世纪遗产之余，推荐了名为**专用电台连接器**的东西。到手后主体就是个小盒子，盒子反面具备**CAT**、**DATA**、**CW**接口（对于FT-8900R只能用上DATA），正面具备**SP**、**MIC**和**USB**口，显然这3个都需要连接电脑。简单测试下来，可以实现用电脑控制收发信息，自动录音等操作。

至于这个所谓的**专用电台连接器**，卖家没有提供原理图，不过国外ham显然也折腾过类似东西：[UD04YA USB Data Mode Cable - PDF4PRO](https://pdf4pro.com/cdn/ud04ya-radioarena-5b0ccd.pdf)。结合八重州电台DATA针脚定义来看，电台输入输出音频信号直连电脑，PTT通过虚拟COM口和电脑连接实现控制。所以**专用电台连接器**并不是TNC，是字面意义上的连接器。过去硬件TNC的大部分功能，如今已经在电脑上软件实现了。
# 软件包选择
## 概述
参考[Packet Radio](http://www.wattystuff.net/amateur/packet/whatwindowsprograms.htm)，作者介绍了[MixW](http://www.mixw.net/)，**Flexnet32**和[AWGPE](https://www.sv2agw.com)。对于前两者作者给予了积极评价。至于**AWGPE**，作者评价其“不稳定”“不值得花钱”，不过**AWGPE**在国内较前两者知名度更高一些，可以自行评估判断。

除了上面3个Windows专有软件，跨平台的**soundmodem**值得一提。在Debian衍生系统中，可以用apt命令直接安装，最新版为0.2，更新于2000年8月1日……如果发行版软件仓库里没有，那就只能自行编译。经过一番考古找到了0.2版本的源码：

https://github.com/yu4zed/soundmodem-backup

备用下载地址：
1. https://archive.org/details/soundmodem-0.20
2. https://archive.org/download/soundmodem-0.20/soundmodem-0.20.tar.gz
3. http://archive.ubuntu.com/ubuntu/pool/universe/s/soundmodem/soundmodem_0.20.orig.tar.gz

源码包下载下来解压缩，进入目录执行`./configure`，根据提示查缺补漏。我的Deepin编译环境比较全，所以只额外安装了**libgtk2.0-0**和**libaudiofile-dev**。configure没问题执行`make CXXFLAGS+=" -fpermissive"`，然后`sudo make install`即可。

除了man页面，对**soundmodem**的介绍还可以参考[Multiplatform Soundcard Packet Radio Modem](https://www.qsl.net/g0wfv/soundmodem/)，页面上同时给出了Windows安装包。不过都是老古董，即便不能正常运行也不要过于失望。
## AGWPE
本部分主要参考自[Download and Install AGWPE](https://www.soundcardpacket.org/2agwget.aspx)。
### 下载
下载页面： https://www.sv2agw.com/downloads/default.htm

作者的许可比较宽松，Pro版于2020年1月6日更新，以Shareware许可分发，试用期30天。按页面上对Shareware的定义，应该是试用期后也可继续使用，售价约合人民币320元。不想掏钱又不愿意试用的可以下载2013年4月15日发布的旧版，这个作者宣布ham可以永久免费使用。而且旧版支持从Win95到Win10的Windows系统，捡一台瘦主机或者上网本搭建平台也很合适。

### 安装
下载下来的压缩包绿色免安装直接运行。注意不要把程序文件夹放到**C:\Program Files**即可，否则权限问题会导致配置文件写入失败。

程序入口为**AGW Packet Engine.exe**，建议在桌面新建快捷方式。
### 配置
以一个声卡，一部电台为例配置。

注意声卡的选择。一般而言，连接主板音频插口，然后软件里选择主板声卡即可。类似无线耳机、显示器等都不要选。

2021-12-02 16:17:49 更新：

后来使用了MixW，没有用AGWPE。
## MixW
MixW还算好用，SSTV等没问题，不过受限于FT-8900R本身，可用模式不多。没有CAT功能，瀑布图不知道有什么用。
### 小结
FT-8900R作为车载FM收发机还算好用，临时架设中继也行，数字通信没有折腾价值，Packet Radio没人玩。
