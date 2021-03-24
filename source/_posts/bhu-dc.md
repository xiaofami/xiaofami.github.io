---
title: 必虎路由器折腾记录
date: 2021-03-23 14:41:15
tags:
- 必虎
- 路由器
- openwrt
- linux
---
*路由器主板正面*
{% asset_img 必虎DC-正面.jpg 路由器主板正面 %}
*路由器主板背面*
{% asset_img 必虎DC-背面.jpg 路由器主板背面 %}
某小黄鱼上15元捡来的路由器，必虎路由器DC。

# 硬件配置
- SOC：MT7628NN
- FLASH：16MB
- RAM：64M
- 网口：3个
- 天线：2个
- USB：无
- 供电：5V1A，圆口
- 指示灯：蓝/紫色
- 特色：磁铁

硬件上没啥好说的，主板与外壳没有任何连接方便拆卸，直接拿来刷机。

# 刷机工作
原厂固件自动开启收费共享WIFI无法修改，而且已经绑定了其他人手机号，必须刷机。原厂固件默认开启SSH，但是无法登录，用编程器备份固件后刷breed然后刷第三方固件。

## 编程器
diybcq.com 设计出品的CH341A v1.5 （论坛有网店），上手相当不错，配合SOP8烧录夹（带转接板）顺利读写闪存。注意：我操作的闪存是Winbond 25Q128JVSQ，按照软件说明应该使用3.3V电压操作，但实测此时路由器会启动，结果是无法识别读写闪存。经测试，电压设置为2.5V可正常读写闪存。

## 转接板，夹子
没有热风枪 + 怕麻烦，遂尝试了免拆机方案，CH341A配合最普通的SOP8烧录夹和转接板就行了。在免拆机条件下由于外围电路会有干扰，所以不一定能够成功读写闪存。

## UART-USB？
原厂固件的UART也加密了，需要身份验证，无法直接操作。另外CH341A提供了TTL功能，不需要另外购买。

附上原厂固件启动日志：
<details>
<summary>点击展开查看</summary>

