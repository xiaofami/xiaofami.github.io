---
title: Manjaro安装使用transmission
date: 2021-10-19 16:36:40
tags:
- Manjaro
- ARM
- aarch64
- transmission
---
# 硬件
R3300-M一台，TF卡一个（运行Manjaro ARM），拆机硬盘DIY的移动硬盘一个。电源用12V 2A的，1A的带硬盘不够。

# 安装
```bash
sudo pacman -Sy transmission-cli
```
# 配置文件
```bash
sudo vim /var/lib/transmission/.config/transmission-daemon/settings.json
```

以下为常用配置，设置下载队列大小，下载路径，缓存等。对于一个headless下载机而言能够远程访问很重要，所以建议把局域网地址添加到`rpc-whitelist`中。
```json
"cache-size-mb": 50,
"download-dir": "/mnt/transmission",
"download-queue-size": 50,
"download-dir": "/mnt/transmission",
"rpc-whitelist": "192.168.1.*,127.0.0.1,::1",
```
# 启动服务

```bash
sudo systemctl enable transmission
sudo systemctl start transmission
```

`transmission-cli`贴心地提供了系统服务，启用即可。

# 运行smb服务

下篇讲解。