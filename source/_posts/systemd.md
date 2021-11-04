---
title: Systemd
date: 2021-11-04 11:15:48
tags:
- Manjaro
- arm64
- aarch64
- systemd
---

# 推荐阅读

1. [最简明扼要的 Systemd 教程，只需十分钟](https://linux.cn/article-6888-1.html)
2. [Systemd 入门教程：命令篇](https://www.ruanyifeng.com/blog/2016/03/systemd-tutorial-commands.html)

# 几例应用
## 关闭swap
swap的使用一直存在争议，为了延长TF卡使用寿命，将其关掉。内存如果不够用，关掉一些服务就行了。毕竟不能指望一台1G内存的电视盒子面面俱到。
临时关闭：
```bash
$ sudo swapoff -a
```
永久关闭：
```bash
$ sudo systemctl stop zswap-arm.service
$ sudo systemctl disable zswap-arm.service
```
## 修改hostname
```bash
$ sudo hostnamectl set-hostname manjaro-arm
```
也可以使用`nmtui`修改，不过`hostnamectl`是`systemd`提供的工具，更底层、更直接。大部分现代Linux发行版都使用systemd。

## 定时任务
`systemd`可以编写`timer`，作为`cron`和`at`的上位替代。类似Manjaro ARM等发行版已经取消了cron的预装。

以DDNS为例：

```ddns.service
[Unit]
Description=NewFuture ddns
Requires=network-online.target

[Service]
Type=simple
WorkingDirectory=/usr/share/DDNS
ExecStart=/usr/bin/env python /usr/share/DDNS/run.py -c /etc/DDNS/config.json

[Install]
WantedBy=multi-user.target
```

```ddns.timer
[Unit]
Description=NewFuture ddns timer
Requires=network-online.target

[Timer]
OnBootSec=1m
OnUnitActiveSec=5m
Unit=ddns.service

[Install]
WantedBy=multi-user.target
```
