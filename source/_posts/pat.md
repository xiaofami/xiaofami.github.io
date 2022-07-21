---
title: 在Manjaro ARM中编译运行Pat
date: 2022-07-21 14:22:47
tags:
- winlink
- Pat
---
经过一些阅读，比如[Pt/Direwolf/SignaLink](https://groups.google.com/g/pat-users/c/tY1b15MD7ZM)，Linux上的AX.25栈在过去的20年中没有得到良好维护，在2022年的可用性堪忧。这些问题暂且搁置，继续收集Linux实现Packet radio的拼图🧩碎片。

# Pat是什么
Pat是一个跨平台的 **Winlink** 客户端，提供了命令行界面和网页界面

特点：

* 收信发信（简单的信箱功能）；
* 自动压缩图片附件；
* 可以通过GPS设备，网页定位或者手动输入方式报告位置消息；
* 借助hamlib,可以为winmor PTT 和 QSY 提供电台控制；
* 可以通过CRON风格的语法实现计划任务功能；
* 内建了http服务器，提供了移动端友好的页面；
* 提供了Git风格的命令行界面；
* 支持同时以多种模式监听多条P2P连接；
* 提供了 AX.25,telnet,WINMOR和ARDOP支持；
* （试验性）消息可支持gzip压缩

# Pat编译安装
编译平台：R3300-M,Manjaro ARM
```bash
git clone https://github.com/la5nta/pat
cd pat
./make.bash libax25
sudo ./make.bash
```
最后在当前目录下会生成一个名为pat的可执行文件，把它复制到`/usr/local/bin`就可以了。

# Pat配置
首次执行后生成的配置文件为 `$HOME/.config/pat/config.json` ，结合实际修改。`"http_addr": "localhost:8080"` 可修改为 `"http_addr": "0.0.0.0:8080"` 以支持外部访问，否则只能在本机上打开网络页面。

Winlink账户貌似只能在 **Winlink Express** 客户端中注册，这个软件是免费的，运行于Windows系统。

Pat的网络页面提供了多样连接方式，在既无TNC又没有电台的情况下可以使用telnet连接，经测试连接正常。

# Direwolf, AX.25, Pat

https://groups.io/g/direwolf/topic/use_pat_with_direwolf/80185118?p=,,,20,0,0,0::recentpostdate%2Fsticky,,,20,0,40,80185118

参见Direwolf用户手册 **5.8 Kiss TNC emulation-seial port** (第25页)一节：

Direwolf可以扮演成一个使用Kiss协议、通过伪终端（pseudo terminal,设备路径形如/dev/pts/1）通信的传统TNC。通过伪终端可实现虚拟COM功能（所以之前设想的socat就不需要了）：



Jeff, NC6J 于2021年1月分享的direwolf与Pat使用方式：
```bash
sudo direwolf -p 
# 观察pts符号链接，本例中假设为/dev/pts/1
sudo kissattach /dev/pts/1 port
# 这里的port是/etc/ax25/axports中定义的名称，对于Pat而言一般习惯用wl2k。我自编译的ax25apps,ax25tools,libax25不知为何没有将这些配置文件复制到指定位置
pat http # 启动pat的网页页面
# direwolf -p 进程停止后，符号链接消失，kissattach结束
```