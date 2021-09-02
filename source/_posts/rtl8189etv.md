---
title: Manjaro ARM编译RTL8189ETV驱动
date: 2021-09-02 09:29:41
tags:
	- RTL8189ETV
	- ARM
	- Manjaro
	- R3300-M
---
目标硬件平台还是R3300-M …… 尝试解决下WIFI问题。

参考：[Orange Pi](https://wiki.archlinux.org/title/Orange_Pi#RTL8189ES/ETV)

```bash
git clone https://github.com/jwrdegoede/rtl8189ES_linux.git
cd rtl8189ES_linux
make -j4 ARCH=arm KSRC=/usr/lib/modules/4.18.11-1-ARCH/build/
cp 8189es.ko /usr/lib/modules/4.18.11-1-ARCH/kernel/drivers/net/wireless/realtek/
depmod -a
modprobe 8189es
```
上述`4.18.11-1-ARCH`根据实际情况替换。有反馈说NanoPi A64使用5.11内核驱动正常，这几天抽空测试下。

更新：编译加载成功，步骤如下：

```bash
git clone https://github.com/jwrdegoede/rtl8189ES_linux.git
sudo pacman -S linux-headers
cd /usr/lib/modules/5.13.12-1-MANJARO-ARM/build/arch
sudo mv arm armold
sudo mv arm64 arm
cd ~/rtl8189ES_linux/
make -j4 ARCH=arm KSRC=/usr/lib/modules/5.13.12-1-MANJARO-ARM/build
sudo cp 8189es.ko /usr/lib/modules/5.13.12-1-MANJARO-ARM/kernel/drivers/net/wireless/realtek/
sudo depmod -a
sudo modprobe 8189es
```

使用的是`5.13.12-1-MANJARO-ARM #1 SMP Wed Aug 18 07:36:58 UTC 2021 aarch64 GNU/Linux`主线内核，模块编译过程很顺利，只需要对build目录做一点微小的改动，编译完成后可以把文件夹名称修改回去。测试重启后依然有效，不需要手动加载。