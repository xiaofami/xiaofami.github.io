---
title: openwrt旁路由防火墙配置
date: 2024-8-2 08:58:47
tags:
- openwrt
- firewall
index_img: /img/wrt.png
---
我的主路由是一台运行Mikrotik Routeros 7.15 的工控小主机，i3-5010U + 4G 内存 + 8G MSATA SSD+ 32G SATA SSD配置。原本打算通过container运行 **mosdns**和**Adguard home**，但是routeros的container实在难用，所以后来这部分功能转移到了openwrt旁路由中。

运行openwrt的设备为一台J800小主机，单螃蟹网卡。在 `cgi-bin/luci/admin/network/firewall` 页面中，需要进行如下设置：

**常规设置**部分：
* 启用 SYN-flood 防御：关闭
* 丢弃无效数据包：关闭
* 启用FullCone-NAT：停用
* 入站数据：接受
* 出站数据：接受
* 转发：接受

**区域**设置里面同样把入站数据、出站数据和转发全部设置成接受，IP 动态伪装和MSS 钳制都关掉。如果不这样设置，在外面通过wireguard连接到主路由routeros后，会发现无法访问旁路由LUCI页面，也无法使用openwrt旁路由提供的DNS功能。

上述设置不难理解。旁路由不发生NAT，所以 **IP 动态伪装**（masquerade）和**FullCone-NAT**关掉。 **MSS 钳制**已由主路由routeros实现，不需要openwrt画蛇添足，所以关掉。至于 **SYN-flood 防御**、**丢弃无效数据包**同样是主路由（边界路由）才需要考虑，这里统统关掉。入站、出站、转发没有理由设置门槛，自然全部接受，至此旁路由防火墙就配置完毕了。