```
[BEGIN] 2021/3/4 21:11:07
[040±°08][0′0±0C0E]
                   DDR Ca&#47650;rati&#60320;DQS r&#18784;= 00°08788

&#1261;Boot ±.1.3 ¨Feb 2· 2017 - 14:21o39)

Boa2¤: &#6889;&#60000;&#1199;C DRAMo  64 MB
1&#255;t￥Α&#597;new interface driver usbfs
[    1.272000] usbcore: registered new interface driver hub
[    1.276000] usbcore: registered new device driver usb
[    1.280000] bhu_tc_attach : end, g_bhu_tc_salt=-1536776869
[    1.284000] Switching to clocksource MIPS
[    1.288000] NET: Registered protocol family 2
[    1.296000] TCP established hash table entries: 512 (order: 0, 4096 bytes)
[    1.300000] TCP bind hash table entries: 512 (order: -1, 2048 bytes)
[    1.308000] TCP: Hash tables configured (established 512 bind 512)
[    1.316000] TCP: reno registered
[    1.316000] UDP hash table entries: 256 (order: 0, 4096 bytes)
[    1.324000] UDP-Lite hash table entries: 256 (order: 0, 4096 bytes)
[    1.332000] NET: Registered protocol family 1
[    1.336000] MTK/Ralink EHCI/OHCI init.
[    1.340000] squashfs: version 4.0 (2009/01/31) Phillip Lougher
[    1.348000] jffs2: version 2.2. (NAND) (SUMMARY)  (LZMA) (RTIME) (CMODE_PRIORITY) (c) 2001-2006 Red Hat, Inc.
[    1.360000] msgmni has been set to 118
[    1.364000] io scheduler noop registered (default)
[    1.376000] Serial: 8250/16550 driver, 2 ports, IRQ sharing disabled
[    1.384000] serial8250: ttyS0 at MMIO 0x10000d00 (irq = 21) is a 16550A
[    1.392000] serial8250: ttyS1 at MMIO 0x10000c00 (irq = 20) is a 16550A
[    1.400000] led=43, on=1, off=5, blinks=1, rest=0, times=1
[    1.404000] Ralink gpio driver initialized
[    1.408000] flash manufacture id: ef, device id 40 18
[    1.416000] W25Q128BV(ef 40180000) (16384 Kbytes)
[    1.420000] mtd .name = raspi, .size = 0x01000000 (16M) .erasesize = 0x00010000 (64K) .numeraseregions = 0
[    1.428000] Creating 8 MTD partitions on "raspi":
[    1.432000] 0x000000000000-0x000001000000 : "ALL"
[    1.440000] 0x000000000000-0x000000040000 : "Bootloader"
[    1.448000] 0x000000040000-0x000000050000 : "Config"
[    1.452000] 0x000000050000-0x000000060000 : "Factory"
[    1.460000] 0x000000060000-0x000000de0000 : "firmware"
[    1.468000] 0x0000001a398a-0x000000de0000 : "rootfs"
[    1.472000] mtd: partition "rootfs" must either start or end on erase block boundary or be smaller than an erase block -- forcing read-only
[    1.488000] mtd: partition "rootfs_data" created automatically, ofs=0x940000, len=0x4a0000
[    1.496000] 0x000000940000-0x000000de0000 : "rootfs_data"
[    1.504000] 0x000000de0000-0x000000fe0000 : "user"
[    1.508000] 0x000000fe0000-0x000000ff0000 : "cfg"
[    1.516000] 0x000000ff0000-0x000001000000 : "oem"
[    1.524000] tun: Universal TUN/TAP device driver, 1.6
[    1.528000] tun: (C) 1999-2004 Max Krasnyansky <maxk@qualcomm.com>
[    1.532000] GMAC1_MAC_ADRH -- : 0x00008482
[    1.540000] GMAC1_MAC_ADRL -- : 0xf438c014
[    1.544000] Ralink APSoC Ethernet Driver Initilization. v3.1  512 rx/tx descriptors allocated, mtu = 1500!
[    1.552000] GMAC1_MAC_ADRH -- : 0x00008482
[    1.556000] GMAC1_MAC_ADRL -- : 0xf438c014
[    1.560000] PROC INIT OK!
[    1.564000] ehci_hcd: USB 2.0 'Enhanced' Host Controller (EHCI) Driver
[    1.572000] ehci-pci: EHCI PCI platform driver
[    1.576000] ehci-platform: EHCI generic platform driver
[    1.600000] ******MT7628 mtk phy
[    1.604000] *****run project phy.
[    1.616000] FM_OUT value: u4FmOut = 0(0x00000000)
[    1.628000] FM_OUT value: u4FmOut = 124(0x0000007C)
[    1.632000] FM detection done! loop = 1
[    1.644000] SR calibration value u1SrCalVal = 7
[    1.648000] *********Execute mt7628_phy_init!!
[    1.652000] ehci-platform ehci-platform: EHCI Host Controller
[    1.656000] ehci-platform ehci-platform: new USB bus registered, assigned bus number 1
[    1.664000] ehci-platform ehci-platform: irq 18, io mem 0x101c0000
[    1.684000] ehci-platform ehci-platform: USB 2.0 started, EHCI 1.00
[    1.688000] hub 1-0:1.0: USB hub found
[    1.692000] hub 1-0:1.0: 1 port detected
[    1.696000] ohci_hcd: USB 1.1 'Open' Host Controller (OHCI) Driver
[    1.724000] *********Execute mt7628_phy_init!!
[    1.728000] ohci-platform ohci-platform: Generic Platform OHCI Controller
[    1.736000] ohci-platform ohci-platform: new USB bus registered, assigned bus number 2
[    1.744000] ohci-platform ohci-platform: irq 18, io mem 0x101c1000
[    1.812000] hub 2-0:1.0: USB hub found
[    1.816000] hub 2-0:1.0: 1 port detected
[    1.820000] Ralink APSoC Hardware Watchdog Timer
[    1.824000] gre: GRE over IPv4 demultiplexor driver
[    1.832000] TCP: cubic registered
[    1.832000] NET: Registered protocol family 10
[    1.840000] NET: Registered protocol family 17
[    1.844000] Bridge firewalling registered
[    1.848000] 8021q: 802.1Q VLAN Support v1.8
[    1.852000] registered taskstats version 1
[    1.864000] VFS: Mounted root (squashfs filesystem) readonly on device 31:5.
[    1.872000] Freeing unused kernel memory: 220K (80389000 - 803c0000)
procd: Console i[    2.556000] Started WatchDog Timer.
s alive
procd: - watchdog -
[    3.904000] SCSI subsystem initialized
[    3.916000] usbcore: registered new interface driver usb-storage
procd: - preinit -
[    5.104000] jffs2: notice: (239) jffs2_build_xattr_subsystem: complete building xattr subsystem, 53 of xdatum (0 unchecked, 53 orphan) and 53 of xref (0 dead, 53 orphan) found.
[    5.120000] block: attempting to load /tmp/jffs_cfg/upper/etc/config/fstab
[    5.128000] block: unable to load configuration (fstab: Entry not found)
[    5.136000] block: attempting to load /tmp/jffs_cfg/etc/config/fstab
[    5.140000] block: unable to load configuration (fstab: Entry not found)
[    5.148000] block: attempting to load /etc/config/fstab
[    5.288000] block: extroot: not configured
jffs2 is ready
No jffs2 marker was found
[    5.452000] jffs2: notice: (236) jffs2_build_xattr_subsystem: complete building xattr subsystem, 53 of xdatum (0 unchecked, 53 orphan) and 53 of xref (0 dead, 53 orphan) found.
[    5.836000] block: attempting to load /tmp/jffs_cfg/upper/etc/config/fstab
[    5.844000] block: unable to load configuration (fstab: Entry not found)
[    5.848000] block: attempting to load /tmp/jffs_cfg/etc/config/fstab
[    5.856000] block: unable to load configuration (fstab: Entry not found)
[    5.864000] block: attempting to load /etc/config/fstab
[    5.872000] block: extroot: not configured
switching to overlay
procd: - early -
procd: - watchdog -
procd: - ubus -
procd: - init -
Please press Enter to activate this console.
[    7.052000] NTFS driver 2.1.30 [Flags: R/O MODULE].
[    7.092000] Initializing XFRM netlink socket
[    7.100000] NET: Registered protocol family 15
[    7.156000] nf_conntrack version 0.5.0 (954 buckets, 3816 max)
[    7.164000] ip6_tables: (C) 2000-2006 Netfilter Core Team
[    7.240000] Ebtables v2.0 registered
[    7.248000] ip_tables: (C) 2000-2006 Netfilter Core Team
[    7.252000] Type=Linux
[    7.276000] rdm_major = 253
[    7.300000] xt_time: kernel timezone is -0000
[    7.316000] PPP generic driver version 2.4.2
[    7.324000] NET: Registered protocol family 24
[    7.384000] bhu_stat_register_netlink: family id is 19
[    7.388000] BHUGenNetlink: bhu_gen_nl_register_netlink
[    7.392000] bhu_gen_nl_register_netlink: succeed to register bhu gen netlink. family id is 20
[    7.416000] BHUGenNetlink: bhu_gen_nl_register_netlink
[    7.420000] bhu_gen_nl_register_netlink: BHU gen netlink has been registered. Family id is 20
[    7.444000] FFFFFF84:FFFFFF82:FFFFFFF4:38:FFFFFFC0:14
[    7.448000] Raeth v3.1 (Tasklet,SkbRecycle)
[    7.452000]
[    7.452000] phy_tx_ring = 0x0328a000, tx_ring = 0xa328a000
[    7.460000]
[    7.460000] phy_rx_ring0 = 0x0328c000, rx_ring0 = 0xa328c000
[    7.484000] GMAC1_MAC_ADRH -- : 0x00008482
[    7.488000] GMAC1_MAC_ADRL -- : 0xf438c014
[    7.492000] RT305x_ESW: Link Status Changed
[    7.492000] [bhu_esw_link_status_change][2061]: stat[0], stat_curr[81808100]
[    7.492000] BHU ESW LAN link change
switch reg write offset=14, value=405555
switch reg write offset=50, value=2001
switch reg write offset=98, value=7f3f
switch reg write offset=e4, value=3f
switch reg write offset=40, value=1002
switch reg write offset=44, value=1001
switch reg write offset=48, value=1001
switch reg write offset=70, value=ffff417e
switch reg write offset=74, value=ffffffff
done.
Setting up networking on loopback device:
this file has been obseleted. please call "/sbin/block mount" directly
block: Fall back on RO mount. Permission denied.
block: /dev/mtdblock6 is already mounted
[    8.180000] jffs2: notice: (641) jffs2_build_xattr_subsystem: complete building xattr subsystem, 0 of xdatum (0 unchecked, 0 orphan) and 0 of xref (0 dead, 0 orphan) found.
/etc/rc.common: line 1: config_load: not found
block: /dev/mtdblock5 is already mounted
block: /dev/mtdblock6 is already mounted
block: /dev/mtdblock7 is already mounted
[    8.980000] device eth5T entered promiscuous mode
[    9.480000]
[    9.480000]
[    9.480000] === pAd = c078b000, size = 845504 ===
[    9.480000]
[    9.488000] <-- RTMPAllocTxRxRingMemory, Status=0, ErrorValue=0x
[    9.496000] <-- RTMPAllocAdapterBlock, Status=0
[    9.500000] RtmpChipOpsHook(492): Not support for HIF_MT yet!
[    9.508000] mt7628_init()-->
[    9.508000] mt7628_init(FW(8a00), HW(8a01), CHIPID(7628))
[    9.516000] e2.bin mt7628_init(1135)::(2), pChipCap->fw_len(63888)
[    9.520000] mt_bcn_buf_init(218): Not support for HIF_MT yet!
[    9.528000] <--mt7628_init()
[    9.528000] bhu_stainfo_register_callback: register callback successed
[    9.540000] BHUGenNetlink: bhu_gen_nl_register_netlink
[    9.544000] bhu_gen_nl_register_netlink: BHU gen netlink has been registered. Family id is 20
[    9.568000] TX_BCN DESC a29d8000 size = 320
[    9.572000] RX[0] DESC a29db000 size = 1024
[    9.576000] RX[1] DESC a29dc000 size = 1024
[    9.608000] cfg_mode=9
[    9.612000] cfg_mode=9
[    9.616000] wmode_band_equal(): Band Equal!
[    9.620000] AndesSendCmdMsg: Could not send in band command due to diable fRTMP_ADAPTER_MCU_SEND_IN_BAND_CMD
[    9.632000] APSDCapable[0]=1
[    9.636000] APSDCapable[1]=1
[    9.636000] APSDCapable[2]=1
[    9.640000] APSDCapable[3]=1
[    9.644000] APSDCapable[4]=1
[    9.644000] APSDCapable[5]=1
[    9.648000] APSDCapable[6]=1
[    9.652000] APSDCapable[7]=1
[    9.656000] APSDCapable[8]=1
[    9.656000] APSDCapable[9]=1
[    9.660000] APSDCapable[10]=1
[    9.664000] APSDCapable[11]=1
[    9.668000] APSDCapable[12]=1
[    9.668000] APSDCapable[13]=1
[    9.672000] APSDCapable[14]=1
[    9.676000] APSDCapable[15]=1
[    9.708000] load fw image from fw_header_image
[    9.712000] AndesMTLoadFwMethod1(2182)::pChipCap->fw_len(63888)
[    9.720000] FW Version:20151201
[    9.720000] FW Build Date:20151201183641
[    9.724000] CmdAddressLenReq:(ret = 0)
[    9.732000] CmdFwStartReq: override = 1, address = 1048576
[    9.736000] CmdStartDLRsp: WiFI FW Download Success
[    9.740000] MtAsicDMASchedulerInit(): DMA Scheduler Mode=0(LMAC)
[    9.748000] efuse_probe: efuse = 10000012
[    9.752000] RtmpChipOpsEepromHook::e2p_type=0, inf_Type=4
[    9.756000] RtmpEepromGetDefault::e2p_dafault=2
[    9.760000] RtmpChipOpsEepromHook: E2P type(2), E2pAccessMode = 2, E2P default = 2
[    9.768000] NVM is FLASH mode
[    9.772000] 1. Phy Mode = 14
[    9.936000] Country Region from e2p = ffff
[    9.940000] tssi_1_target_pwr_g_band = 36
[    9.944000] 2. Phy Mode = 14
[    9.944000] 3. Phy Mode = 14
[    9.948000] NICInitPwrPinCfg(11): Not support for HIF_MT yet!
[    9.956000] NICInitializeAsic(651): Not support rtmp_mac_sys_reset () for HIF_MT yet!
[    9.964000] mt_mac_init()-->
[    9.964000] MtAsicInitMac()-->
[    9.968000] mt7628_init_mac_cr()-->
[    9.972000] MtAsicSetMacMaxLen(1276): Set the Max RxPktLen=1024!
[    9.980000] <--mt_mac_init()
[    9.980000]         WTBL Segment 1 info:
[    9.984000]                 MemBaseAddr/FID:0x28000/0
[    9.988000]                 EntrySize/Cnt:32/128
[    9.992000]         WTBL Segment 2 info:
[    9.996000]                 MemBaseAddr/FID:0x40000/0
[   10.000000]                 EntrySize/Cnt:64/128
[   10.004000]         WTBL Segment 3 info:
[   10.008000]                 MemBaseAddr/FID:0x42000/64
[   10.012000]                 EntrySize/Cnt:64/128
[   10.012000]         WTBL Segment 4 info:
[   10.016000]                 MemBaseAddr/FID:0x44000/128
[   10.020000]                 EntrySize/Cnt:32/128
[   10.024000] AntCfgInit(2947): Not support for HIF_MT yet!
[   10.032000] MCS Set = ff ff 00 00 00
[   10.032000] MtAsicSetChBusyStat(861): Not support for HIF_MT yet!
[   10.540000] RT305x_ESW: Link Status Changed
[   10.540000] [bhu_esw_link_status_change][2061]: stat[81808100], stat_curr[a190a110]
[   10.540000] BHU ESW LAN link change
[   10.600000] CmdSlotTimeSet:(ret = 0)
[   12.696000] =====================================================
[   12.700000] Channel 1 : Dirty = 258, False CCA = 0, Busy Time = 5134, Skip Channel = FALSE
[   12.708000] Channel 2 : Dirty = 152, False CCA = 0, Busy Time = 6000, Skip Channel = FALSE
[   12.716000] Channel 3 : Dirty = 222, False CCA = 0, Busy Time = 7537, Skip Channel = FALSE
[   12.724000] Channel 4 : Dirty = 184, False CCA = 0, Busy Time = 7006, Skip Channel = FALSE
[   12.732000] Channel 5 : Dirty = 244, False CCA = 0, Busy Time = 8647, Skip Channel = FALSE
[   12.744000] Channel 6 : Dirty = 144, False CCA = 0, Busy Time = 12316, Skip Channel = FALSE
[   12.752000] Channel 7 : Dirty = 356, False CCA = 0, Busy Time = 5557, Skip Channel = FALSE
[   12.760000] Channel 8 : Dirty = 260, False CCA = 0, Busy Time = 5268, Skip Channel = FALSE
[   12.768000] Channel 9 : Dirty = 310, False CCA = 0, Busy Time = 15987, Skip Channel = FALSE
[   12.776000] Channel 10 : Dirty = 268, False CCA = 0, Busy Time = 11282, Skip Channel = FALSE
[   12.784000] Channel 11 : Dirty = 490, False CCA = 0, Busy Time = 10399, Skip Channel = FALSE
[   12.792000] Channel 12 : Dirty = 254, False CCA = 0, Busy Time = 6015, Skip Channel = TRUE
[   12.800000] Channel 13 : Dirty = 192, False CCA = 0, Busy Time = 3918, Skip Channel = TRUE
[   12.808000] =====================================================
[   12.816000] [PMF]ap_pmf_init:: apidx=0, MFPC=0, MFPR=0, SHA256=0
[   12.824000] [PMF]ap_pmf_init:: apidx=1, MFPC=0, MFPR=0, SHA256=0
[   12.828000] [PMF]ap_pmf_init:: apidx=2, MFPC=0, MFPR=0, SHA256=0
[   12.836000] [PMF]ap_pmf_init:: apidx=3, MFPC=0, MFPR=0, SHA256=0
[   12.840000] MtAsicSetRalinkBurstMode(3047): Not support for HIF_MT yet!
[   12.848000] MtAsicSetPiggyBack(796): Not support for HIF_MT yet!
[   12.876000] reload DPD from flash , 0x9F = [c600] doReload bit7[0]
[   12.880000] CmdLoadDPDDataFromFlash: Channel = 6, DoReload = 0
[   12.888000] MtAsicSetTxPreamble(3026): Not support for HIF_MT yet!
[   12.892000] The 4-BSSID mode is enabled, the BSSID byte5 MUST be the multiple of 4
[   12.900000] MtAsicSetPreTbtt(): bss_idx=0, PreTBTT timeout = 0xf0
[   12.908000] Main bssid = 84:82:f4:38:c0:15
[   12.912000] <==== rt28xx_init, Status=0
[   12.920000] BHUGenNetlink: bhu_gen_nl_register_netlink
[   12.924000] bhu_gen_nl_register_netlink: BHU gen netlink has been registered. Family id is 20
[   12.948000] BHUGenNetlink: bhu_gen_nl_register_netlink
[   12.952000] bhu_gen_nl_register_netlink: BHU gen netlink has been registered. Family id is 20
[   12.972000] BHUGenNetlink: bhu_gen_nl_register_netlink
[   12.976000] bhu_gen_nl_register_netlink: BHU gen netlink has been registered. Family id is 20
[   12.984000] @@@ ed_monitor_exit : ===>
[   12.988000] @@@ ed_monitor_exit : <===
[   12.992000] mt7628_set_ed_cca: TURN OFF EDCCA  mac 0x10618 = 0xd7083f0f
[   13.000000] WiFi Startup Cost (wlan0): 3.432s
[   15.496000] led=43, on=1, off=5, blinks=1, rest=0, times=1
[main] >>> Init dispather success!
BHU Software Version: AP902P07V1.6.0Build798_TU 2017-11-03-09:13 Revision: 798
procd: - init complete -
kill: you need to specify whom to kill
Mongoose web server v.3.9 started on port(s) 80 with web root [/usr/share/www]
main, 36, svn:798, version:10015, time:[Thu Nov  2 20:56:08 CST 2017]
wait for pa data initpa_data_init done[   19.788000] bhuhttp_L2_init: register nl family ok
[   19.796000] user space pid:799
[http_url_start_timer][269] http url age timer start..
[   20.036000] cfg_mode=9
[   20.036000] wmode_band_equal(): Band Equal!
[   20.044000] AddTxSType: already registered TxSType (PID = 32, Format = 0
kmod: module is not loaded
[   20.120000] cfg_mode=9
[   20.124000] wmode_band_equal(): Band Equal!
[   20.128000] AddTxSType: already registered TxSType (PID = 32, Format = 0
[   20.164000] cfg_mode=9
[   20.164000] wmode_band_equal(): Band Equal!
[   20.168000] AddTxSType: already registered TxSType (PID = 32, Format = 0
[   20.216000] MtAsicSetPreTbtt(): bss_idx=0, PreTBTT timeout = 0x0
[   20.224000] MtAsicSetPiggyBack(796): Not support for HIF_MT yet!
[   20.228000] [PMF]ap_pmf_init:: apidx=0, MFPC=0, MFPR=0, SHA256=0
[   20.236000] [PMF]ap_pmf_init:: apidx=1, MFPC=0, MFPR=0, SHA256=0
[   20.240000] [PMF]ap_pmf_init:: apidx=2, MFPC=0, MFPR=0, SHA256=0
[   20.248000] [PMF]ap_pmf_init:: apidx=3, MFPC=0, MFPR=0, SHA256=0
[   20.252000] MtAsicSetRalinkBurstMode(3047): Not support for HIF_MT yet!
[   20.260000] MtAsicSetPiggyBack(796): Not support for HIF_MT yet!
[   20.288000] reload DPD from flash , 0x9F = [c600] doReload bit7[0]
[   20.292000] CmdLoadDPDDataFromFlash: Channel = 6, DoReload = 0
[   20.304000] MtAsicSetTxPreamble(3026): Not support for HIF_MT yet!
[   20.308000] AddTxSType: already registered TxSType (PID = 32, Format = 0
[   20.316000] The 4-BSSID mode is enabled, the BSSID byte5 MUST be the multiple of 4
[   20.324000] AddTxSType: already registered TxSType (PID = 6, Format = 0
[   20.332000] AddTxSType: already registered TxSType (PID = 8, Format = 0
[   20.336000] MtAsicSetPreTbtt(): bss_idx=0, PreTBTT timeout = 0xf0
[   20.344000] Main bssid = 84:82:f4:38:c0:15
[   20.376000] MtAsicSetPreTbtt(): bss_idx=0, PreTBTT timeout = 0x0
[   20.380000] MtAsicSetPiggyBack(796): Not support for HIF_MT yet!
[   20.388000] [PMF]ap_pmf_init:: apidx=0, MFPC=0, MFPR=0, SHA256=0
[   20.392000] [PMF]ap_pmf_init:: apidx=1, MFPC=0, MFPR=0, SHA256=0
[   20.400000] [PMF]ap_pmf_init:: apidx=2, MFPC=0, MFPR=0, SHA256=0
[   20.404000] [PMF]ap_pmf_init:: apidx=3, MFPC=0, MFPR=0, SHA256=0
[   20.412000] MtAsicSetRalinkBurstMode(3047): Not support for HIF_MT yet!
[   20.416000] MtAsicSetPiggyBack(796): Not support for HIF_MT yet!
[   20.456000] reload DPD from flash , 0x9F = [c600] doReload bit7[0]
[   20.460000] CmdLoadDPDDataFromFlash: Channel = 6, DoReload = 0
[   20.468000] MtAsicSetTxPreamble(3026): Not support for HIF_MT yet!
[   20.472000] AddTxSType: already registered TxSType (PID = 32, Format = 0
[   20.480000] The 4-BSSID mode is enabled, the BSSID byte5 MUST be the multiple of 4
[   20.488000] AddTxSType: already registered TxSType (PID = 6, Format = 0
[   20.496000] AddTxSType: already registered TxSType (PID = 8, Format = 0
[   20.500000] MtAsicSetPreTbtt(): bss_idx=0, PreTBTT timeout = 0xf0
[   20.508000] Main bssid = 84:82:f4:38:c0:15
[   20.572000] device eth0 entered promiscuous mode
[   20.580000] device wlan0 entered promiscuous mode
[   20.592000] device wlan2 entered promiscuous mode
[   20.600000] device wlan3 entered promiscuous mode
killall: dropbear: no process killed
kill: you need to specify whom to kill
[   21.972000] MtAsicSetPreTbtt(): bss_idx=0, PreTBTT timeout = 0x0
[   21.980000] MtAsicSetPiggyBack(796): Not support for HIF_MT yet!
[   21.984000] [PMF]ap_pmf_init:: apidx=0, MFPC=0, MFPR=0, SHA256=0
[   21.992000] [PMF]ap_pmf_init:: apidx=1, MFPC=0, MFPR=0, SHA256=0
[   21.996000] [PMF]ap_pmf_init:: apidx=2, MFPC=0, MFPR=0, SHA256=0
[   22.004000] [PMF]ap_pmf_init:: apidx=3, MFPC=0, MFPR=0, SHA256=0
[   22.012000] MtAsicSetRalinkBurstMode(3047): Not support for HIF_MT yet!
[   22.016000] MtAsicSetPiggyBack(796): Not support for HIF_MT yet!
[   22.044000] reload DPD from flash , 0x9F = [c600] doReload bit7[0]
[   22.052000] CmdLoadDPDDataFromFlash: Channel = 6, DoReload = 0
[   22.056000] MtAsicSetTxPreamble(3026): Not support for HIF_MT yet!
[   22.064000] AddTxSType: already registered TxSType (PID = 32, Format = 0
[   22.072000] The 4-BSSID mode is enabled, the BSSID byte5 MUST be the multiple of 4
[   22.080000] AddTxSType: already registered TxSType (PID = 6, Format = 0
[   22.084000] AddTxSType: already registered TxSType (PID = 8, Format = 0
[   22.092000] MtAsicSetPreTbtt(): bss_idx=0, PreTBTa￠￥μ&#189;&#1425;= 0xf0
[   22.096000] Main bssid = 84:82:f4:38:c0:15
[   22.104000] MtAsicSetPreTbtt(): bss_idx=0, PreTBTT timeout = 0x0
[   22.112000] MtAsicSetPiggyBack(796): Not support for HIF_MT yet!
[   22.116000] [PMF]ap_pmf_init:: apidx=0, MFPC=0, MFPR=0, SHA256=0
[   22.124000] [PMF]ap_pmf_init:: apidx=1, MFPC=0, MFPR=0, SHA256=0
[   22.128000] [PMF]ap_pmf_init:: apidx=2, MFPC=0, MFPR=0, SHA256=0
[   22.136000] [PMF]ap_pmf_init:: apidx=3, MFPC=0, MFPR=0, SHA256=0
[   22.144000] MtAsicSetRalinkBurstMode(3047): Not support for HIF_MT yet!
[   22.148000] MtAsicSetPiggyBack(796): Not support for HIF_MT yet!
[   22.176000] reload DPD from flash , 0x9F = [c600] doReload bit7[0]
[   22.180000] CmdLoadDPDDataFromFlash: Channel = 6, DoReload = 0
[   22.188000] MtAsicSetTxPreamble(3026): Not support for HIF_MT yet!
[   22.196000] AddTxSType: already registered TxSType (PID = 32, Format = 0
[   22.200000] The 4-BSSID mode is enabled, the BSSID byte5 MUST be the multiple of 4
[   22.208000] AddTxSType: already registered TxSType (PID = 6, Format = 0
[   22.216000] AddTxSType: already registered TxSType (PID = 8, Format = 0
[   22.224000] MtAsicSetPreTbtt(): bss_idx=0, PreTBTT timeout = 0xf0
[   22.228000] Main bssid = 84:82:f4:38:c0:15
[   22.244000] MtAsicSetPreTbtt(): bss_idx=0, PreTBTT timeout = 0x0
[   22.252000] MtAsicSetPiggyBack(796): Not support for HIF_MT yet!
[   22.256000] [PMF]ap_pmf_init:: apidx=0, MFPC=0, MFPR=0, SHA256=0
[   22.264000] [PMF]ap_pmf_init:: apidx=1, MFPC=0, MFPR=0, SHA256=0
[   22.268000] [PMF]ap_pmf_init:: apidx=2, MFPC=0, MFPR=0, SHA256=0
[   22.276000] [PMF]ap_pmf_init:: apidx=3, MFPC=0, MFPR=0, SHA256=0
[   22.280000] MtAsicSetRalinkBurstMode(3047): Not support for HIF_MT yet!
[   22.288000] MtAsicSetPiggyBack(796): Not support for HIF_MT yet!
[   22.316000] reload DPD from flash , 0x9F = [c600] doReload bit7[0]
[   22.324000] CmdLoadDPDDataFromFlash: Channel = 6, DoReload = 0
[   22.328000] MtAsicSetTxPreamble(3026): Not support for HIF_MT yet!
[   22.336000] AddTxSType: already registered TxSType (PID = 32, Format = 0
[   22.344000] The 4-BSSID mode is enabled, the BSSID byte5 MUST be the multiple of 4
[   22.352000] AddTxSType: already registered TxSType (PID = 6, Format = 0
[   22.356000] AddTxSType: already registered TxSType (PID = 8, Format = 0
[   22.364000] MtAsicSetPreTbtt(): bss_idx=0, PreTBTT timeout = 0xf0
[   22.372000] Main bssid = 84:82:f4:38:c0:15
[   23.416000] MtAsicSetPreTbtt(): bss_idx=0, PreTBTT timeout = 0x0
[   23.424000] MtAsicSetPiggyBack(796): Not support for HIF_MT yet!
[   23.428000] [PMF]ap_pmf_init:: apidx=0, MFPC=0, MFPR=0, SHA256=0
[   23.436000] [PMF]ap_pmf_init:: apidx=1, MFPC=0, MFPR=0, SHA256=0
[   23.440000] [PMF]ap_pmf_init:: apidx=2, MFPC=0, MFPR=0, SHA256=0
[   23.448000] [PMF]ap_pmf_init:: apidx=3, MFPC=0, MFPR=0, SHA256=0
[   23.452000] MtAsicSetRalinkBurstMode(3047): Not support for HIF_MT yet!
[   23.460000] MtAsicSetPiggyBack(796): Not support for HIF_MT yet!
[   23.488000] reload DPD from flash , 0x9F = [c600] doReload bit7[0]
[   23.492000] CmdLoadDPDDataFromFlash: Channel = 6, DoReload = 0
[   23.500000] MtAsicSetTxPreamble(3026): Not support for HIF_MT yet!
[   23.504000] AddTxSType: already registered TxSType (PID = 32, Format = 0
[   23.512000] The 4-BSSID mode is enabled, the BSSID byte5 MUST be the multiple of 4
[   23.520000] AddTxSType: already registered TxSType (PID = 6, Format = 0
[   23.528000] AddTxSType: already registered TxSType (PID = 8, Format = 0
[   23.532000] MtAsicSetPreTbtt(): bss_idx=0, PreTBTT timeout = 0xf0
[   23.540000] Main bssid = 84:82:f4:38:c0:15
[   23.560000] MtAsicSetPreTbtt(): bss_idx=0, PreTBTT timeout = 0x0
[   23.564000] MtAsicSetPiggyBack(796): Not support for HIF_MT yet!
[   23.572000] [PMF]ap_pmf_init:: apidx=0, MFPC=0, MFPR=0, SHA256=0
[   23.576000] [PMF]ap_pmf_init:: apidx=1, MFPC=0, MFPR=0, SHA256=0
[   23.584000] [PMF]ap_pmf_init:: apidx=2, MFPC=0, MFPR=0, SHA256=0
[   23.588000] [PMF]ap_pmf_init:: apidx=3, MFPC=0, MFPR=0, SHA256=0
[   23.596000] MtAsicSetRalinkBurstMode(3047): Not support for HIF_MT yet!
[   23.600000] MtAsicSetPiggyBack(796): Not support for HIF_MT yet!
[   23.628000] reload DPD from flash , 0x9F = [c600] doReload bit7[0]
[   23.636000] CmdLoadDPDDataFromFlash: Channel = 6, DoReload = 0
[   23.640000] MtAsicSetTxPreamble(3026): Not support for HIF_MT yet!
[   23.648000] AddTxSType: already registered TxSType (PID = 32, Format = 0
[   23.652000] The 4-BSSID mode is enabled, the BSSID byte5 MUST be the multiple of 4
[   23.660000] AddTxSType: already registered TxSType (PID = 6, Format = 0
[   23.668000] AddTxSType: already registered TxSType (PID = 8, Format = 0
[   23.676000] MtAsicSetPreTbtt(): bss_idx=0, PreTBTT timeout = 0xf0
[   23.680000] Main bssid = 84:82:f4:38:c0:15
[   24.724000] MtAsicSetPreTbtt(): bss_idx=0, PreTBTT timeout = 0x0
[   24.732000] MtAsicSetPiggyBack(796): Not support for HIF_MT yet!
[   24.736000] [PMF]ap_pmf_init:: apidx=0, MFPC=0, MFPR=0, SHA256=0
[   24.744000] [PMF]ap_pmf_init:: apidx=1, MFPC=0, MFPR=0, SHA256=0
[   24.748000] [PMF]ap_pmf_init:: apidx=2, MFPC=0, MFPR=0, SHA256=0
[   24.756000] [PMF]ap_pmf_init:: apidx=3, MFPC=0, MFPR=0, SHA256=0
[   24.760000] MtAsicSetRalinkBurstMode(3047): Not support for HIF_MT yet!
[   24.768000] MtAsicSetPiggyBack(796): Not support for HIF_MT yet!
[   24.796000] reload DPD from flash , 0x9F = [c600] doReload bit7[0]
[   24.800000] CmdLoadDPDDataFromFlash: Channel = 6, DoReload = 0
[   24.808000] MtAsicSetTxPreamble(3026): Not support for HIF_MT yet!
[   24.812000] AddTxSType: already registered TxSType (PID = 32, Format = 0
[   24.820000] The 4-BSSID mode is enabled, the BSSID byte5 MUST be the multiple of 4
[   24.828000] AddTxSType: already registered TxSType (PID = 6, Format = 0
[   24.836000] AddTxSType: already registered TxSType (PID = 8, Format = 0
[   24.840000] MtAsicSetPreTbtt(): bss_idx=0, PreTBTT timeout = 0xf0
[   24.848000] Main bssid = 84:82:f4:38:c0:15
[   24.868000] MtAsicSetPreTbtt(): bss_idx=0, PreTBTT timeout = 0x0
[   24.872000] MtAsicSetPiggyBack(796): Not support for HIF_MT yet!
[   24.880000] [PMF]ap_pmf_init:: apidx=0, MFPC=0, MFPR=0, SHA256=0
[   24.884000] [PMF]ap_pmf_init:: apidx=1, MFPC=0, MFPR=0, SHA256=0
[   24.892000] [PMF]ap_pmf_init:: apidx=2, MFPC=0, MFPR=0, SHA256=0
[   24.896000] [PMF]ap_pmf_init:: apidx=3, MFPC=0, MFPR=0, SHA256=0
[   24.904000] MtAsicSetRalinkBurstMode(3047): Not support for HIF_MT yet!
[   24.908000] MtAsicSetPiggyBack(796): Not support for HIF_MT yet!
[   24.936000] reload DPD from flash , 0x9F = [c600] doReload bit7[0]
[   24.944000] CmdLoadDPDDataFromFlash: Channel = 6, DoReload = 0
[   24.948000] MtAsicSetTxPreamble(3026): Not support for HIF_MT yet!
[   24.956000] AddTxSType: already registered TxSType (PID = 32, Format = 0
[   24.964000] The 4-BSSID mode is enabled, the BSSID byte5 MUST be the multiple of 4
[   24.972000] AddTxSType: already registered TxSType (PID = 6, Format = 0
[   24.976000] AddTxSType: already registered TxSType (PID = 8, Format = 0
[   24.984000] MtAsicSetPreTbtt(): bss_idx=0, PreTBTT timeout = 0xf0
[   24.988000] Main bssid = 84:82:f4:38:c0:15
iptables: No chain/target/match by that name.
MASQUERADE  all opt -- in * out eth1  0.0.0.0/0  -> 0.0.0.0/0  [24 bytes of unknown target data]
iptables: No chain/target/match by that name.
udhcpc (v1.22.1) started
route: SIOCDELRT: No such process
iptables: No chain/target/match by that name.
iptables: No chain/target/match by that name.
[   27.408000] br-lan: port 2(wlan0) entered forwarding state
[   27.412000] br-lan: port 2(wlan0) entered forwarding state
[   27.420000] br-lan: port 1(eth0) entered forwarding state
[   27.424000] br-lan: port 1(eth0) entered forwarding state
iptables: No chain/target/match by that name.
iptables: No chain/target/match by that name.
iptables: No chain/target/match by that name.
iptables: No chain/target/match by that name.
iptables: No chain/target/match by that name.
iptables: No chain/target/match by that name.
MASQUERADE  all opt -- in * out [   27.688000] The 4-BSSID mode is enabled, the BSSID byte5 MUST be the multiple of 4
eth1  0.0.0.0/0 [   27.700000] MtAsicSetPreTbtt(): bss_idx=0, PreTBTT timeout = 0x0
-> 0.0.0.0/0  [[   27.704000] MtAsicSetPiggyBack(796): Not support for HIF_MT yet!
24 bytes of unknown target data]
MASQUERADE  all opt -- in * out eth1  192.168.62.0/24  -> 0.0.0.0/0  [24 bytes of unknown target data]
[   27.936000] bhu_tc_send_q_tx: send skb failed, err=2
[   28.032000] bhu_tc_send_q_tx: send skb failed, err=2
[   28.240000] tx_kickout_fail_count = 0
[   28.244000] tx_timeout_fail_count = 0
[   28.244000] rx_receive_fail_count = 0
[   28.248000] alloc_cmd_msg = 207
[   28.252000] free_cmd_msg = 207
[   28.260000] br-lan: port 2(wlan0) entered disabled state
iptables: No chain/target/match by that name.
[   28.308000] TX_BCN DESC a29d8000 size = 320
[   28.312000] RX[0] DESC a29db000 size = 1024
[   28.316000] RX[1] DESC a29dc000 size = 1024
[   28.332000] cfg_mode=9
[   28.332000] cfg_mode=9
[   28.336000] wmode_band_equal(): Band Equal!
[   28.340000] AndesSendCmdMsg: Could not send in band command due to diable fRTMP_ADAPTER_MCU_SEND_IN_BAND_CMD
[   28.352000] APSDCapable[0]=1
[   28.356000] APSDCapable[1]=1
[   28.360000] APSDCapable[2]=1
[   28.360000] APSDCapable[3]=1
[   28.364000] APSDCapable[4]=1
[   28.368000] APSDCapable[5]=1
[   28.368000] APSDCapable[6]=1
[   28.372000] APSDCapable[7]=1
[   28.376000] APSDCapable[8]=1
[   28.380000] APSDCapable[9]=1
[   28.380000] APSDCapable[10]=1
[   28.384000] APSDCapable[11]=1
[   28.388000] APSDCapable[12]=1
[   28.392000] APSDCapable[13]=1
[   28.392000] APSDCapable[14]=1
[   28.396000] APSDCapable[15]=1
[   28.428000] load fw image from fw_header_image
[   28.432000] AndesMTLoadFwMethod1(2182)::pChipCap->fw_len(63888)
[   28.440000] FW Version:20151201
[   28.444000] FW Build Date:20151201183641
[   28.448000] CmdReStartDLRsp: WiFI FW Download Success
[   28.452000] CmdAddressLenReq:(ret = 0)
[   28.456000] CmdFwStartReq: override = 1, address = 1048576
[   28.464000] CmdStartDLRsp: WiFI FW Download Success
[   28.468000] MtAsicDMASchedulerInit(): DMA Scheduler Mode=0(LMAC)
[   28.472000] efuse_probe: efuse = 10000012
[   28.476000] RtmpChipOpsEepromHook::e2p_type=2, inf_Type=4
[   28.484000] RtmpEepromGetDefault::e2p_dafault=2
[   28.488000] RtmpChipOpsEepromHook: E2P type(2), E2pAccessMode = 2, E2P default = 2
[   28.496000] NVM is FLASH mode
[   28.500000] 1. Phy Mode = 14
[   28.660000] Country Region from e2p = ffff
[   28.668000] tssi_1_target_pwr_g_band = 36
[   28.672000] 2. Phy Mode = 14
[   28.672000] 3. Phy Mode = 14
[   28.676000] NICInitPwrPinCfg(11): Not support for HIF_MT yet!
[   28.680000] NICInitializeAsic(651): Not support rtmp_mac_sys_reset () for HIF_MT yet!
[   28.688000] mt_mac_init()-->
[   28.692000] MtAsicInitMac()-->
[   28.696000] mt7628_init_mac_cr()-->
[   28.700000] MtAsicSetMacMaxLen(1276): Set the Max RxPktLen=1024!
[   28.704000] <--mt_mac_init()
[   28.708000]         WTBL Segment 1 info:
[   28.712000]                 MemBaseAddr/FID:0x28000/0
[   28.716000]                 EntrySize/Cnt:32/128
[   28.720000]         WTBL Segment 2 info:
[   28.724000]                 MemBaseAddr/FID:0x40000/0
[   28.728000]                 EntrySize/Cnt:64/128
[   28.732000]         WTBL Segment 3 info:
[   28.732000]                 MemBaseAddr/FID:0x42000/64
[   28.736000]                 EntrySize/Cnt:64/128
[   28.740000]         WTBL Segment 4 info:
[   28.744000]                 MemBaseAddr/FID:0x44000/128
[   28.748000]                 EntrySize/Cnt:32/128
[   28.752000] AntCfgInit(2947): Not support for HIF_MT yet!
[   28.756000] MCS Set = ff ff 00 00 00
[   28.760000] MtAsicSetChBusyStat(861): Not support for HIF_MT yet!
[   31.416000] =====================================================
[   31.420000] Channel 1 : Dirty = 254, False CCA = 0, Busy Time = 4969, Skip Channel = FALSE
[   31.428000] Channel 2 : Dirty = 168, False CCA = 0, Busy Time = 4130, Skip Channel = FALSE
[   31.436000] Channel 3 : Dirty = 208, False CCA = 0, Busy Time = 3210, Skip Channel = FALSE
[   31.444000] Channel 4 : Dirty = 250, False CCA = 0, Busy Time = 3656, Skip Channel = FALSE
[   31.452000] Channel 5 : Dirty = 280, False CCA = 0, Busy Time = 8862, Skip Channel = FALSE
[   31.464000] Channel 6 : Dirty = 218, False CCA = 0, Busy Time = 6476, Skip Channel = FALSE
[   31.472000] Channel 7 : Dirty = 432, False CCA = 0, Busy Time = 6117, Skip Channel = FALSE
[   31.480000] Channel 8 : Dirty = 336, False CCA = 0, Busy Time = 5338, Skip Channel = FALSE
[   31.488000] Channel 9 : Dirty = 366, False CCA = 0, Busy Time = 9826, Skip Channel = FALSE
[   31.496000] Channel 10 : Dirty = 324, False CCA = 0, Busy Time = 4860, Skip Channel = FALSE
[   31.504000] Channel 11 : Dirty = 598, False CCA = 0, Busy Time = 9220, Skip Channel = FALSE
[   31.512000] Channel 12 : Dirty = 248, False CCA = 0, Busy Time = 6747, Skip Channel = TRUE
[   31.520000] Channel 13 : Dirty = 216, False CCA = 0, Busy Time = 7909, Skip Channel = TRUE
[   31.528000] =====================================================
[   31.536000] [PMF]ap_pmf_init:: apidx=0, MFPC=0, MFPR=0, SHA256=0
[   31.544000] [PMF]ap_pmf_init:: apidx=1, MFPC=0, MFPR=0, SHA256=0
[   31.548000] [PMF]ap_pmf_init:: apidx=2, MFPC=0, MFPR=0, SHA256=0
[   31.556000] [PMF]ap_pmf_init:: apidx=3, MFPC=0, MFPR=0, SHA256=0
[   31.560000] MtAsicSetRalinkBurstMode(3047): Not support for HIF_MT yet!
[   31.568000] MtAsicSetPiggyBack(796): Not support for HIF_MT yet!
[   31.596000] reload DPD from flash , 0x9F = [c600] doReload bit7[0]
[   31.600000] CmdLoadDPDDataFromFlash: Channel = 2, DoReload = 0
[   31.608000] MtAsicSetTxPreamble(3026): Not support for HIF_MT yet!
[   31.616000] The 4-BSSID mode is enabled, the BSSID byte5 MUST be the multiple of 4
[   31.624000] MtAsicSetPreTbtt(): bss_idx=0, PreTBTT timeout = 0xf0
[   31.628000] Main bssid = 84:82:f4:38:c0:15
[   31.632000] <==== rt28xx_init, Status=0
[   31.636000] @@@ ed_monitor_exit : ===>
[   31.640000] @@@ ed_monitor_exit : <===
[   31.644000] mt7628_set_ed_cca: TURN OFF EDCCA  mac 0x10618 = 0xd7083f0f
[   31.652000] WiFi Startup Cost (wlan0): 3.344s
[   31.656000] br-lan: port 2(wlan0) entered forwarding state
[   31.660000] br-lan: port 2(wlan0) entered forwarding state
iptables: No chain/target/match by that name.
serverctl: BHU Tunnel probably not started (Error: No such file or directory)
serverctl: BHU Tunnel probably not started (Error: No such file or directory)
serverctl: BHU Tunnel probably not started (Error: No such file or directory)
serverctl: BHU Tunnel probably not started (Error: No such file or directory)
serverctl: BHU Tunnel probably not started (Error: No such file or directory)
serverctl: BHU Tunnel probably not started (Error: No such file or directory)
serverctl: BHU Tunnel probably not started (Error: No such file or directory)
serverctl: BHU Tunnel probably not started (Error: No such file or directory)
serverctl: BHU Tunnel probably not started (Error: No such file or directory)
serverctl: BHU Tunnel probably not started (Error: Connection refused)
serverctl: BHU Tunnel probably not started (Error: Connection refused)
serverctl: BHU Tunnel probably not started (Error: Connection refused)
serverctl: BHU Tunnel probably not started (Error: Connection refused)
serverctl: BHU Tunnel probably not started (Error: Connection refused)
serverctl: BHU Tunnel probably not started (Error: Connection refused)
serverctl: BHU Tunnel probably not started (Error: Connection refused)
serverctl: BHU Tunnel probably not started (Error: Connection refused)
serverctl: BHU Tunnel probably not started (Error: Connection refused)
serverctl: BHU Tunnel probably not started (Error: Connection refused)
serverctl: BHU Tunnel probably not started (Error: Connection refused)
serverctl: BHU Tunnel probably not started (Error: Connection refused)
serverctl: BHU Tunnel probably not started (Error: Connection refused)
serverctl: BHU Tunnel probably not started (Error: Connection refused)
serverctl: BHU Tunnel probably not started (Error: Connection refused)
serverctl: BHU Tunnel probably not started (Error: Connection refused)
[   33.928000] led=43, on=0, off=1, blinks=0, rest=0, times=0
[   33.984000] led=42, on=2, off=5, blinks=1, rest=0, times=1
wandetect: eth1 is running
wandetect: start pppoe_discovery_main thread ok.
wandetect: start dhcp detect thread ok.
udhcpc (v1.22.1) started
wlan_ol_sta_online_proc: add sta 74:97:81:ab:06:dd, count 1
assoced:74:97:81:ab:06:dd
[   35.040000] led=43, on=2, off=5, blinks=1, rest=0, times=1
wandetect: Timeout waiting for PADO packets
wandetect: Timeout waiting for PADO packets
wandetect: Timeout waiting for PADO packets
wandetect: Timeout waiting for PADO packets
No lease, failing
wandetect: Timeout waiting for PADO packets
wandetect: Timeout waiting for PADO packets
wandetect: Timeout waiting for PADO packets
wandetect: Timeout waiting for PADO packets
wandetect: Timeout waiting for PADO packets
wandetect: Timeout waiting for PADO packets
wandetect: Timeout waiting for PADO packets
wandetect:
HOSTNAME login:

[END] 2021/3/4 21:13:04
```
</details>

