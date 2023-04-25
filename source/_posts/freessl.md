---
title: HP ProLiant MicroServer Gen8再战群晖(2023)
date: 2023-04-25 14:13:57
tags:
- synology
- freessl
index_img: /img/Screenshot_20230425_150454.png
---

最近参照[编译了个Gen8黑群引导支持最新7.1.1-62962正式版-物理机安装](http://www.gebi1.com/thread-302165-1-1.html)给尘封已久的 *HP ProLiant MicroServer Gen8* 安装了 *DSM 7.1.1-42962 Update 5* ，于是开始了新一轮折腾。

# 申请使用freessl免费证书
freessl网址： https://freessl.org/ ，注意后缀不是cn。群晖本身支持一键申请Let's Encrypt证书，但是家宽被封了80端口，所以退而求其次，使用邮箱申请。成功后得到4个文件：

* domian.key : 私钥；
* domain.pem : 证书。

在群晖中导入上述两个文件即可。剩下的 intermediate.pem 和 root.pem 用不到。443端口自然也不通，于是我将8443端口映射到了5001端口。
# 修改DownloadStation下载缓存
控制面板里打开SSH，连接后进行修改：

```bash
cat /var/packages/DownloadStation/etc/settings.conf

btsearch_server="https://update.synology.com/btsearchupdate/getServerInfo.php"
download_bt_cache_limit="32"
download_maxtasks_limit="80"
download_enable_amule=yes
download_ul_rate=0
download_enable_bt_port_forwarding=yes
download_seeding_interval=1440
download_seeding_ratio=100
download_amule_ul_rate=0
```

利用vi将 **download_bt_cache_limit** 调大。我的内存是16G，所以设置成了2048。
然后重启DownloadStation：

```bash
sudo synopkg stop DownloadStation
sudo synopkg start DownloadStation
```
