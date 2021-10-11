---
title: 使用Systemd实现以用户身份开机自动执行脚本
date: 2021-10-11 15:18:42
tags:
- Manjaro
- ARM
- aarch64
- Systemd
---

# 需要开机自动执行的脚本
```bash                                                              
#!/bin/bash
# rustdocs.sh
# 别忘记给它可执行权限
/home/marly/.cargo/bin/mdbook serve -n 0.0.0.0 -p 3000 /home/marly/Documents/rust/trpl-zh-cn&
/home/marly/.cargo/bin/mdbook serve -n 0.0.0.0 -p 4000 /home/marly/Documents/rust/rust-by-example-cn&
```
第一行如果末尾不加"&"，第二句命令就不会执行。

另外脚本启动发生在marly登录bash之前，所以类似`.bash_profile`中自定义的`$PATH`无效，需要使用绝对路径。

# systemd服务

```bash
[Unit]
Description=Start rust doc service on boot
Requires=network-online.target
Documentation=man:rustc

[Service]
User=marly
Type=forking
ExecStart=/home/marly/.local/bin/rustdocs.sh

[Install]
WantedBy=multi-user.target
```
把它命名为 `rustdoc-start.service` 即可，必须以`.service`结尾。

# 启动服务

将上述service文件放置在`/etc/systemd/system`或`/usr/lib/systemd/system/`中，然后执行`sudo systemctl enable rustdoc-start.service`。完毕后重启设备观察效果，如无意外mdbook服务会自动启动。

注意`sudo systemctl enable rustdoc-start.service`的细节。此步骤在`/etc/systemd/system/multi-user.target.wants`创建了指向`rustdoc-start.service`的同名符号链接。

# 分析
上面的User，Type，ExecStart，WantedBy是重点。`User=marly`即以用户marly身份执行，`ExecStart`为所执行命令，本例中即刚才编写的脚本路径。`WantedBy`决定了服务启动时机，`multi-user.target`对应的系统状态大致为： (参考自 [Why do most systemd examples contain WantedBy=multi-user.target?](https://unix.stackexchange.com/questions/506347/why-do-most-systemd-examples-contain-wantedby-multi-user-target))

> multi-user.target normally defines a system state where all network services are started up and the system will accept logins, but a local GUI is not started. This is the typical default system state for server systems, which might be rack-mounted headless systems in a remote server room.

> 所有网络服务已启动，系统已经做好接受登录的准备，但是GUI还未启动。对于无头服务器而言，这是默认的系统状态。

本例需要对外提供网络服务，所以`WantedBy=multi-user.target`是合适的。

最后是`Type`，有`simple, exec, forking, oneshot, dbus, notify, idle`几种类型。借用下[金步国先生的翻译](http://www.jinbuguo.com/systemd/systemd.service.html) ：

> 如果设为 forking ，那么表示 ExecStart= 进程将会在启动过程中使用 fork() 系统调用。 也就是当所有通信渠道都已建好、启动亦已成功之后，父进程将会退出，而子进程将作为主服务进程继续运行。 这是传统UNIX守护进程的经典做法。 在这种情况下，systemd 会认为在父进程退出之后，该服务就已经启动完成。 如果使用了此种类型，那么建议同时设置 PIDFile= 选项，以帮助 systemd 准确可靠的定位该服务的主进程。 systemd 将会在父进程退出之后 立即开始启动后继单元。

个人理解，执行`rustdocs.sh`本身创建了一个进程，其中的两条mdbook命令又创建了2个子进程。只有2个子进程存续，我们的rust doc服务才能访问。所以oneshot，simple等都不行。

简单验证一下猜想：

```bash
$ ps x | grep rust
    403 ?        Sl     0:05 /home/marly/.cargo/bin/mdbook serve -n 0.0.0.0 -p 3000 /home/marly/Documents/rust/trpl-zh-cn
    404 ?        Sl     0:05 /home/marly/.cargo/bin/mdbook serve -n 0.0.0.0 -p 4000 /home/marly/Documents/rust/rust-by-example-cn
  63046 pts/0    S+     0:00 grep rust
```

验证成功。再顺便看看进程的owner：

```bash
$ stat -c '%U' /proc/403 /proc/404
marly
marly
```
符合预期。