## breed
使用恩山论坛的breed-mt7688-reset38.bin。不能正确识别内存大小，此外没什么问题。这个路由器内存为一片EM68B16CWQH-25H，64MB，breed中识别为128MB，可以在编译openwrt前修改dts设置内存为64MB。

## 刷回原厂固件
breed中刷入一次刚才导出的编程器固件，此步骤作用是恢复mac地址与eeprom。

### openwrt编译
使用lean/lede代码，选择MT76X8，GL.iNet VIXMINI配置。GL.iNet VIXMINI配置为MT7628NN 8+64，无USB，与必虎mini接近： https://www.gl-inet.cn/products/vixmini/

#### 修改 lede/target/linux/ramips/mt76x8/base-files/etc/board.d/02_network
```
glinet,microuter-n300|\
glinet,vixmini)
	ucidef_add_switch "switch0" \
		"0:lan" "6@eth0"
	;;
```
修改为
```
glinet,microuter-n300|\
glinet,vixmini)
	ucidef_add_switch "switch0" \
		"4:lan" "2:lan" "0:wan" "6@eth0"
	;;
```
因为vixmini只有一个网口，我们需要自行添加2个网口，注意对应交换机的2和4。注意MT7628只有一个网卡（interface），内置5口交换机，通过VLAN划分WAN与LAN，WAN一般对应0号口，LAN需要自己测试，本例中为2和4。

