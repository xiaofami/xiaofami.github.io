---
title: Manjaro ARM 搭建LaTeX中文写作环境
date: 2021-09-13 15:57:07
tags:
- Manjaro
- ARM
- R3300-M
---
最近瞎鼓捣东西形成了一些笔记想好好地汇编成册，当年写论文时用过的LaTeX还不错，基本语法也没忘，于是就选它了。troff据说历史更悠久，而且基本上Linux发行版都会预装，不过就不花功夫研究老古董了。

得益于Archlinux粗壮的大腿，使用Manjaro遇到的问题往往可以在(Archlinux Wiki)[https://wiki.archlinux.org/title/TeX_Live_(%E7%AE%80%E4%BD%93%E4%B8%AD%E6%96%87)#TeXLive_Local_Manager]中找到答案。安装很简单：
```bash
sudo pacman -Sy texlive-most texlive-langchinese
```
`texlive-most`包含了`texlive-core`和其他一些可选模块，建议全选。`texlive-langchinese`包含了CTEX宏包。我选择`xeLatex + CTEX`的中文方案，所以这个包必装。

安装完毕后测试看看效果：
```tex
\documentclass{ctexbook}
\begin{document}
中文测试
\end{document}
```
输出符合预期。`texdoc tikz`还是一如既往地头大，而且现在又多了一个画花纹的pgfornament看起来很有趣。