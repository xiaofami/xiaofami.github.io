---
title: Archlinux搭建Canokey固件编译及烧录环境
date: 2024-12-19 21:19:20
tags:
- Archlinux
- EndeavourOS
- nRF52840
index_img: https://makerworld.bblmw.com/makerworld/model/US76a0774e941e4c/design/2024-11-13_3f7e2672efdcb8.jpg?x-oss-process=image/resize,w_1000/format,webp
---
# 前言
鉴于已经将主力系统迁移到了Archlinux(EndeavourOS)，本文补充一下在Archlinux编译Canokey固件及配置的过程。
# 配置编译环境
```bash
sudo pacman -S cmake arm-none-eabi-gcc arm-none-eabi-newlib
```
我的EndeavourOS需要安装上述软件包完成编译环境搭建。在首次搭建编译环境时，常常会遇到缺少头文件的情况，怎样知道应该安装哪些软件包呢？pacman提供了对应查询功能：

```bash
sudo pacman -Fy limits.h
```

例如，编译Canokey固件需要**limits.h**这个头文件，可以通过**pacman -Fy**查询。虽然多个软件包均提供了**limits.h**，不过根据常识，头文件应当与Target平台对应，所以安装**arm-none-eabi-newlib**。

后续编译操作与在WSL2中一致，无须赘言。
# 搭建烧录环境
在Windows系统中，使用**nRF Connect for Desktop**烧录固件极为便利。幸运的是，Nordic公司也为它开发了Linux版本：
```bash
paru -S nrfconnect-appimage nrf-udev
```
软件界面及使用方式与Windows版本完全一致。
# 安装Google Chrome
安装一个浏览器似乎与Canokey没什么联系，其实不然。Canokey的fido2模块无法通过Canokey自己的console配置，必须借助第三方程序。在Windows 11中，可以借助 **Windows Hello** 配置：（参考：[Resetting the FIDO2 Application on Your YubiKey or Security Key](https://support.yubico.com/hc/en-us/articles/360016648899-Resetting-the-FIDO2-Application-on-Your-YubiKey-or-Security-Key)）

打开**系统设置**，选择 **账户 - 登录选项 - 安全密钥 - 使用物理安全密钥登录到应用 - 管理  安全密钥PIN（创建/更改），重置安全密钥**，即可实现修改fido2 pin码，或者重置fido2模块操作。Linux下可以利用**Google Chrome**实现同等功能：
```bash
paru -S google-chrome-wayland-vulkan
```
使用kate打开 `/usr/share/applications/google-chrome.desktop`，将
```bash
Exec=/usr/bin/google-chrome-stable %U
```
修改为
```bash
Exec=env LANGUAGE=zh_CN LC_ALL=zh_CN.UTF-8 QT_SCREEN_SCALE_FACTORS=1 XMODIFIERS="@im=fcitx" GTK_IM_MODULE="fcitx" QT_IM_MODULE="fcitx" SDL_IM_MODULE=fcitx GLFW_IM_MODULE=ibus /usr/bin/google-chrome-stable %U
```
这一步只是为了解决中文输入以及中文界面问题，与之前配置WPS如出一辙。

配置结束后，打开Google Chrome，访问 [chrome://settings/securityKeys](chrome://settings/securityKeys) 便可进入物理密钥配置页面，能够进行fido2相关配置。
# 第三方外壳
热心网友为**EBYTE E104BT5040U**制作了带按钮的外壳，手里有3D打印机的可以打印出来试试效果如何：[EByte nRF52840 Dongle Case with Buttons
](https://makerworld.com/en/models/785032#profileId-722680)
[!img](https://makerworld.bblmw.com/makerworld/model/US76a0774e941e4c/design/2024-11-13_5636ec5c156af8.jpg?x-oss-process=image/resize,w_1000/format,webp)
[!img](https://makerworld.bblmw.com/makerworld/model/US76a0774e941e4c/design/2024-11-13_3f7e2672efdcb8.jpg?x-oss-process=image/resize,w_1000/format,webp)
# 其他
自从上次使用fido2功能已经过去了很久，以至于我完全忘记了对应pin码，几次错误后被Google以及GitHub拉黑了设备，提示要重置设备，这个重置指的是重置fido2模块。注意，重新刷固件不能实现fido2重置，必须通过上面的**Windows Hello**或者**Google Chrome**方式才行，我来回刷了几次固件才发现这一问题。

另外今年11月27日**Gpg4win 4.4.0** 正式发布，配合Canokey没什么问题,还在用旧版本的可以更新了。
