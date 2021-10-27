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
sudo snap refresh core --beta
sudo reboot
sudo snap install rocketchat-server
```
然后在浏览器中，访问服务器的3000端口就行了。注意3000端口常用（比如mdbook就会默认占用），注意不要冲突。

snap core安装了beta版本，默认稳定版提示`ld.so`错误，beta版运行正常。

完成安装后，系统会自动配置好相应服务，默认开机启动，不需要额外配置：
```bash
systemctl status snap.rocketchat-server.rocketchat-server.service
● snap.rocketchat-server.rocketchat-server.service - Service for snap application rocketchat-server.rocketchat-server
     Loaded: loaded (/etc/systemd/system/snap.rocketchat-server.rocketchat-server.service; enabled; vendor preset: disabled)
     Active: active (running) since Wed 2021-10-27 16:02:05 CST; 28min ago
   Main PID: 516 (startRocketChat)
      Tasks: 31 (limit: 664)
     Memory: 529.0M
        CPU: 3min 14.954s
     CGroup: /system.slice/snap.rocketchat-server.rocketchat-server.service
             ├─516 /bin/bash /snap/rocketchat-server/1460/bin/startRocketChat
             └─902 node /snap/rocketchat-server/1460/main.js

Oct 27 16:04:41 marly-aml rocketchat-server.rocketchat-server[902]: ➔ |       MongoDB Engine: wiredTiger        |
Oct 27 16:04:41 marly-aml rocketchat-server.rocketchat-server[902]: ➔ |             Platform: linux             |
Oct 27 16:04:41 marly-aml rocketchat-server.rocketchat-server[902]: ➔ |         Process Port: 3000              |
Oct 27 16:04:41 marly-aml rocketchat-server.rocketchat-server[902]: ➔ |             Site URL: http://localhost  |
Oct 27 16:04:41 marly-aml rocketchat-server.rocketchat-server[902]: ➔ |     ReplicaSet OpLog: Enabled           |
Oct 27 16:04:41 marly-aml rocketchat-server.rocketchat-server[902]: ➔ |          Commit Hash: 5e9f4bc424        |
Oct 27 16:04:41 marly-aml rocketchat-server.rocketchat-server[902]: ➔ |        Commit Branch: HEAD              |
Oct 27 16:04:41 marly-aml rocketchat-server.rocketchat-server[902]: ➔ |                                         |
Oct 27 16:04:41 marly-aml rocketchat-server.rocketchat-server[902]: ➔ +-----------------------------------------+
Oct 27 16:05:02 marly-aml rocketchat-server.rocketchat-server[902]: (node:902) [DEP0005] DeprecationWarning: Buffer() is deprecated due to security and usability issues.
```
# 性能
参考[官方文档](https://docs.rocket.chat/quick-start/installing-and-updating/hardware-requirements)，4核1G内存的树莓派2或者3配合32G存储卡，能够满足大约50个用户同时使用。对于S905盒子而言毫无压力。