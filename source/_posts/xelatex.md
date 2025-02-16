---
title: Archlinx中使用texlive排版中文
date: 2025-02-16 10:26:22
tags:
- Archlinux
- texlive
- xelatex
index_img: data:image/png;base64,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
---
# 安装texlive
下载安装texlive iso镜像即可，如果之前使用pacman安装了类似 **texlive-basic** 等相关包，记得先删掉。然后如果安装程序没有自动添加环境变量，就需要手动设置，在 `~/.bashrc` 中加入这样一句就行了：
```bash
export PATH=$PATH:/usr/local/texlive/2024/bin/x86_64-linux
```
# 字体安装
```bash
paru -S ttf-wps-fonts wps-office-fonts
sudo fc-cache -fv
```
**tf-wps-fonts** 提供了Windows自带的大量字体， 可以参见项目地址：https://github.com/ferion11/ttf-wps-fonts； **wps-office-fonts** 提供了常用的方正GBK字体。如果你想使用Windows系统自带的类似宋体、仿宋等中文字体，可以安装 **ttf-ms-win10-auto-zh_cn** 或 **ttf-ms-win11-zh_cn** 获取，无须手动复制安装。
# 学习参考
首推刘海洋老师的[《LaTeX 入门》](https://yun.weicheng.men/Book/LaTeX%E5%85%A5%E9%97%A8.pdf)，再结合 **texdoc** 翻翻 **CTEX** 等常用宏包文档就差不多了。LaTeX中文写作现在还是 xelatex + ctex 老一套，十几年来没发生什么变化。
# 使用示范
一个很简单的个人总结模板：
```tex
%!TEX program = xelatex
%-*- coding: UTF-8 -*-
\documentclass[UTF8,a4paper,fontset=none]{ctexart}
\usepackage{titling}
\setlength{\droptitle}{-4em}     % Eliminate the default vertical space

\usepackage[top=2.54cm, bottom=2.54cm, left=2.8cm, right=2.8cm]{geometry}

%fancyhdr设置要在geometry之后，使宏包获取正确的页面信息
\usepackage{fancyhdr}
\pagestyle{fancy}
\fancyhf{}
\cfoot{\thepage}
\renewcommand\headrulewidth{0pt}
\linespread{1.5}

\setmainfont{Times New Roman}%设置正文罗马字体族
\setsansfont{Verdana}%设置无衬线字体族
\setmonofont{Courier New}%设置打字机字体族
\setCJKmainfont[BoldFont=FZHei-B01,ItalicFont=FZKai-Z03,BoldItalicFont=FZLiShu-S01]{FZFangSong-Z02}%设置正文罗马字体族
\setCJKfamilyfont{fzxbs}{FZXiaoBiaoSong-B05}
\setCJKfamilyfont{fzKai}{FZKai-Z03}
% 配置ctex标题格式
\ctexset{
    section = {
        format = \zihao{3}\bfseries,
        indent = 2\ccwd,
        beforeskip = 0ex,
        afterskip = 0ex,
        name = {,、},
        number = \chinese{section},
        aftername = \hspace{0.5em},
    },
    subsection = {
        format = \zihao{3}\itshape,
        indent = 2\ccwd,
        beforeskip = 0ex,
        afterskip = 0ex,
        name = {（,）},
        number = \chinese{subsection},
        aftername = \hspace{0.5em},
    },
    subsubsection = {
        format = \zihao{3}\normalfont\bfseries,
        indent = 2\ccwd,
        beforeskip = 0ex,
        afterskip = 0ex,
        name = {,.},
        number = \arabic{subsubsection}.,
        aftername = \hspace{0.5em},
        runin = true,
    }
}
% 设置全局段落格式

\setlength{\parskip}{0pt}
%\setlength{\parindent}{2em} % 首行缩进2字符
%\pagestyle{empty} % 去除页眉页脚
% 标题和作者信息
\title{\zihao{2}\CJKfamily{fzxbs} 工作总结}
\author{\zihao{3}\CJKfamily{fzKai} 职务+姓名}
\date{} % 去掉日期
%\usepackage{newunicodechar}
%\newunicodechar{🌖}{\bigmoon}
\begin{document}
\maketitle
% 正文内容
\zihao{3} % 设置正文字体字号
\vspace{-3\ccwd}
一个个人总结……
\end{document}
```

很简单的模板。行间距可以这么计算：正文字号为三号，即16bp，约等于16pt。LaTeX中，基本行距为文字大小的1.2倍，上面将**linespread**设置为1.5，所以最后的行间距即为 `16*1.2*1.5 = 28.8pt`，对应WORD中的28.8磅行间距。
