---
title: R3300-M 运行 Manjaro ARM Sway
date: 2021-09-03 14:20:44
tags:
	- R3300-M
	- Manjaro
	- sway
	- arm
---
硬件平台还是R3300-M …… 想要Firefly的Station P2，不过迫于没钱，继续折腾小红盒 XD
# 前言
WIFI设置好后，又动了折腾图形界面的心思。之前测试过XFCE，分辨率不正常，桌面拖动窗口有明显卡顿，打开firefox直接卡死。一则显卡驱动有问题，二则XFCE对于R3300-M还是太重了。于是换用`wayland + sway`方案，彻底放弃X11。显卡驱动选择Lima，已经集成在了mesa软件包中。如果选择尝鲜，也可以安装`mesa-git`。Lima是在反向官方驱动的基础上，由社区开发维护的开源驱动，对`Mali-400`、`Mali-450`提供支持。详情可以在 https://docs.mesa3d.org/drivers/lima.html 查看。感谢Luc Verhaegen和Qiang Yu的开创性工作。
# 镜像

参见 https://manjaro.org/download/#khadas-vim-2-sway ，下载地址

```bash
https://github.com/manjaro-arm/vim2-images/releases/download/21.08/Manjaro-ARM-sway-vim2-21.08.img.xz
https://github.com/manjaro-arm/vim2-images/releases/download/21.08/Manjaro-ARM-sway-vim2-21.08.img.xz.torrent
```
# 安装
烧录镜像、修改u-boot.ext、修改extlinux等与之前无异。

# 配置
第一次启动会进入配置引导程序，配置结束后重启，进入sway图形界面。在开始探索之前，先修复系统的小小bug：

## 修复greetd服务
打开`/etc/greetd/config.toml`，看起来大概这样：
```bash                                          
[terminal]
# The VT to run the greeter on. Can be "next", "current" or a number
# designating the VT.
vt = 1

# The default session, also known as the greeter.
[default_session]
# `agreety` is the bundled agetty/login-lookalike. You can replace `$SHELL`
# with whatever you want started, such as `sway`.
command = "sway --config /etc/greetd/sway"

# The user to run the command as. The privileges this user must have depends
# on the greeter. A graphical greeter may for example require the user to be
# in the `video` group.
user = "greeter"
[initial_session]
command = "sway --config /etc/greetd/oem-setup"
user = "oem"
```
~~你需要将最后一行的`oem`修改为自己实际的用户名。~~ Manjaro ARM团队提到将[initial_session]部分完整删除（即删除上面配置文件最后三行），此问题预计很快会得到修复。

这一步本应由配置程序自动完成，如果忘记修改，下次启动将无法进入图形界面。这种情况下，按下`Ctrl + Alt + F2`进入`tty2`，手动修改过来就可以了。
## 同步时间
直接摘抄之前的文章：
```bash
user $ timedatectl set-ntp true
user $ sudo systemctl enable --now systemd-timesyncd
```
时间不准会造成SSL验证失败等一系列问题。
## 换国内源
```bash
sudo pacman-mirrors -i -c China -m rank
sudo pacman-mirrors -g
sudo pacman -Syyu
```
# 使用
## 文档获取
sway作为窗口管理器（window manager）提供了轻量的图形功能，大量依赖配置文件和快捷键操作。遵循`linux`传统，`/etc/sway/config`和`~/.config/sway/config`各存在一份，前者全局，后者本地优先。另外桌面右上角的问号是入门操作文档，没接触过`i3`或`sway`的用户必读。`sway`虽然轻量，但是仍然提供了丰富好用的功能，类似全屏、窗口、区域截图或录制功能均有对应快捷键，不逊色于macOS。
## 查看glxinfo输出
glxinfo由mesa-demos提供：
```bash
sudo pacman -S mesa-demos
```
然后执行`glxinfo -B`：
```bash
name of display: :0
display: :0  screen: 0
direct rendering: Yes
Extended renderer info (GLX_MESA_query_renderer):
    Vendor: lima (0x13b5)
    Device: Mali450 (0xffffffff)
    Version: 21.1.6
    Accelerated: yes
    Video memory: 0MB
    Unified memory: yes
    Preferred profile: compat (0x2)
    Max core profile version: 0.0
    Max compat profile version: 2.1
    Max GLES1 profile version: 1.1
    Max GLES[23] profile version: 2.0
OpenGL vendor string: lima
OpenGL renderer string: Mali450
OpenGL version string: 2.1 Mesa 21.1.6
OpenGL shading language version string: 1.20

OpenGL ES profile version string: OpenGL ES 2.0 Mesa 21.1.6
OpenGL ES profile shading language version string: OpenGL ES GLSL ES 1.0.16
```
显卡驱动正常。另外执行`sensors`可以看系统温度，负载一高很容易达到50-60°C，有必要考虑强化散热。
## HiDPI设置
这部分可以参阅Archlinux：https://wiki.archlinux.org/title/Sway

