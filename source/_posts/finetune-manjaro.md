---
title: Manjaro ARM Minimal装修
date: 2021-12-07 14:35:36
tags:
- R3300-M
- AARCH64
- Manjaro
---

# 提要
先回顾一下，我们之前为R3300-M刷入了ATV固件，目的是提升CPU主频；在TF卡上刷入了VIM2的Manjaro ARM Minimal 21.10镜像，并使用meson-gxbb-p201.dtb。随后，用linux-odroid替换了主线内核。配合编译WIFI驱动、更换软件源、设置NetworkManager等操作，现在Manjaro ARM已经能够稳定运行，已经为运行各种服务做好了充分准备。不过默认命令行界面略显简陋，下文将介绍如何用较少的硬件资源使Manjaro ARM Minimal看起来更现代、更好用。
# 配置nano高亮
nano是Manjaro ARM Minimal的默认文本编辑器，稍作修改使其更好用：
## 安装拓展高亮
```bash
sudo pacman -Sy nano-syntax-highlighting
```
## 应用高亮
编辑**/etc/nanorc**，加入以下两行：
```nanorc
include "/usr/share/nano/*.nanorc"
include "/usr/share/nano-syntax-highlighting/*.nanorc"
```
重新登录后生效。
# 美化命令行界面
## silver安装
```bash
sudo pacman -Sy silver ttf-nerd-fonts-symbols
```
## silver配置
创建**~/.config/silver/silver.toml**文件，内容如下：
```toml
[[left]]
name = "status"
color.background = "black"
color.foreground = "white"

[[left]]
name = "user"
color.background = "yellow"
color.foreground = "black"

[[left]]
name = "dir"
color.background = "blue"
color.foreground = "black"

[[left]]
name = "git"
color.background = "green"
color.foreground = "black"

[[left]]
name = "cmdtime"
color.background = "magenta"
color.foreground = "black"
```
然后修改**~/.bashrc**文件。默认文件大概这样：
```bash
#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='ls --color=auto'
PS1='[\u@\h \W]\$ '
```
修改成这样：
```bash
#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

PS1='[\u@\h \W]\$ '

# configure silver command prompt
export SILVER_ICONS=nerd
source <(silver init)

# source bash aliases
source ~/.bash_aliases
```
现在还没有**~/.bash_aliases**，手动创建一个，一会儿要用。
# 老命令替代
## 安装
```bash
sudo pacman -Sy exa bat chafa
```
## 配置
编辑**~/.bash_aliases**，加入以下内容：
```bash
alias ls="exa -aglh --icons"
alias tree="exa --tree --icons"
alias cat="bat"
alias chafa="chafa -f sixel"
```
exa和bat分别是ls和cat的现代化替代。chafa比较有意思，可以将图片转换为可以在命令行终端中显示的字符画。

保存后，重新登录或者执行`source ~/.bashrc`生效。
# 安装文件浏览器
```bash
sudo pacman -Ss mc ranger
```
mc是老前辈，ranger是后生，根据个人喜好使用。
