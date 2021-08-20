---
title: 必虎路由器原厂固件探索
date: 2021-03-23 14:41:15
tags:
- 必虎
- 路由器
- openwrt
- linux
---

在`/usr/share/www`中发现*debug.html*页面，访问http://192.168.62.1/debug.html :

可用命令

```
webportal_user_status
pppstatus
dhcpcstatus
dhcpstalist
dhcpdetect
wlanstatus
wlanscan
wlankickoff
sysinfo
diskinfo
sysdebug
syscap
hwinfo
delayreboot
sta_stats
syslice
upnp_nat
if_stat
arp
route
reboot
save
mode
restore_factory
net_speed_test
wandetect
dpi
user_stat
if_rate_info
firmware_upgrade
wifi_schedule
data_stats
pppoe_pass_hack
clear_reset_flag
```


`sysinfo`

```
<?xml version="1.0" encoding="UTF-8"?><return>	<ITEM index="1" cmd="sysinfo" uptime="5:17:13" memory="22835200/62578688" cpu_usage="2" average_load="0.12/0.13/0.14" firmware_version="AP902P07V1.6.0Build798_TU" sn="BN212GH600045AA" sys_name="" sys_description="uRouter series wireless AP. Support 802.11b/g/n. 300Mbps, 2T2R." sys_model="uRouter mini SJBY" ap_vendor="BHU" uplink_interface_mac="84:82:f4:38:bd:3b" hardware_version="Z05" ip="0.0.0.0" netmask="0.0.0.0" gateway="0.0.0.0" firmware_name="kochab" longitude="" latitude="" cpu_type="MIPS 24KEc V5.5" mem_type="DDR2" mem_size="61112" flash_size="16384" sys_net_id="" primary_dns="114.114.114.114" second_dns="0.0.0.0" location="" systime="13:17:13" saved_config="" build_info="2017-11-03-09:13 Revision: 798" config_model_ver="V3" config_mode="basic" work_mode="router-ap" dev_mac="84:82:f4:38:bd:38" bmc_status="" status="done"/></return>
```

`ifrate`

```
<?xml version="1.0" encoding="UTF-8"?><return>	<ITEM index="1" cmd="ifrate" status="done">		<ifrate_sub>			<SUB interface="wlan3" tx_pkts="490" rx_pkts="367" tx_bytes="38872" rx_bytes="56368" tx_rate="0" rx_rate="0"/>			<SUB interface="wlan2" tx_pkts="0" rx_pkts="0" tx_bytes="0" rx_bytes="0" tx_rate="0" rx_rate="0"/>			<SUB interface="wlan1" tx_pkts="0" rx_pkts="0" tx_bytes="0" rx_bytes="0" tx_rate="0" rx_rate="0"/>			<SUB interface="wlan0" tx_pkts="485" rx_pkts="161" tx_bytes="75992" rx_bytes="50581" tx_rate="0" rx_rate="0"/>			<SUB interface="eth1" tx_pkts="2023" rx_pkts="0" tx_bytes="686136" rx_bytes="0" tx_rate="0" rx_rate="0"/>			<SUB interface="eth0" tx_pkts="44410" rx_pkts="49873" tx_bytes="34125041" rx_bytes="18727781" tx_rate="0" rx_rate="0"/>		</ifrate_sub>	</ITEM></return>
```

