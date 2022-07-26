---
title: Manjaro ARM编译LinBPQ
date: 2022-7-25 11:17:04
tags:
- ax25
- LinBPQ
---
源码地址： https://www.cantab.net/users/john.wiseman/Downloads/LatestLinBPQSource.zip

为了在Manjaro ARM下成功编译，需要对源文件进行如下改动：

1. makefile第22行，将
```makefile
all: CFLAGS = -DLINBPQ -MMD -g
```
修改为
```makefile
all: CFLAGS = -DLINBPQ -MMD -g -fcommon
```
如果不加入 **-fcommon** 选项，编译时gcc会提示 **multiple definition** 错误。

2. makefile第31行，将 **libminiupnpc.a** 修改为 **libminiupnpc.so** 。谨慎起见先检查一下 **miniupnpc** 这个包有没有安装，它提供了 **/usr/lib/libminiupnpc.so** 。

3. BBSUtilities.c 第9797行，将
```c
config_set_auto_convert (&cfg, 1);
```
修改为
```c
config_set_option(&cfg, CONFIG_OPTION_AUTOCONVERT, 1); 
```

保存上述修改后执行 `make -j$(nproc)` 编译即可。结束后当前目录会出现名为 **linbpq** 的可执行程序。这个程序可以移动到其他方便使用的地方，但是注意 **linbpq** 默认会在运行路径下寻找配置文件并生成log，暂时还不清楚如何指定配置文件位置。

LinBPQ配置比较复杂，可以参考开发者亲自撰写的[LinBPQ Guides](https://www.cantab.net/users/john.wiseman/Documents/LinBPQGuides.html)

再次致谢LinBPQ的开发者 **John G8BPQ** ，他对编译中遇到的问题给出了解决办法，使Manjaro ARM运行LinBPQ成为现实。大师教导参见 https://groups.io/g/bpq32/topic/92582455 。