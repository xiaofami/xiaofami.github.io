---
title: Manjaro ARM编译Linbpq
date: 2022-7-25 11:17:04
tags:
- ax25
- linbpq
---

源码地址： https://www.cantab.net/users/john.wiseman/Downloads/LatestLinBPQSource.zip

下载后解压，然后将makefile第11行修改成 **all: CFLAGS = -DLINBPQ -fcommon -MMD -g** ,在原基础上增加了 **-fcommon** 选项。如果不加入这个选项，编译时会提示 **multiple definition** 错误然后失败。

执行 `make -j$(nproc)` 编译，编译最后阶段会提示输入su密码，输入密码然后回车即可。编译结束后当前目录下会出现 **linbpq** 二进制程序，把它移动到 `/usr/local/bin` 就可以了。

另外Linbpq原本是32位程序，在64位系统上未得到充分测试，但是据作者说大部分常用功能是正常的。具体讨论可以参见 https://groups.io/g/bpq32/topic/92582455 。

至此已经成功在Manjaro ARM上编译 AX.25(内核), direwolf, Pat, Linfbb, Linbpq，距离搭建Winlink Gateway的目标已不遥远。