---
title: Manjaro ARM更换linux-odroid内核
date: 2021-12-02 09:24:57
tags:
- R3300-M
- AARCH64
- Manjaro
---
Manjaro ARM最近似乎用**linux-odroid**替换了**linux-vim**，执行**pacman -Syu**系统更新时会提示是否替换：

```bash
core/linux 5.15.5-1
core/linux-headers 5.15.5-1
core/linux-vim 5.14.10-1
core/linux-vim-headers 5.14.10-1
core/linux-odroid 5.15.3-1
core/linux-odroid-headers 5.15.3-1
```
更新后测试没问题，重启正常，关机没测不过应该没问题。主线内核有空可以测下。

另外测试无线仍然无法正常驱动，可以看到WIFI列表但是连接失败。
