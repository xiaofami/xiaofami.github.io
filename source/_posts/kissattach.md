---
title: kissattach探究
date: 2022-07-22 15:25:47
tags:
- ax25
- tnc
---
参考了man手册和Direwolf文档，同时结合实际操作验证。

# 名称
kissattach, spattach —— 用于连接一个KISS或者6PACK接口

# 概要
```man
kissattach [-b] [-6] [-l] [-m mtu] [-v] tty port [inetaddr]
spattach [-b] [-l] [-m mtu] [-v] tty port [inetaddr]
```

编者按：kissattach默认使用KISS模式，spattach默认使用6PACK模式，此外并无分别。
# 描述

将一个KISS或者6PACK接口连接到KISS或者6PACK模式的TNC，就像一条普通的tty连接线一样。这个程序在执行后会自动变成后台进程，可以通过给这个后台进程发送 **SIGTERM** 以终止。

kissattach从 **axports** 文件中读取port以及相关的参数（编者补充：传统上axports路径为/etc/ax25,kissattatch也会在这里寻找axports,不过我自己编译安装的ax25toos会在/usr/local/etc/ax25/目录下寻找。另外make install后不知为何axports等配置文件没有被复制到这些位置，需要自己手动复制）。如果axports中speed是一个非零值，那么这个值会被用作串口通信速度，如果是0则意味着没有设置速度（貌似是废话）。paclen是设备的MTU值，可以通过-m选项覆盖。

tty在传统上是与KISS或者6PACK TNC连接的串口，不过也可以和伪终端（编者按：这是我们需要的，和Direwolf生成的伪终端连接）或者例如SCC卡这种KISS端口模拟器连接。kissattach也支持BSD和Unix98风格的伪终端。如果tty参数是 **/dev/ptmx** ，那么Kissattach就会自动适应Unix98的行为。对于Unix98伪终端，从tty名称是不可预见的，所以kissattach会在标准输出上另起一行输出对应从伪终端的名字。

port就是从axports文件中读取的portname值。

inetaddr参数是可选的，它是这个新接口的IP地址。有时这个选项不能省略，不过总体而言给这个接口分配IP地址的意义不大。（编者按：可以通过给接口分配IP地址来测试是否与Direwolf连接成功，该方法参考自Direwolf文档）

# 选项
-6 使用6PACK而非KISS。使用spattach调用时该选项默认开启。

-i inetaddr 设定接口的IP地址。接受hostname或者类似192.168.1.110的数字+点的形式。这个选项已经过时了，虽然能用但不推荐。

-l 将日志记载到系统日志中。默认不记载到系统日志。

-b 允许在接口上进行广播，默认不广播。

-m mtu 设置接口的mtu值，用于覆盖axports中的paclen。

-v 显示版本信息。

# 参考阅读
kill(1), stty(1), ax25(4), axports(5), axparms(8), ifconfig(8).
# 作者
       Alan Cox GW4PTS <alan@cymru.net>
       Jonathan Naylor G4KLX <g4klx@g4klx.demon.co.uk>

2017年8月1日

# 实际试验


```bash
cat /usr/local/etc/ax25/axports 
#portname       callsign        speed   paclen  window  description
wl2k              BH2VJW          1200    255     4     Direwolf

sudo direwolf -p
sudo kissattach `ls -l /tmp/kisstnc | awk '{ print $11 }'` wl2k 10.89.1.123
AX.25 port wl2k bound to device ax0

ip a show ax0
31: ax0: <BROADCAST,UP,LOWER_UP> mtu 255 qdisc fq_codel state UNKNOWN group default qlen 10
    link/ax25 BH2VJW-0 brd QST-0 permaddr LINUX-1
    inet 10.89.1.123/8 brd 10.255.255.255 scope global ax0
       valid_lft forever preferred_lft forever

ping 10.89.1.123
```



主机的IP地址为10.89.1.122，给wl2k这个接口分配地址为10.89.1.123，此时从10.89.1.122 ping 10.89.1.123，Direwolf中会出现大量信息。

另外Direwolf文档声称kissattach对符号链接支持不佳，所以没有直接用 **/tmp/kisstnc** ， 而是通过命令展开方式获取了设备实际地址。