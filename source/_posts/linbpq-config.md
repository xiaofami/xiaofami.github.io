---
title: LinBPQ配置
date: 2022-7-28 10:45:23
tags:
- Node
- bpq32
---
之前已经成功为Manjaro ARM编译了LinBPQ，现在来研究如何配置。

配置过程中参考了 [Winlink Gateway on a Raspberry Pi LinBPQ](https://www.youtube.com/watch?v=F_s4zIUIfew)，这个视频提供了大量配置细节。

# 生成bpq32.cfg配置文件
这个文件可以参考 [G8BPQ Home Page](https://www.cantab.net/users/john.wiseman/Documents/index.html) ，不过这个过程比较痛苦。好在 **John G8BPQ** 制作了图形化的配置文件生成器 [BPQConfigGen](https://www.cantab.net/users/john.wiseman/Documents/BPQConfigGen.html) ，下载运行即可。Windows版本的功能比Linux版少一些，不过在Windows 10下开箱即用，十分便利。生成的配置文件如下：

```config
; Written by BPQConfigGen

SIMPLE
NODECALL=BH2VJW-7
NODEALIAS=FUXIN
LOCATOR=PN02TA

PORT
PORTNUM=1
 ID=Telnet Server
 DRIVER=TELNET
 CONFIG
  LOGGING=1
  TCPPORT=8010
  FBBPORT=8011
  HTTPPORT=8080
  CMS=1
  CMSCALL=BH2VJW
  CMSPASS=密码不告诉你
  USER=本地管理页面用户名,本地管理页面密码,BH2VJW,,SYSOP;
ENDPORT
PORT
 PORTNUM=2
 ID=Direwolf
 TYPE=ASYNC
 PROTOCOL=KISS
 IPADDR=127.0.0.1
 TCPPORT=8001
 CHANNEL=A
 PACLEN=128
 TXDELAY=500
 FRACK=7000
 RESPTIME=1500
 MAXFRAME=4
 RETRIES=6
WL2KREPORT PUBLIC, www.winlink.org, 8778, BH2VJW-10, PN02TA, 00-23, 145020000, PKT1200, 20, 2, 5, 0
ENDPORT


APPLICATION 1,BBS,,BH2VJW-9,,0
APPLICATION 3,RMS,C 1 CMS,BH2VJW-10,,0
APPLICATION 2,CHAT,,BH2VJW-8,,0

LINMAIL
LINCHAT

```

PORT1是用作本地管理的，不要转发到外部。本地访问8080端口可以打开管理网页，8010可支持telnet连接，FBB端口不知道具体作用。

PORT2配置连接Direwolf。注意这里与Linux下配置AX.25的区别，这里我们使用了Direwolf 的 **KISS over TCP** 协议，没有与Linux的AX.25协议产生关系，所以可以忘掉 **kissattach kissparams axports** 了。

完成上述配置后运行 **linbpq** 即可，注意 **linbpq** 与 **bpq32.cfg** 放在同一个目录下。

下面进行连接测试。

# 连接测试

```bash
call wl2k bh2vjw-7  #连接到Node，连接到Node后可以再行选择连接到下面这些
call wl2k bh2vjw-8  #连接到聊天服务器
call wl2k bh2vjw-9  #连接到BBS
call wl2k bh2vjw-10 #连接到Winlink
```
测试顺利完成，至此距离我们的Node上线运行只有连接电台一步之遥了！

为了能够公开节点信息，还需要联系Winlink管理员进行认证。在[Live System Information](https://winlink.org/rmschannels) 页面搜索 **BH2VJW** 可以看到，我们的网关由于未经认证，所以是红色状态，在[Live System Information](https://winlink.org/rmschannels) 地图上也没有显示。话说地图上显示整个东亚地区公共节点数为0，我这个或许会开创先河？

下步计划撰写systemd服务实现开机自启与进程守护。