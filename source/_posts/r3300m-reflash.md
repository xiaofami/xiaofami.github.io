---
title: R3300-M再刷机
date: 2023-02-06 10:41:46
tags:
- R3300-M
- Manjaro ARM
---

家里先前运行Manjaro ARM的R3300-M最近出现了开机一段时间后SSH无法登陆的问题，于是备份必要文件后重刷系统。原本以为不需要再水一篇文章，不过刷机过程中遇到了一些问题，有必要记录下来。
# 镜像选择
之前我写过一篇文章建议使用generic镜像，我记得当时试验很顺利。不过我发现最新版的generic镜像 **extlinux.ext** 文件结构发生了较大变化，不仅取消了DTB文件指定，而且启动参数也精简了许多，毫无意外启动失败了。我参照之前的格式修改，结果无法发现root分区，这肯定就行不通了。于是换用Vim2镜像，这个也有坑。测试了22.12和22.10版本，启动时提示 **reserved mem:failed to allocate memory for node 'linux,cma'** 错误导致启动失败进入 **emergency shell**。几经测试后 **vim2 22.08** 是能够正常使用的最新版本，开机后直接更新系统换主线内核即可。针对dtb文件区别我进行了简单试验，试验结果如下：

1. 当前使用的dtb文件与Manjaro-ARM-minimal-generic-22.12.img中提供的meson-gxbb-p201.dtb文件，反编译后得到的dts文件经过diff比较是完全一致的，符合预期。
2. 当前使用的dtb文件与Manjaro-ARM-minimal-vim2-22.08.img中提供的meson-gxbb-p201.dtb文件，反编译后得到的dts文件diff结果如下：

```bash
diff current.dts vim2-08.dts
50c50
<                       size = <0x00 0x10000000>;
---
>                       size = <0x00 0x38000000>;
```

对应dts文件中此部分：

```bash
# Manjaro-ARM-minimal-generic-22.12.img
linux,cma {
        compatible = "shared-dma-pool";
        reusable;
        size = <0x00 0x10000000>;
        alignment = <0x00 0x400000>;
        linux,cma-default;
};
```

```bash
# Manjaro-ARM-minimal-vim2-22.08.img
linux,cma {
      compatible = "shared-dma-pool";
      reusable;
      size = <0x00 0x38000000>;
      alignment = <0x00 0x400000>;
      linux,cma-default;
};
```

至于 Manjaro-ARM-minimal-generic-22.12.img 与 Manjaro-ARM-minimal-vim2-22.12.img dtb差异就比较悬殊了，大量的的phandle值不同，而且新增了 ** system-suspend** 、 **rtc@a8** 、 **sound** 、 **vrtc** 内容。

