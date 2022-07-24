---
title: Pat通过AX.25连接Winlink阶段性总结
date: 2022-7-23 19:43:50
tags:
- ax25
- direwolf
- pat
- Manjaro
---
最近一段时间里经过大量阅读和实际操作，我对于AX.25有了更深入的了解，Pat等程序的使用配置也逐渐熟练。今天看到了一个名为[Pat Winlink 2M Packet 1200 baud Setup](https://www.youtube.com/watch?v=o8OBF47UkeI&ab_channel=KM4ACK)的视频教程，KM4ACK在树莓派上利用AX.25, direwolf和Pat实现了packet radio连接Winlink网络。经过比较，该教程思路和操作与我在R3300-M盒子上的操作基本一致，这证明利用电视盒子实现packet radio是完全可行的。这批文章对之前几篇的关键点进行了总结，并补充了遗漏内容。

# 内核
为了在Linux中进行AX.25操作，内核必须支持AX.25。之前我在Manjaro ARM中使用的linux-odroid内核没有预编译对应模块，自行编译内核足足花费了5个小时，不过一次成功。另外经过联系内核维护者，AX.25内核模块已在配置文件中启用，，如无意外linux-odroid在下一个更新便会原生支持AX.25，倘若如此就不需要自己编译内核了。
# ax25tools
https://github.com/ve7fet/linuxax25/releases/tag/ax25tools-1.0.4 由ax25apps， ax25tools, libax25 三部分构成，需要分别编译安装，方法之前已详细介绍。有几点需要特别说明：

1. ax25tools合集中提供的 **kissattach** 等程序会在 `/usr/local/etc/ax25` 目录下寻找 **axports** 等配置文件；
2. make install 没有将这些配置文件复制到 `/usr/local/etc/ax25` 目录下，所以需要自己手动建立配置文件；
3. Pat会在 `/etc/ax25` 目录下寻找 **axports** ，作为变通手段，可以建立软连接： `sudo ln -s /usr/local/etc/ax25 /etc/ax25`。

# Direwolf
编译安装方法之前已详细介绍，额外几点补充说明：
1. 需要启用 **avahi** 服务，否则 Direwolf 会提示 **DNS-SD: Avahi: Failed to create Avahi client: Daemon not running** ：
```bash
sudo systemctl enable --now avahi-daemon.service
```
2. 合理设置以避免使用root权限运行Direwolf。我使用了FT232将串口转换成USB（淘宝买的U5-Link），在Manjaro中对应设备为 **/dev/ttyUSB0** ：
```bash
$ ls /dev/ttyUSB0
Permissions  Size User Group Date Modified Name
crw-rw----  188,0 root uucp   3 Jun 20:59  /dev/ttyUSB0
```
为了能够以普通用户身份读写 `/dev/ttyUSB0` ，需要将当前用户（我的用户名是marly） 添加到 **uucp** 这个组中：
```bash
$ sudo usermod -aG uucp marly
$ id marly
uid=1000(marly) gid=1000(marly) groups=1000(marly),3(sys),90(network),98(power),998(wheel),996(audio),994(input),991(lp),987(storage),986(uucp),985(video),984(users),970(sambashare)
```
通过id命令可以得知当前用户已成功加入到 **uucp** 组中。 **重新登录SSH以使改动生效！**

另外Direwolf每次启动都会创建 **/tmp/kisstnc** 这个指向实际pts设备的符号连接。所以如果你之前用root身份运行过direwolf，direwolf就无法新建 **/tmp/kisstnc** ，把**/tmp/kisstnc**删除一次就可以了。以后创建的**/tmp/kisstnc**不会再遇到这种权限问题。

# KISS TNC配置
测试Direwolf时，发现Direwolf提示
```config
Are you using AX.25 for Linux?  It might be trying to use a modified version of KISS which uses the channel field differently than the original KISS protocol specification.  The solution might be to use a command like "kissparms -c 1 -p radio" to set CRC none mode. Another way of doing this is pre-loading the "kiss" kernel module with CRC disabled: sudo /sbin/modprobe -q mkiss crc_force=1
```
运行 `sudo kissparms -c 1 -p wl2k` 即可。

# 下步计划
计划研究利用LinBPQ搭建Winlink网关，[Winlink Gateway on a Raspberry Pi LinBPQ](https://www.youtube.com/watch?v=F_s4zIUIfew) 这个视频应该会很有帮助。不知道本地的火腿能不能帮忙实测packet radio效果。

另外 [Configuring Linux AX.25](https://www.febo.com/packet/linux-ax25/ax25-config.html) 推荐阅读，有助于加深对AX.25工作方式及使用方法的理解。
