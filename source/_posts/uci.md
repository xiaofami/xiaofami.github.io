---
title: 使用uci配置openwrt旁路由
date: 2024-8-1 16:33:59
tags:
- openwrt
- uci
index_img: /img/wrt.png
---
默认配置下，openwrt的LAN接口IP地址为192.168.1.1，并对外提供DHCP服务，显然该配置不适用于旁路由。这种情况下想连接到LUCI配置很不方便，还好可以使用uci轻松搞定：

```bash
uci set dhcp.lan.ignore="1"
uci commit dhcp
uci set network.lan.proto="dhcp"
uci commit network
service network restart
```

在openwrt终端中执行上述命令即可。这些命令由两部分构成：

```bash
uci set dhcp.lan.ignore="1"
uci commit dhcp
service dnsmasq restart
```
这一部分关闭了LAN接口的DHCP服务器，我们不希望同一网段中存在多个DHCP服务器。 `service dnsmasq restart` 顾名思义重启了dnsmasq服务，当然在 `service network restart` 存在的情况下可以省略，毕竟后者重启了整个网络，自然也包含dnsmasq。

```bash
uci set network.lan.proto="dhcp"
uci commit network
service network restart
```

这一部分将LAN接口的网络协议修改成为DHCP，即由主路由DHCP服务器分配。你当然可以手动分配，不过我更偏好这种方式。

如此一来，我们的openwrt就完成了初步设置，可以访问LUCI界面进行后续操作。