#### 修改lede/target/linux/ramips/image/mt76x8.mk
```
define Device/glinet_vixmini
  IMAGE_SIZE := 7872k
  DEVICE_VENDOR := GL.iNet
  DEVICE_MODEL := VIXMINI
  SUPPORTED_DEVICES += vixmini
endef
TARGET_DEVICES += glinet_vixmini
```
修改为
```
define Device/glinet_vixmini
  IMAGE_SIZE := 16064k
  DEVICE_VENDOR := GL.iNet
  DEVICE_MODEL := VIXMINI
  SUPPORTED_DEVICES += vixmini
endef
TARGET_DEVICES += glinet_vixmini
```
VIXMINI闪存8M，不如此修改无法生成8M~16M大小的固件。

#### 修改lede/target/linux/ramips/dts/mt7628an_glinet_vixmini.dts
```
// SPDX-License-Identifier: GPL-2.0-or-later OR MIT
/dts-v1/;

#include "mt7628an_glinet_vixmini_microuter.dtsi"

/ {
	compatible = "glinet,vixmini", "mediatek,mt7628an-soc";
	model = "GL.iNet VIXMINI";

	memory@0 {
		device_type = "memory";
		reg = <0x0 0x4000000>;
	};
};

&led_power_blue {
	label = "vixmini:blue:power";
};

&led_wlan_white {
	label = "vixmini:white:wlan";
};

&firmware_part {
		reg = <0x50000 0xfb0000>;
};
```
其中，
```
memory@0 {
	device_type = "memory";
	reg = <0x0 0x4000000>;
	};
```
这一段是自己加的，本来内存容量应该由BootLoader获取传递给openwrt，不过由于breed识别错误，所以自己手动指定参数。