Manjaro ARM提供了[manjaro-arm-tools](https://gitlab.manjaro.org/manjaro-arm/applications/manjaro-arm-tools)这一工具，可以提供打包应用，制作系统镜像等功能。有空可以为R3300-M定制一份配置文件。

# 编译WIFI驱动
```bash
sudo pacman -S git make gcc bc
git clone https://github.com/jwrdegoede/rtl8189ES_linux.git
cd ~/rtl8189ES_linux/
make -j$(nproc) ARCH=arm64 KSRC=/usr/lib/modules/$(uname -r)/build
sudo cp 8189es.ko /usr/lib/modules/$(uname -r)/kernel/drivers/net/wireless/realtek/
sudo depmod -a
sudo modprobe 8189es
```
较之前的版本补充了依赖关系安装。nproc是一个用于获取CPU线程数的小程序，用来全速编译很便利。
# 连接WIFI
过去我使用 **networkmanager** 提供的 **nmtui** 连接WIFI，优点比较直观。这次换用 **wpa_supplicant** 连接无线网络。
刚才编译加载好无线驱动后使用 `ip a` 查看，可以看到无线网卡名称为 **wlan0** ，使用 `sudo iw wlan0 scan` 可以扫描到附近的全部无线热点，说明无线网卡已经正常驱动，接下来用pacman安装**wpa_supplicant**。安装程序会自动创建 **/etc/wpa_supplicant/** 这个目录，该目录目前还是空的，需要自行创建WIFI配置文件。

假设要连接SSID为 **ASUS** ，密码为 **12345678** 的这个WIFI，首先生成配置文件：
```bash
wpa_passphrase "ASUS" "12345678" 


network={
        ssid="ASUS"
        #psk="12345678"
        psk=a0efc361219475143ca336c62571c833d81e72b952db56e373a5c255ebff7e00
}
```
在 **/etc/wpa_supplicant/** 这个目录下创建 **wpa_supplicant.conf** ，然后把上门的输出内容复制进去保存。然后执行命令连接：
```bash
sudo wpa_supplicant -i wlan0 -c /etc/wpa_supplicant/wpa_supplicant.conf &
```
这个命令是很直观的，使用wlan0这个无线网卡，根据 **/etc/wpa_supplicant/wpa_supplicant.conf** 配置连接WIFI，并作为后台进程执行。

当然每次开机手动连接WIFI是不方便的，很自然的想法是利用systemd创建service。事实上 **wpa_supplicant** 也提供了服务：
```bash

systemctl cat wpa_supplicant
# /usr/lib/systemd/system/wpa_supplicant.service
[Unit]
Description=WPA supplicant
Before=network.target
After=dbus.service
Wants=network.target
IgnoreOnIsolate=true

[Service]
Type=dbus
BusName=fi.w1.wpa_supplicant1
ExecStart=/usr/bin/wpa_supplicant -u -s -O /run/wpa_supplicant

[Install]
WantedBy=multi-user.target
Alias=dbus-fi.w1.wpa_supplicant1.service
```
但是这个服务达不到期望目的。参考 [Difference between systemd wpa_supplicant.service and wpa_supplicant@wlan0.service?](https://unix.stackexchange.com/questions/361558/difference-between-systemd-wpa-supplicant-service-and-wpa-supplicantwlan0-servi) 一文，这个服务主要是用于服务 **networkmanager** 的。由于我不打算安装使用 **networkmanager** ，所以这个服务没有意义。真正有意义的是 **wpa_supplicant@.service** ，而且值得特别指出，这是个动态服务：

```bash
systemctl cat wpa_supplicant@.service
# /usr/lib/systemd/system/wpa_supplicant@.service
[Unit]
Description=WPA supplicant daemon (interface-specific version)
Requires=sys-subsystem-net-devices-%i.device
After=sys-subsystem-net-devices-%i.device
Before=network.target
Wants=network.target

# NetworkManager users will probably want the dbus version instead.

[Service]
Type=simple
ExecStart=/usr/bin/wpa_supplicant -c/etc/wpa_supplicant/wpa_supplicant-%I.conf -i%I

[Install]
WantedBy=multi-user.target
```

至此思路就清楚了。首先执行 `ps aux | grep wpa` 找到并杀死刚才连接WIFI执行的后台进程，然后将 **/etc/wpa_supplicant/wpa_supplicant.conf** 重命名为 **/etc/wpa_supplicant/wpa_supplicant-wlan0.conf** ，最后执行 `sudo systemctl enable --now wpa_supplicant@wlan0` 激活服务就大功告成。注意体味下此处动态服务的妙用。
# 重新安装hexo
```bash
sudo pacman -S npm
sudo npm install hexo-cli -g
sudo npm install hexo-deployer-git --save
```
这里补充的主要是GitHub使用密钥同步问题：

1. 修复密钥权限
**$HOME/.ssh**目录下的私钥 **id_rsa** 导回后默认权限为644，程序会抱怨权限太宽，需要手动改成600。成功后测试输出如下：
```bash
ssh -T git@github.com
Hi xiaofami! You've successfully authenticated, but GitHub does not provide shell access.
```
2. 修改 **.git/config**文件
**.git** 位于你的hexo目录。我修改后的config文件内容如下：
```config
[core]
        repositoryformatversion = 0
        filemode = true
        bare = false
        logallrefupdates = true
[remote "origin"]
        url = git@github.com:xiaofami/xiaofami.github.io
        fetch = +refs/heads/*:refs/remotes/origin/*
[branch "blogSource"]
        remote = origin
        merge = refs/heads/blogSource
```
修改之前 **url** 一行使用的是https格式，所以无法跳过手动输入验证步骤。按照上述形式修改为git即可。
