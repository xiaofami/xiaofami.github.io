---
title: HP M281FDW降级固件分享
date: 2025-01-15 21:38:13
tags:
- HP
- M281FDW
index_img: https://tse3-mm.cn.bing.net/th/id/OIP-C.38CYOuFKKM4pq5RCWDxoZAHaHa?w=176&h=180&c=7&r=0&o=5&pid=1.7
---
家里有台多年前海淘的HP M281FDW激光彩色打印机，几年下来用着还算满意。可是HP为了让用户使用高价原装耗材，在后续固件更新中封杀了第三方硒鼓。虽然我早早就关掉了固件更新功能，不过以防意外，特意搜罗了固件降级方法，有需要的网友不要客气直接拿去用。

# 下载降级固件
请直接点击下载：

- {% asset_link HP_LaserJet_Pro_M280_M281_Printer_series_20200612.exe HP_LaserJet_Pro_M280_M281_Printer_series_20200612.exe %}

MD5: 3519A1E3EB67D5564B6284F03B1D5C66
SHA1: 32E30EE529E8DC55BFD4A46A03B8823AF8D1F47D

- {% asset_link HP_LaserJet_Pro_M280_M281_Printer_series_20200612.rfu HP_LaserJet_Pro_M280_M281_Printer_series_20200612.rfu %}

MD5: 3E637DE030C760EEC23DF158D35AE0B6
SHA1: 5B4911716708626624E031F0D47D4F1A9DF11996

- {% asset_link HP-Color-LaserJet-Pro-MFP-M280M281-Firmware-Downgrade.pdf HP-Color-LaserJet-Pro-MFP-M280M281-Firmware-Downgrade.pdf %}

- {% asset_link HP_Color_LaserJet_Pro_M282_M285_Multifunction_Printer_series_20200603.rfu HP_Color_LaserJet_Pro_M282_M285_Multifunction_Printer_series_20200603.rfu %}

附件1、2是M281FDW的降级程序/固件，3为打印机设置，4为M282的降级固件，偶然间得到就随手放了上来。
# 打印机设置
在打印机触摸屏中进入对应菜单进行以下操作：

Setup（设置） > Service（服务） > LaserJet Update（LaserJet更新） > Manage Updates（管理更新）

* Allow Downgrade（允许降级）: Yes（是）
* Check Automatically（自动检查）: Off（关闭）
* Prompt Before Install（安装前提示）: Always Prompt（总是提示）
* Allow Updates（允许更新）: Yes（是，降级完成后记得回来把这个选项关掉）

附件3中有图文步骤，可供参考。
# 开始刷机
## FTP打印法
参考自[How to downgrade HP Printer firmware via FTP](https://rickscully.com/2020/how-to-downgrade-hp-printer-firmware-via-ftp/)

过程如下：
1. 浏览器中打开打印机管理页面，进入 **网络 > 高级**配置页面，把**FTP打印**选中，然后点击页面最下方**应用**按钮。
2. 随便打开一个你喜欢的FTP客户端，连接到打印机，用户名与密码均为空。连上去后，上传**HP_LaserJet_Pro_M280_M281_Printer_series_20200612.rfu**，打印机会自动开始刷机。

rfu文件本质上就是一个raw格式打印任务，神奇的是利用打印任务，我们也可以进行固件刷写等操作：

> The rfu files are simply formatted as raw print jobs that the printer understands as firmware updates (actually quite a clever mechanism for updating, although I wonder how easily it could be abused by a knowledgeable hacker...) The printer accepted the update, rebooted and came up with the older firmware. Printing works again on the third party cartridges, confirming that HP definitely did something in 20201021 that blocks at least some types of third party cartridges.

-From [Anyone have older HP LaserJet firmwares?](https://www.reddit.com/r/DataHoarder/comments/joznz6/anyone_have_older_hp_laserjet_firmwares/)。
## LPR打印法
在Windows功能中打开**打印和文件服务 > LPR端口监视器**功能，Linux应该默认提供了lpr。然后运行以下命令：
```bash
lpr -S 10.0.1.250 -P 10.0.1.250 HP_LaserJet_Pro_M280_M281_Printer_series_20200612.rfu 
```
**10.0.1.250** 是局域网中打印机地址，请自行替换。
和FTP刷机方式类似，也是将rfu格式固件当作打印任务提交，打印机便会自动开始刷机。
## Windows双击法
在Windows系统中双击**HP_LaserJet_Pro_M280_M281_Printer_series_20200612.exe**并按照提示进行操作，可以参考[HP惠普M281打印机升级后不兼容国产硒鼓，系统固件降级步骤](https://post.smzdm.com/p/a0qkwegr/)，貌似需要用USB线连接电脑操作。

上述方法均未经本人验证，不过根据reddit上的回帖反馈，不少人用FTP方式刷机成功，将系统固件降级到了**20200612**。
