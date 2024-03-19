---
title: manjaro arm运行wireguard作为跳板机
date: 2024-03-19 15:21:53
tags:
- wireguard
- routeros
- manjaro arm
index_img: /img/wireguard.jpg
---
# 前言
折腾对象还是Bestv 3300M这个机顶盒 。。。家里新办了移动千兆宽带，资费比先前的联通300M还要便宜一大截，实测网速可达到 940/100 。可惜不提供公网IPv4地址，于是只能从IPv6上下功夫，就用wireguard + DDNS搞定吧。
# 光猫改桥接
移动送的光猫是 **ZXHN F7000MV3** ，类型如下：

    产品名称：10Gbit/s无源光网络用户端设备（XG-PON ONU）
    产品类型：中国移动智能家庭网关 类型十九
    产品型号：ZXHN F7000MV3
    默认终端配置地址：192.168.1.1
    电源规格：12V 1A
    生产日期：2024-02-29
    1个光口，4个千兆LAN口，1个USB2.0接口，1个USB3.0接口

光猫通过LOID自动下发配置，默认光猫拨号，可获得60长度的IPv6前缀。超级用户账号密码就是常见的CMCCAdmin和aDm8H%MdA2，注册设备后密码会被修改。尝试了 factorymode_crack ， 中兴telnet开启工具 等软件，均无法开启telnet。用U盘导出的配置文件也无法被ztecfg.exe解码。换一种思路，用普通用户账号进入后台记录连接信息，共3条：

    1_TR069_R_VID_4011
    2_INTERNET_R_VID_1073
    3_OTHER_B_VID_4017

自行为上网和机顶盒创建2条桥接方式连接，绑定好LAN口后填写LOID通过验证。验证后 **TR069** 会恢复并修改超密，不过关键的两条手动创建桥接没有被改动，至此光猫配置顺利完成，通过拨号可以获得60长度的前缀。
# 路由器关闭防火墙
拨号主路由是Linksys 8300，默认开启IPv6 SPI防火墙，记得关掉。MR8300作为WIFI5时代产物，WIFI测速只能勉强达到600M，不过好在家里大部分设备都采用有线接入，没必要破费升级到WIFI6了。
# manjaro arm运行ddns
采用 Newfuture DDNS更新AAAA记录，之前写过教程，不再赘述。
# manjaro arm 配置 wireguard
## 检查内核
比较新的linux内核已经包含wireguard了，可使用modinfo确认：

```bash
[marly@manjaro ~]$ modinfo wireguard
filename:       /lib/modules/6.4.3-1-MANJARO-ARM-ODROID/kernel/drivers/net/wireguard/wireguard.ko.gz
alias:          net-pf-16-proto-16-family-wireguard
alias:          rtnl-link-wireguard
version:        1.0.0
author:         Jason A. Donenfeld <Jason@zx2c4.com>
description:    WireGuard secure network tunnel
license:        GPL v2
srcversion:     C5E63ADC650EA5DDFE3643C
depends:        libcurve25519-generic,libchacha20poly1305
intree:         Y
name:           wireguard
vermagic:       6.4.3-1-MANJARO-ARM-ODROID SMP preempt mod_unload aarch64
[marly@manjaro ~]$
```
由于我们的manjaro arm是跳板机，需要经由它访问局域网内其他设备，所以需要打开内核流量转发功能。首先检查流量转发是否已启用：

