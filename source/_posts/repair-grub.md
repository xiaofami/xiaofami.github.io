---
title: 重装Windows 10 + 修复grub
date: 2022-06-22 14:48:01
tags:
- grub
- windows
- linux
---
# 前言
单位 **G3930** 电脑的windows 10系统最近更新几次失败后就频繁死机，被迫重装，于是grub就无了。为啥要重装windows,而不是Linux only呢，因为我搞不定Linux下的打印机 Orz Windows 10的打印机其实也有bug,最著名的便是 **KB5006670** 导致远程smb打印机连接失败，一顿折腾后参考[真解决Win10最新补丁导致共享打印问题](https://bbs.pcbeta.com/viewthread-1907877-1-1.html) 通过替换 **win32spl** 文件解决了。
# 下载Windows 10
微软官网直接提供了ISO下载地址，不需要安装工具： https://www.microsoft.com/en-us/software-download/windows10ISO
# 制作安装U盘
```bash
sudo pacman -Syu woeusb
sudo woeusb --device /home/manjaro/迅雷下载/Win10_21H2_Chinese_x64.iso /dev/sdb
````
windows下我习惯用rufus制作各类安装U盘，Linux下 **woeusb** 是个不错的命令行工具，用法和 **dd** 类似，更多用法可以通过 **man** 查询。注意提供的文件名不要太复杂，比如

```bash
sudo woeusb --device /home/manjaro/迅雷下载/Win10_21H2_Chinese(Simplified)_x64.iso /dev/sdb
```

就会执行失败，推测原因是圆括号不能正常识别。
# 安装Windows 10
傻瓜操作
# 修复 grub
以下步骤在 **Manjaro live usb** 中进行，或者其他自己惯用的Linux发行版，制作好安装U盘后启动即可。
```bash
su
mount /dev/sda8 /mnt
mount mount --bind /dev /mnt/dev
mount --bind /proc /mnt/proc
mount --bind /sys /mnt/sys
chroot /mount
grub-install --target i386-pc /dev/sda
update-grub
```

有两处需要注意。其一是Linux位置，可以通过 **fdisk** 查看，本例中为 **sda8** 。其二是 **grub** 安装。我这里 **EFI** 安装失败，所以指定了 **i386-pc** 这种老式方式。重启后问题圆满解决。