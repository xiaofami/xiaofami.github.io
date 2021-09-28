---
title: Manjaro Sway 命令行提示符挖掘 
date: 2021-09-28 09:23:29
tags:
- bash
- silver
- nerd-fonts
---
Manjaro Sway默认的bash提示符看起来类似oh-my-zsh比较美观，简单分析后发现使用了[silver](https://github.com/reujab/silver)：

![图示](https://github.com/reujab/silver/raw/master/sleep.png)

> A cross-shell customizable powerline-like prompt heavily inspired by Agnoster. The faster rust port of bronze.

silver是一个跨平台、方便配置的类powerline提示符，从bronze移植而来。bronze是用go开发的，目前已经停止维护了，其git页面上显示用rust写的silver比它快50%，其配置文件通用所以老用户迁移很容易。bronze大量参考了[Agnoster](https://github.com/agnoster/agnoster-zsh-theme)这个zsh主题。

目前silver支持 Powershell, Bash, Zsh, fish, Ion 和Elvish。

silver的图标由[nerd](https://github.com/ryanoasis/nerd-fonts)字体提供。这个字体囊括了常用图标库，比如Font Awesome就包含其中。
[diagram](https://github.com/ryanoasis/nerd-fonts/raw/master/images/sankey-glyphs-combined-diagram.svg)

Manjaro Sway中，silver.toml位于`~/.config/silver`，可根据自身喜好修改。