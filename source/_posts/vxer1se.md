---
title: Archlinux平台为VXE R1 SE+ 鼠标配置udev规则
date: 2024-12-21 19:18:12
tags:
- Archlinux
- EndeavourOS
- VXE R1 SE
index_img: https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQ2UOl9KBvZCeXw3n2qR770GGUODJRUDpLcwg&s
---
参考自[Linux 下配置udev来实现chrome对于蜻蜓R1鼠标的访问](https://www.cnblogs.com/dingnosakura/p/18274600)。

# 找到鼠标USB无线接收器的PID和VID
```bash
$ lsusb

Bus 001 Device 003: ID 3554:f58e VXE VXE Mouse 1K Dongle
```
3554为VID，f58e为PID。
# 创建udev规则文件
```bash
kate /etc/udev/rules.d/99-usb.rules
```
写入以下内容：[^1]
```udev
SUBSYSTEM=="usb", ATTRS{idVendor}=="3554", ATTRS{idProduct}=="f58e", MODE="0666"
```
# 加载udev规则
```bash
sudo udevadm control --reload-rules
sudo udevadm trigger
```

完成后，在Chrome浏览器中访问 https://hub.atk.pro/ 即可连接到鼠标进行各种设置。

[^1]:所参考的教程中创建了名为plugdev的GROUP并写入了udev规则，实测并无必要，反正已经设置了666权限。
