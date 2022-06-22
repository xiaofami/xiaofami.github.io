---
title: 在manjaro中使用ctex
date: 2022-06-22 16:48:01
tags:
- manjaro
- linux
---

```bash
sudo pacman -S texlive-most texlive-langchinese
```
manjaro软件仓库里的 **texlive** 比较精简，没有附带宏包手册所以 **texdoc** 不能用， **latex** 初学者还是建议去CTAN下载完整镜像手动安装。我是为了编译之前写好的文件所以没有手册影响不大。（原本写作环境Deepin挂掉了）