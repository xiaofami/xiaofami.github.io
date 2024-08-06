---
title: Mikrotik Routeros 7.15 CF DDNS 脚本
date: 2024-8-6 09:30:49
tags:
- ROS
- cloudflare
- DDNS
index_img: /img/mikrotik.png
---
Miktotik Routeros利用脚本能够方便实现DDNS功能。如果你的域名托管在cloudflare平台，可以直接使用下述脚本，适用于最新版的Mikrotik Routeros 7.15，将脚本执行与PPPoE UP事件关联即可。

# IPv4版本
具备IPv4公网地址的网友推荐此脚本。

```bash
# Cloudflare Dynamic DNS update script
# Required policy: read, write, test, policy
# Add this script to scheduler
# Install DigiCert root CA or disable check-certificate
# Configuration ---------------------------------------------------------------------

:local TOKEN "*********************************"
:local ZONEID "********************************"
:local RECORDID "******************************"
:local RECORDNAME "****************************"
:local WANIF "*********************************"

#------------------------------------------------------------------------------------

:global IP4NEW
:global IP4CUR

:local url "https://api.cloudflare.com/client/v4/zones/$ZONEID/dns_records/$RECORDID/"

:if ([/interface get $WANIF value-name=running]) do={
# Get the current public IP
    :local currentIP [/ip address get [/ip address find interface=$WANIF ] address];
    :set IP4NEW [:pick $currentIP 0 [:find $currentIP "/"]];
# Check if IP has changed
    :if ($IP4NEW != $IP4CUR) do={
        :log info "CF-DDNS: Public IP changed to $IP4NEW, updating"
        :local cfapi [/tool fetch http-method=put mode=https url=$url check-certificate=no output=user as-value \
            http-header-field="Authorization: Bearer $TOKEN,Content-Type: application/json" \
            http-data="{"type":"A","name":"$RECORDNAME","content":"$IP4NEW","ttl":120,"proxied":false}"]
        :set IP4CUR $IP4NEW
        :log info "CF-DDNS: Host $RECORDNAME updated with IP $IP4CUR"
    }  else={
        :log info "CF-DDNS: Previous IP $IP4NEW not changed, quitting"
    }
} else={
    :log info "CF-DDNS: $WANIF is not currently running, quitting"
}
```

简单介绍下变量含义，星号内容自行替换：

* TOKEN：Cloudflare管理后台中自行创建的API Token，安全起见不要用Global API KEY。
* ZONEID：对应Cloudflare域名管理“overview”页面右下能直接看到的 Zone ID值。
* RECORDID：动态域名解析的ID值。注意，对于同一个域名，不同解析类型的ID值也不同，例如A记录和AAAA记录的ID值就不一样。可以在Cloudflare控制面板中手动创建一条解析记录，然后到Cloudfalre的Audit LOG中查看对应ID值。
* RECORDNAME：具体动态域名。
* WANIF：对应PPPoE拨号的接口名称。routeros中一般默认为 **pppoe-out1**。

# IPv6版本
没有公网IPv4地址，但是有公网IPv6地址的网友可以使用这个脚本。一般而言，国内家宽可以从ISP获取到60长度前缀，记得在IPv6 Addreess List中给WAN接口分配地址，默认 **::/64** 即可，Mikrotik Routeros会结合前缀自动计算并分配地址。

```bash
# Cloudflare Dynamic DNS update script
# Required policy: read, write, test, policy
# Add this script to scheduler
# Install DigiCert root CA or disable check-certificate
# Configuration ---------------------------------------------------------------------

:local TOKEN "*********************************"
:local ZONEID "********************************"
:local RECORD6ID "*****************************"
:local RECORDNAME "****************************"
:local WANIF "*********************************"

#------------------------------------------------------------------------------------

:global IP6NEW
:global IP6CUR

:local url6 "https://api.cloudflare.com/client/v4/zones/$ZONEID/dns_records/$RECORD6ID/"

:if ([/interface get $WANIF value-name=running]) do={
# Get the current public IP
    :local currentIP [/ipv6/address/get [:pick [find global interface=$WANIF] 0 ] address ]
    :set IP6NEW [:pick $currentIP 0 [:find $currentIP "/"]];
# Check if IP has changed
    :if ($IP6NEW != $IP6CUR) do={
        :log info "CF-DDNS: Public IPv6 address changed to $IP6NEW, updating"
        :local cfapi [/tool fetch http-method=put mode=https url=$url6 check-certificate=no output=user as-value \
            http-header-field="Authorization: Bearer $TOKEN,Content-Type: application/json" \
            http-data="{\"type\":\"AAAA\",\"name\":\"$RECORDNAME\",\"content\":\"$IP6NEW\",\"ttl\":120,\"proxied\":false}"]
        :set IP6CUR $IP6NEW
        :log info "CF-DDNS: Host $RECORDNAME updated with IP $IP6CUR"
    }  else={
        :log info "CF-DDNS: Previous IPv6 $IP6NEW not changed, quitting"
    }
} else={
    :log info "CF-DDNS: $WANIF is not currently running, quitting"
}
```

上述脚本直接从本地获取公网地址，不像许多脚本那样**fetch**外部API查询，故可靠性、安全性更优越。