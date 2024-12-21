---
title: Canokey之OATH踩坑记录
date: 2024-12-21 20:14:52
tags:
- Archlinux
- EndeavourOS
- Canokey
index_img: /img/Screenshot_20241221_204430.png
---
之前使用Canokey的opengpg模块实现了文件加解密、签名、SSH登录、GitHub commit等功能，于是又折腾了下OATH模块。用起来很简单，但是有坑需要注意。

# 获取TOTP链接并添加到Canokey
支持TOTP的网站一般会提供一个二维码，把这个二维码图片保存到本地，然后使用`zbarimg`读取即可获得链接:
```bash
$ zbarimg yourqrcode.png

QR-Code:otpauth:// ………………secret=……………………
```
大致如此，执行后会输出二维码对应的实际链接。Archlinux中，zbarimg由`zbar`提供，如果没有预装请自行pacman。

得到链接后，在Canokey管理页面**TOTP/HOTP**模块中手动添加对应信息即可。Canokey管理页面也提供了图片识别功能，可以一键识别图片省却手动填写麻烦，两种方式看个人喜好。（别用微信扫码就行 。。。）

# 坑点
Canokey管理页面 https://console.canokeys.org/#/applets/oath 中，右上角有一个🔒标志，可以为**TOTP/HOTP**页面设置访问密码。这个设计逻辑上没问题，但是实现上貌似存在BUG。初次设置密码后，后续对该密码的任何修改或清空操作都无效——没有错误提示，而且Canokey文档中根本没提到过这个密码，这真令人头大。Canokey的新版管理页面中移除了重置模块选项，还得到旧版管理页面中操作。

旧版管理页面有两个，分别为

* https://console-legacy.canokeys.org/#/
* https://console-vue.canokeys.org/

真正有用的是第二个。关闭掉所有的canokey管理页面避免访问冲突，打开 https://console-vue.canokeys.org/admin ，选择**RESET OATH**，重置后恼人的**TOTP/HOTP**页面访问密码就没有了，当然先前的**TOTP**记录也没了，需要重新导入。
