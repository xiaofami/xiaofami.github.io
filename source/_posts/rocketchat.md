---
title: 使用Rocket.Chat搭建聊天服务器
date: 2021-10-27 16:21:57
tags:
- Manjaro
- ARM
- aarch64
- Rocket.Chat
---
# 前言
Rocket.Chat是一个开源，可定制的交流平台，支持docker和snap。本文介绍在Manjaro ARM的安装方式。

# 安装
首先安装snap：

```bash
sudo pacman -Sy snapd
sudo snap install rocketchat-server
```

然后在浏览器中，访问服务器的3000端口就行了。注意3000端口常用（比如mdbook就会默认占用），注意不要冲突。

完成安装后，系统会自动配置好相应服务，默认开机启动，不需要额外配置：
```bash
systemctl status snap.rocketchat-server.rocketchat-server.service
● snap.rocketchat-server.rocketchat-server.service - Service for snap application rocketchat-server.rocketchat-server
     Loaded: loaded (/etc/systemd/system/snap.rocketchat-server.rocketchat-server.service; enabled; vendor preset: disabled)
     Active: active (running) since Thu 2021-10-28 15:41:03 CST; 2min 58s ago
   Main PID: 443 (startRocketChat)
      Tasks: 25 (limit: 664)
     Memory: 544.6M
        CPU: 2min 10.298s
     CGroup: /system.slice/snap.rocketchat-server.rocketchat-server.service
             ├─ 443 /bin/bash /snap/rocketchat-server/1460/bin/startRocketChat
             └─1140 node /snap/rocketchat-server/1460/main.js

Oct 28 15:43:41 marly-aml rocketchat-server.rocketchat-server[1140]: ➔ |      MongoDB Version: 3.6.21            |
Oct 28 15:43:41 marly-aml rocketchat-server.rocketchat-server[1140]: ➔ |       MongoDB Engine: wiredTiger        |
Oct 28 15:43:41 marly-aml rocketchat-server.rocketchat-server[1140]: ➔ |             Platform: linux             |
Oct 28 15:43:41 marly-aml rocketchat-server.rocketchat-server[1140]: ➔ |         Process Port: 3000              |
Oct 28 15:43:41 marly-aml rocketchat-server.rocketchat-server[1140]: ➔ |             Site URL: http://localhost  |
Oct 28 15:43:41 marly-aml rocketchat-server.rocketchat-server[1140]: ➔ |     ReplicaSet OpLog: Enabled           |
Oct 28 15:43:41 marly-aml rocketchat-server.rocketchat-server[1140]: ➔ |          Commit Hash: 5e9f4bc424        |
Oct 28 15:43:41 marly-aml rocketchat-server.rocketchat-server[1140]: ➔ |        Commit Branch: HEAD              |
Oct 28 15:43:41 marly-aml rocketchat-server.rocketchat-server[1140]: ➔ |                                         |
Oct 28 15:43:41 marly-aml rocketchat-server.rocketchat-server[1140]: ➔ +-----------------------------------------+

```
服务启动比较慢，如果`systemctl status snap.rocketchat-server.rocketchat-server.service`提示`ERROR: ld.so: object '/usr/lib/libgtk3-nocsd.so.0' from LD_PRELOAD cannot be preloaded (cannot open shared object file): ignored.`，等待3分钟即可。
# 性能
参考[官方文档](https://docs.rocket.chat/quick-start/installing-and-updating/hardware-requirements)，4核1G内存的树莓派2或者3配合32G存储卡，能够满足大约50个用户同时使用。对于S905盒子而言毫无压力。
