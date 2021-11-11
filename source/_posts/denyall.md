---
title: 隐匿气息！只允许cloudflare访问网站
date: 2021-11-11 15:08:44
tags:
- Manjaro
- arm64
- aarch64
- iptables
---
# 提要
上篇文章我们利用机顶盒搭建了wordpress网站，但是存在风险。政策上，国内家用宽带禁止设立网站。技术上，发现私设网站也不难。于是需要采取一些手段切断域名与真实IP地址的联系。
# 开启CDN
使用cloudflare，通过CDN访问。这样域名DNS查询结果显示的是cloudflare地址。不过仅仅这样还不够。使用`nmap`对真实地址嗅探，可以直接看到我们的盒子开放了22，80和443端口。使用curl访问443端口，caddy直接会返回信息！这样当然不行。
# 使用iptables过滤流量
为了我们的电视盒子不被发现，可以通过iptables限制只有cloudflare可以访问80和443端口，从而规避风险。Github上找到一个很好的脚本：[Manouchehri/cloudflare.sh](https://gist.github.com/Manouchehri/cdd4e56db6596e7c3c5a)

```bash
# Source:
# https://www.cloudflare.com/ips
# https://support.cloudflare.com/hc/en-us/articles/200169166-How-do-I-whitelist-CloudFlare-s-IP-addresses-in-iptables-

for i in `curl https://www.cloudflare.com/ips-v4`; do iptables -I INPUT -p tcp -m multiport --dports http,https -s $i -j ACCEPT; done
for i in `curl https://www.cloudflare.com/ips-v6`; do ip6tables -I INPUT -p tcp -m multiport --dports http,https -s $i -j ACCEPT; done

# Avoid racking up billing/attacks
# WARNING: If you get attacked and CloudFlare drops you, your site(s) will be unreachable. 
iptables -A INPUT -p tcp -m multiport --dports http,https -j DROP
ip6tables -A INPUT -p tcp -m multiport --dports http,https -j DROP
```
执行后，nmap和curl测试电视盒子真实IPv6地址均无法发现开放的80和443端口。按照 https://www.v2ex.com/t/610260 azh7138m 说法 

> 不介意速度可以套个 CF CDN
然后 drop 掉所有非 CF 的流量

这样应该就比较安全了。
