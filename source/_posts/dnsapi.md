---
title: 使用dnsapi签发证书
date: 2024-8-2 10:03:34
tags:
- acme
- letsencrypt
index_img: /img/acme.png
---
acme支持多种签发证书方式，之前使用的是手动创建TXT记录这种方式，过程稍显繁琐，可以使用dnsapi进行简化：

```bash
export CF_Token="*******************************"
./acme.sh --issue --dns dns_cf --server letsencrypt -d domain.com
```
注意 **CF_Token** 会被acme.sh自动保存于 **~/.acme.sh/account.conf**，请妥善保管谨防泄漏。