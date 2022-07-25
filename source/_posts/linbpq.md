---
title: Manjaro ARM编译LinBPQ
date: 2022-7-25 11:17:04
tags:
- ax25
- LinBPQ
---
# 编译程序
源码地址： https://www.cantab.net/users/john.wiseman/Downloads/LatestLinBPQSource.zip

下载后解压，然后将makefile第11行修改成 **all: CFLAGS = -DLINBPQ -fcommon -MMD -g** ,在原基础上增加了 **-fcommon** 选项。如果不加入这个选项，编译时会提示 **multiple definition** 错误然后失败。

执行 `make -j$(nproc)` 编译，编译最后阶段会提示输入su密码，输入密码然后回车即可。编译结束后当前目录下会出现 **linbpq** 二进制程序。

另外Linbpq原本是32位程序，在64位系统上未得到充分测试，但是据作者说大部分常用功能是正常的。具体讨论可以参见 https://groups.io/g/bpq32/topic/92582455 。

至此已经成功在Manjaro ARM上编译 AX.25(内核), direwolf, Pat, Linfbb, LinBPQ，距离搭建Winlink Gateway的目标已不遥远。

# 更新
刚才编译成功代码源自 [g8bpq / LinBPQ ](https://github.com/g8bpq/LinBPQ)，虽然编译成功但是二进制程序执行会遇到 **Segmentation fault** :

```bash
          PID: 44795 (linbpq)
           UID: 1000 (marly)
           GID: 1000 (marly)
        Signal: 11 (SEGV)
     Timestamp: Mon 2022-07-25 15:12:58 CST (43min ago)
  Command Line: ./linbpq
    Executable: /home/marly/LinBPQ/linbpq
 Control Group: /user.slice/user-1000.slice/session-36.scope
          Unit: session-36.scope
         Slice: user-1000.slice
       Session: 36
     Owner UID: 1000 (marly)
       Boot ID: d5fa61d0a2c14ee29ef9269436fe2c96
    Machine ID: 4ef1f00ff29c47de9dccb0a3ab36f5e7
      Hostname: manjaro-minimal
       Storage: /var/lib/systemd/coredump/core.linbpq.1000.d5fa61d0a2c14ee29ef9269436fe2c96.44795.1658733178000000.zst (presen>
     Disk Size: 82.7K
       Message: Process 44795 (linbpq) of user 1000 dumped core.
                
                Module linux-vdso.so.1 with build-id faa2ed8100a9566346456d83ea907d810d4b1773
                Stack trace of thread 44795:
                #0  0x0000aaaad880ab34 n/a (n/a + 0x0)
                #1  0x0000aaaad880ab7c n/a (n/a + 0x0)
                #2  0x0000aaaad884cabc n/a (n/a + 0x0)
                #3  0x0000ffff8bba7b80 n/a (n/a + 0x0)
                #4  0x0000ffff8bba7c60 n/a (n/a + 0x0)
                #5  0x0000aaaad87990b0 n/a (n/a + 0x0)
                ELF object binary architecture: AARCH64
```

编译 https://www.cantab.net/users/john.wiseman/Downloads/LatestLinBPQSource.zip  则会提示

```bash
/home/marly/bpq/CommonSource/BBSUtilities.c:9797: undefined reference to `config_set_auto_convert'
collect2: error: ld returned 1 exit status
make: *** [makefile:31: linbpq] Error 1
```
大家看看这个问题应该如何解决。。。