经过以上修改后就可以编译固件了，然而由于MT7628开源WIFI驱动贫弱的表现，你很可能会不满意，如此可以继续阅读：

## 刷GL-iNet GL-MT300N-V2固件
在GL-iNet官网下载:http://download.gl-inet.com/firmware/

GL-iNet应该是主打外贸的国内路由器厂商，路由器固件均基于openwrt，包含MTK私有驱动，WIFI表现良好，实测穿2道非承重墙非常轻松。

GL-MT300N-V2固件初始WIFI密码goodlife，管理页面登录密码admin。首次设置需要通过WIFI连接，通过SSH访问修改`/etc/config/network`，将vlan为1的交换机端口修改成以下的样子：

```
config switch_vlan
        option device 'switch0'
        option vlan '1'
        option ports '2 4 6t'
```

对应2和4。之后执行`/etc/init.d/network restart`LAN口就可用了。

# 下步折腾计划
恩山上看见有人通过刮U露出针脚的方式自己加焊了USB接口……查了下资料MT7628NN的Pin61，62分别对应USB_DP和USB_DM，如果这两个针脚在主板上已经引出就简单了，有空时拿万用表测下。

- {% asset_link MT7628_datasheet.pdf MT7628NN Datasheet %}
- {% asset_link breed-mt7688-reset38.bin breed文件 %}
- {% asset_link 25b5h4.bin 编程器固件（必虎原厂） %}