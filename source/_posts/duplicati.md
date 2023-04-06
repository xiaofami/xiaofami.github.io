---
title: duplicati 试用
date: 2023-04-03 10:14:19
tags:
- Manjaro ARM
- duplicati
- docker
index_img: /img/duplicati.jpg
---
本地数据会因磁盘故障损毁，组RAID的NAS会被一窝端，云盘可能会意外泄露隐私。权衡利弊，可以将重要数据存储在NAS阵列中，加密后同步到云盘。duplicati为此提供了一套解决方案。

# Manjaro ARM本地运行
duplicati主要用于备份本机数据，所以在局域网内搭建一台备份服务器，然后给其他设备提供备份服务的想法不太完美。当然可以将远程目录挂载到本地，不过这不在讨论范围之内。
在Manjaro ARM上安装主要用于验证duplicati对aarch64的支持程度，顺便备份一些有用数据。

## 安装
```bash
yay -S duplicati-beta-bin
```
duplicati位于AUR仓库中，使用yay安装，全部选项默认即可，结束后 **Duplicati - 2.0.6.3_beta_2021-06-17** （截至2023年4月3日最新版本）便已安装完成。

## 允许局域网访问
duplicati默认只允许localhost通过8200端口访问，这带来2个问题。其一，localhost没有图形界面，自然也没有浏览器可用，无法通过页面配置。其二，8200端口与minidlna冲突，需要想办法修改。

参考[Installing Duplicati on Linux](https://duplicati.readthedocs.io/en/latest/02-installation/#installing-duplicati-on-linux)一文，进行配置：

首先停止服务：
```bash
sudo systemctl disable duplicati.service
sudo systemctl stop duplicati.service
```

配置dpulicati环境变量：
```bash
vim /etc/default/duplicati
```
加入 `DAEMON_OPTS="--webservice-interface=any --webservice-port=8600 --portable-mode"` 一行。

再修改systemd单元文件，使用上述变量：

```bash
sudo vim /usr/lib/systemd/system/duplicati.service
```

修改前：

```bash
[marly@manjaro ~]$ cat /usr/lib/systemd/system/duplicati.service
[Unit]
Description=Duplicati
After=network.target

[Service]
ExecStart=/usr/bin/mono /opt/duplicati/Duplicati.Server.exe --webservice-port=8200
Restart=on-abort
EnvironmentFile=-/etc/default/duplicati
User=duplicati
Group=duplicati

[Install]
WantedBy=default.target
```

修改后：

```bash
[marly@manjaro ~]$ cat /usr/lib/systemd/system/duplicati.service
[Unit]
Description=Duplicati
After=network.target

[Service]
ExecStart=/usr/bin/mono /opt/duplicati/Duplicati.Server.exe $DAEMON_OPTS
Restart=on-abort
EnvironmentFile=-/etc/default/duplicati
User=duplicati
Group=duplicati

[Install]
WantedBy=default.target
```

安装程序提供的单元文件虽然指定了环境文件路径，但是没有使用。改过来即可。另外注意duplicati服务以duplicati用户和组的身份执行，用于备份本地home目录会遇到权限问题，可以将上面的User和Group内容用自己的用户名和组替换。

最后启动服务：
```bash
sudo systemctl enable duplicati.service
sudo systemctl daemon-reload
sudo systemctl start duplicati.service 
```

现在即可在局域网中通过 **ip:8600** 访问管理页面。

# 在Docker中运行
duplicati的docker镜像由linuxserver维护，支持x86-64和arm64，参见[linuxserver/duplicati](https://hub.docker.com/r/linuxserver/duplicati)。

# 其他选择
[duplicacy](https://github.com/gilbertchen/duplicacy)号称是当下最先进最快的开源云备份工具，提供了linux arm64的二进制包，可以在Manjaro ARM中直接运行：

```bash
[marly@manjaro tmp]$ cd tmp
[marly@manjaro tmp]$ wget https://github.com/gilbertchen/duplicacy/releases/download/v3.1.0/duplicacy_linux_arm64_3.1.0
[marly@manjaro tmp]$ chmod +x duplicacy_linux_arm64_3.1.0

[marly@manjaro tmp]$ ./duplicacy_linux_arm64_3.1.0 -h
NAME:
   duplicacy - A new generation cloud backup tool based on lock-free deduplication

USAGE:
   duplicacy [global options] command [command options] [arguments...]

VERSION:
   3.1.0 (27FF3E)

COMMANDS:
   init         Initialize the storage if necessary and the current directory as the repository
   backup       Save a snapshot of the repository to the storage
   restore      Restore the repository to a previously saved snapshot
   list         List snapshots
   check        Check the integrity of snapshots
   cat          Print to stdout the specified file, or the snapshot content if no file is specified
   diff         Compare two snapshots or two revisions of a file
   history      Show the history of a file
   prune        Prune snapshots by revision, tag, or retention policy
   password     Change the storage password
   add          Add an additional storage to be used for the existing repository
   set          Change the options for the default or specified storage
   copy         Copy snapshots between compatible storages
   info         Show the information about the specified storage
   benchmark    Run a set of benchmarks to test download and upload speeds
   help, h      Shows a list of commands or help for one command

GLOBAL OPTIONS:
   -verbose, -v                 show more detailed information
   -debug, -d                   show even more detailed information, useful for debugging
   -log                         enable log-style output
   -stack                       print the stack trace when an error occurs
   -no-script                   do not run script before or after command execution
   -background                  read passwords, tokens, or keys only from keychain/keyring or env
   -profile <address:port>      enable the profiling tool and listen on the specified address:port
   -comment                     add a comment to identify the process
   -suppress, -s <id> [+]       suppress logs with the specified id
   -print-memory-usage          print memory usage every second
   -help, -h                    show help
```
它支持通过本地磁盘、SFTP、WebDav、Dropbox、Google Drive、Microsoft OneDrive等方式进行数据备份，结合安装简单与性能优势，看起来比duplicati更好用。