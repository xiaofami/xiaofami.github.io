---
title: Manjaro设置静态IP
date: 2023-02-16 10:40:22
tags:
- R3300-M
- Manjaro ARM
- dhcpcd
index_img: /img/dhcpcd.png
---
R3300-M的IP地址变来变去比较烦人，于是给它设置一下静态IP。由于没有使用NetworkManager，我们用dhcpcd来实现。

```bash
sudo vim /etc/dhcpcd.conf
```
在文件末尾添加如下内容，根据自身实际修改。

```conf
interface eth0
static ip_address=10.0.0.100/24
static routers=10.0.0.1
static domain_name_servers=75.75.75.75 75.75.76.76 2001:558:feed::1 2001:558:feed::2

interface wlan0
static ip_address=10.0.0.99/24
static routers=10.0.0.1
static domain_name_servers=75.75.75.75 75.75.76.76 2001:558:feed::1 2001:558:feed::2
```
DNS服务器根据自身喜好填写，可以参考 `/etc/resolv.conf` 内容。保存后执行 sudo systemctl restart dhcpcd.service` 重启服务即可。