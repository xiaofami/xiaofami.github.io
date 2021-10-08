---
title: Manjaro ARM内核比较
date: 2021-10-08 11:01:33
tags:
- Manjaro
- ARM
- aarch64
- kernel
- R3300-M
---
Manjaro ARM软件仓库里可用内核有三个分支：mainline，aml，vim，都有对应的headers。

# mainline
更新最快，理论上被投入的开发维护资源更多。如果用mainline kernel一切正常，就选它好了。

# aml
可能对Amlogic SOC有加成？我没发现。

# vim
可能对vim板子有加成？

用刷入ATV底包的R3300-M盒子测试，三者都能正常启动运行，但是只有vim内核poweroff与reboot正常，故切换到vim内核。
```bash
sudo pacman -Sy linux-vim linux-vim-headers
```

编译WIFI驱动小小修改一下：
```bash
git clone https://github.com/jwrdegoede/rtl8189ES_linux.git
cd ~/rtl8189ES_linux/
make -j4 ARCH=arm64 KSRC=/usr/lib/modules/$(uname -r)/build
sudo cp 8189es.ko /usr/lib/modules/$(uname -r)/kernel/drivers/net/wireless/realtek/
sudo depmod -a
sudo modprobe 8189es
```
直接指定架构为arm64进行编译即可。