```bash
[root@manjaro wireguard]# sysctl -a | grep forward
net.ipv4.conf.all.bc_forwarding = 0
net.ipv4.conf.all.forwarding = 0
net.ipv4.conf.all.mc_forwarding = 0
net.ipv4.conf.default.bc_forwarding = 0
net.ipv4.conf.default.forwarding = 0
net.ipv4.conf.default.mc_forwarding = 0
net.ipv4.conf.eth0.bc_forwarding = 0
net.ipv4.conf.eth0.forwarding = 0
net.ipv4.conf.eth0.mc_forwarding = 0
net.ipv4.conf.ip6tnl0.bc_forwarding = 0
net.ipv4.conf.ip6tnl0.forwarding = 0
net.ipv4.conf.ip6tnl0.mc_forwarding = 0
net.ipv4.conf.lo.bc_forwarding = 0
net.ipv4.conf.lo.forwarding = 0
net.ipv4.conf.lo.mc_forwarding = 0
net.ipv4.conf.wg0.bc_forwarding = 0
net.ipv4.conf.wg0.forwarding = 0
net.ipv4.conf.wg0.mc_forwarding = 0
net.ipv4.ip_forward = 0
net.ipv4.ip_forward_update_priority = 1
net.ipv4.ip_forward_use_pmtu = 0
net.ipv6.conf.all.forwarding = 0
net.ipv6.conf.all.mc_forwarding = 0
net.ipv6.conf.default.forwarding = 0
net.ipv6.conf.default.mc_forwarding = 0
net.ipv6.conf.eth0.forwarding = 0
net.ipv6.conf.eth0.mc_forwarding = 0
net.ipv6.conf.ip6tnl0.forwarding = 0
net.ipv6.conf.ip6tnl0.mc_forwarding = 0
net.ipv6.conf.lo.forwarding = 0
net.ipv6.conf.lo.mc_forwarding = 0
net.ipv6.conf.wg0.forwarding = 0
net.ipv6.conf.wg0.mc_forwarding = 0
```
输出结果表明流量转发并未开启，需要修改sysctl配置文件。找下这个文件位置：

```bash
[marly@manjaro ~]$ systemd-analyze cat-config sysctl.d
# /usr/lib/sysctl.d/10-arch.conf
# Raise inotify resource limits
fs.inotify.max_user_instances = 1024
fs.inotify.max_user_watches = 524288

# /usr/lib/sysctl.d/50-coredump.conf
#  This file is part of systemd.
```

看来修改 **/usr/lib/sysctl.d/10-arch.conf** 这个文件就行了。打开这个文件，添加
```bash
net.ipv4.ip_forward = 1
net.ipv4.conf.all.forwarding = 1
net.ipv6.conf.all.forwarding = 1
```
然后执行 `sudo sysctl -p /usr/lib/sysctl.d/10-arch.conf` 即可生效。
## 生成密钥和配置文件
首先安装 **wireguard-tools**。这个软件包提供了密钥工具、systemd服务单元文件等，能极大降低配置难度：`sudo pacman -Sy wireguard-tools` 。然后生成密钥：
```bash
wg genkey | tee key.txt | wg pubkey >> key.txt
```
key.txt中，第一行为私钥，第二行为公钥。

最后创建 `/etc/wireguard/wg0.conf` ，内容如下：

```conf
[Interface]
ListenPort = 6666
PrivateKey = 私钥，对应刚才key.txt的第一行内容
Address = 192.168.9.1/24
PostUp = iptables -I FORWARD -i wg0 -j ACCEPT; iptables -I FORWARD -o wg0 -j ACCEPT; iptables -I INPUT -i wg0 -j ACCEPT; iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
PostDown = iptables -D FORWARD -i wg0 -j ACCEPT; iptables -D FORWARD -o wg0 -j ACCEPT; iptables -D INPUT -i wg0 -j ACCEPT; iptables -t nat -D POSTROUTING -o eth0 -j MASQUERADE

[Peer]
# xiaomi 12
PublicKey = peer的公钥
AllowedIPs = 192.168.9.2/32
```
上述iptables中的eth0请结合实际修改，具体名称可通过 `ip a` 查看。
## 启动 wireguard 服务
```bash
sudo systemctl enable --now wg-quick@wg0
```
至此manjaro arm中的wireguard配置完成。peer连接到manjaro arm后，即可通过ipv4局域网地址访问各种服务。

# 跋
如果wireguard主机同时具备公网IPv4与IPv6地址，可以实现仅具备IPv4地址的peer访问IPv6站点，笔者已在routeros中配置成功。