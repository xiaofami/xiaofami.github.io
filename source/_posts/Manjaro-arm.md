---
title: R3300-M安装运行Manjaro ARM
date: 2021-08-19 15:40:39
tags:
- GXBB
- S905
- S905M-B
- BestTV
- Manjaro
- Arm
---
# 提要
这个盒子硬件没啥好说的了，前面介绍过。之前用它运行Armbian 20.10 Focal 没问题，但是balbes150弃坑后无人接手，前景不明，于是迁移到了Manjaro ARM。目前来看社区支持比较完善，更新及时，测试内核5.13（linux-aml）运行成功。

# 镜像
选择了Manjaro ARM 21.04。为什么没有选择更新的版本，比如21.06，还得从内核提起。21.04搭载主线5.11内核，测试启动R3300-M没问题，但是后续版本搭载的主线内核（测试了5.13）无法启动，提示`phy phy-c000000.phy.0:phy poweron failed --> -22`然后卡死，所以需要想办法卸载主线内核然后安装Amlogic分支。

    https://github.com/manjaro-arm/vim2-images/releases/download/21.04/Manjaro-ARM-minimal-vim2-21.04.img.xz
    https://github.com/manjaro-arm/vim2-images/releases/download/21.04/Manjaro-ARM-mate-vim2-21.04.img.xz
    https://github.com/manjaro-arm/vim2-images/releases/download/21.04/Manjaro-ARM-kde-plasma-vim2-21.04.img.xz/
    https://github.com/manjaro-arm/vim2-images/releases/download/21.04/Manjaro-ARM-xfce-vim2-21.04.img.xz/

官方提供的4个镜像中，minimal不含图形界面，经本人测试运行成功，其余带图形界面的镜像未经测试。

# 安装
和Armbian 20.10 Focal基本一致，修改extlinux.conf选择合适dtb（R3300-M使用meson-gxbb-p201.dtb），修改u-boot-s905为u-boot.ext（镜像里默认的u-boot.ext适用s905x和s912，不适用于R3300-M），然后启动盒子，完成设置，SD卡自动扩容，一切结束后自动重启完成安装进入系统。

# 系统更新（更换内核）
## 冻结内核
首先修改系统文件避免更新内核（现在更新系统就挂了）。所有Manjaro发行版均预装nano，所以：

    sudo nano /etc/pacman.conf

找到`IgnorePkg`一行，取消开头注释，修改为`IgnorePkg = linux`，保存退出，执行`sudo pacman -Syu`更新系统。系统更新后，建议重启系统。
## 切换内核为linux-aml
执行

    sudo pacman -S linux-aml

这步会删除主线内核，安装更合适的Amlogic分支内核。结束后重启系统，用uname -a查看，系统内核已更新为5.13。
## 收尾工作
再次编辑`/etc/paman.conf`，修改`IgnorePkg = linux`为`IgnorePkg = linux-aml`，毕竟在电视盒子这种非正式支持的设备上更新内核还是要谨慎一些，没必要别乱动内核。确实需要更新的情况下，提前备份好Image和initramfs-linux.img，方便回滚。

# 备注
1. 经测试，系统写入emmc无法启动。
2. 如果使用U盘启动，需要在`extlinux.conf`中指定`usb-storage.quirks`参数。例如：

> APPEND root=PARTUUID=5418e4d8-02 rootflags=data=writeback rw console=ttyAML0,115200n8 console=tty0 no_console_suspend consoleblank=0 fsck.fix=yes fsck.repair=yes net.ifnames=0 quiet splash plymouth.ignore-serial-consoles usb-storage.quirks=152d:1561:u

152d:1561为U盘vendor和product的ID号码。在linux下可以使用`lsusb`查看，Windows下也有类似小工具。
3. 无法使用root身份SSH登录，会提示密码错误。建议用普通用户连接后再切换身份。
4. 有线网卡Mac地址不固定，每次重启都会变化。
5. WIFI暂不可用，待进一步测试。
6. 类似21.06等感觉可以通过替换Image和initramfs-linux.img实现从内核从主线到Amlogic分支切换，有兴趣的可以测试。