我使用的某品牌2K分辨率，默认分辨率看起来很正常，实际也是如此：

```bash
$ swaymsg -t get_outputs
Output HDMI-A-1 'Unknown Q27D530VHP 0x00000000' (focused)
  Current mode: 2560x1440 @ 59.951 Hz
  Position: 0,0
  Scale factor: 1.000000
  Scale filter: nearest
  Subpixel hinting: unknown
  Transform: normal
  Workspace: 1
  Max render time: off
  Adaptive sync: disabled
  Available modes:
    640x480 @ 72.809 Hz
    640x480 @ 75.000 Hz
    720x480 @ 59.940 Hz
    800x600 @ 60.317 Hz	
    800x600 @ 72.188 Hz
    800x600 @ 75.000 Hz
    1024x768 @ 60.004 Hz
    1024x768 @ 70.069 Hz
    1024x768 @ 75.029 Hz
    1280x720 @ 59.940 Hz
    1280x720 @ 60.000 Hz
    1280x800 @ 59.910 Hz
    1366x768 @ 59.964 Hz
    1280x1024 @ 60.020 Hz
    1280x1024 @ 75.025 Hz
    1600x900 @ 60.000 Hz
    1680x1050 @ 59.883 Hz
    1920x1080 @ 59.940 Hz
    1920x1080 @ 60.000 Hz
    1920x1080 @ 60.000 Hz
    1920x1200 @ 59.950 Hz
    2560x1440 @ 59.951 Hz
```
执行`glxgears`可以调出一个齿轮画面测试FPS,R3300-M稳定在34～35之间。电脑上这个值一般都是三位数，不过对于盒子而言已经很不错了。

2K分辨率下文字有点小，缩放到1.5：
```bash
swaymsg output HDMI-A-1 scale 1.5
```
这样看起来好了很多。
## 输入法安装
```bash
sudo pacman -S fcitx5-im #安装所有
sudo pacman -S fcitx5-chinese-addons	
```
然后打开`/etc/environment`添加参数：
```bash
GTK_IM_MODULE=fcitx
QT_IM_MODULE=fcitx
XMODIFIERS=@im=fcitx
```
最后在`Fcitx 5 Configuration`中，删除默认的Default Group,新建一个Chinese组，`Keyboard-Chinese`放上面，`Pinyin`放下面就万事大吉。默认输入法英文，使用`Ctrl Space`或`Ctrl Shift`或`Left Shift`在中英文之间来回切换。除了候选框小一点没别的问题。
## 杂项
自带的firefox刷个论坛还是很舒服的，测试bilibili弹幕比较卡，而且会丢帧，看视频还是重启到安卓系统吧。libreoffice，gedit等用着很流畅。目前小红盒用来写hexo博客或者看PDF很安逸。

另外电源管理有点小问题，关机会直接重启。而且有时休眠后显示器点不亮，需要重新拔插HDMI。
