---
title: 使用opengpg智能卡认证SSH登录
date: 2024-12-20 22:33:55
tags:
- Archlinux
- EndeavourOS
- nRF52840
- Canokey
- SSH
index_img: https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSQKhu4nmsbK_PpR5Q7JcpLj-KOvqdWmjXLMsJa5ed0UHavCc2vd-s_0E7dI7BtYCvj_w&usqp=CAU
---
# 远程服务器配置
远程服务器的设置比较简单，在本地将负责*Authentication*子密钥的公钥导出，添加到服务器 ** ~/.ssh/authorized_keys** 文件即可，记得重启SSH服务，或者直接重启系统。在实验成功之前，不要禁用掉之前的登录方式，避免把自己锁在外面。

这个公钥可以在已经插入智能卡的情况下，通过`ssh-add -L`查看，喜欢GUI界面的也可以在**kleopatra**中右键导出。

至此服务器端配置结束，下面来配置客户端。
# Archlinux系统配置方法
参考自[Yubikey 开箱上手](https://www.kxxt.dev/blog/yubikey-oobe/)：

编辑 **~/.bashrc**，加入以下内容：
```bash
export GPG_TTY="$(tty)"
export SSH_AUTH_SOCK=$(gpgconf --list-dirs agent-ssh-socket)
gpgconf --launch gpg-agent
```
Log out后再回来，提前插好智能卡然后执行ssh命令登录服务器，会自动弹出输入PIN码窗口，这个PIN码是Canokey中opengpg模块的PIN码，默认为123456，输入并确认即可登录成功。

# Windows 11系统配置方法
参考自[在 Windows 10 上用 GPG 完成 SSH 认证](https://lab.jinkan.org/2021/08/01/using-gpg-for-ssh-authentication-on-windows-10/)，大体步骤如下：
## 安装配置[Gpg4win](https://www.gpg4win.org/download.html)
假设你采用了默认安装路径，那么在`C:\Program Files (x86)\Gpg4win\bin\`目录中，存在一个名为**gpgolconfig.exe**的二进制程序，将它打开，逐次打开**GnuPG System（Technical）** - **Private Keys**页面，找到**Options controlling the configuration**区域，选中 **Enable ssh support**和**Enable putty support**并保存。

打开`%APPDATA%\gnupg\gpg-agent.conf`，加入这样一行：
```bash
enable-putty-support
```
查看负责*Authentication*子密钥的KeyGrip，注意是最下面那个：
```bash
PS C:\> gpg -K --with-keygrip
sec#  rsa4096 2020-03-04 [C]
      7046C3E8C8DD73F814FDE289E6ED69D1C9149F9B
      Keygrip = <40位10进制表示>
uid           [ultimate] yinian <yinian@jinkan.org>
ssb   ed25519 2020-03-04 [S] [expires: 2023-03-04]
      Keygrip = <40位10进制表示>
ssb   cv25519 2020-03-04 [E] [expires: 2023-03-04]
      Keygrip = <40位10进制表示>
ssb   ed25519 2020-03-04 [A] [expires: 2023-03-04]
      Keygrip = <40位10进制表示>
```
复制KeyGrip后粘贴到`%APPDATA%\gnupg\sshcontrol`即可。

笔者按：上述配置文件方式感觉有些问题。参见Archwiki中[Using_a_PGP_key_for_SSH_authentication](https://wiki.archlinux.org/title/GnuPG#Using_a_PGP_key_for_SSH_authentication)一文，文中明确指出，在GPG密钥存储于物理卡片情况下没必要将keygrip添加到sshcontrol文件。另外对`%APPDATA%\gnupg\gpg-agent.conf`的修改也有待推敲。总而言之，我感觉完全没必要修改`%APPDATA%\gnupg\gpg-agent.conf`和`%APPDATA%\gnupg\sshcontrol`这两个配置文件，有空时针对性测试一下。
## 启动gpg-agent
打开CMD窗口，执行以下命令：
```cmd
PS C:\> gpg-connect-agent killagent /bye
OK closing connection

PS C:\> gpg-connect-agent /bye
gpg-connect-agent: no running gpg-agent - starting 'C:\Program Files (x86)\Gpg4win\..\GnuPG\bin\gpg-agent.exe'
gpg-connect-agent: waiting for the agent to come up ... (5s)
gpg-connect-agent: connection to agent established
```

笔者按：Windows 11系统中，**gpg-agent**每次开机后需要手动启动，所以参考教程中的“重启gpg-agent”说法似有不妥。另外参考[How can I restart gpg-agent?](https://superuser.com/questions/1075404/how-can-i-restart-gpg-agent)以及[Reload the agent](https://wiki.archlinux.org/title/GnuPG#Reload_the_agent)，
```cmd
gpg-connect-agent reloadagent /bye
```
这一命令似乎更为优雅，这也正是archwiki所推荐的方式。
# 安装SSH客户端
[MobaXterm](https://mobaxterm.mobatek.net/)即可。无须特殊配置，提供服务器地址、用户名、端口号即可进行SSH登录。与Archlinux情形相同，登录时会自动弹出PIN输入框，输入并确认即可完成登录。

所参考的教程中用到的是[putty-cac](https://github.com/NoMoreFood/putty-cac)，经测试同样无须任何额外配置即可完成SSH登录。
# Github commit 签名
参考自[Telling Git about your signing key](https://docs.github.com/en/authentication/managing-commit-signature-verification/telling-git-about-your-signing-key)
```bash
$ gpg --list-secret-keys --keyid-format=long
/Users/hubot/.gnupg/secring.gpg
------------------------------------
sec   4096R/3AA5C34371567BD2 2016-03-10 [expires: 2017-03-10]
uid                          Hubot <hubot@example.com>
ssb   4096R/4BB6D45482678BE3 2016-03-10
```
记住 *3AA5C34371567BD2* 这个 **GPG key ID**，然后执行
```bash
git config --global user.signingkey 3AA5C34371567BD2
git config --global commit.gpgsign true
git config --global tag.gpgSign true
git config --global gpg.program gpg2
```
另外在GitHub设置页面中，不要忘记分别添加SSH Key和GPG Key，这两个是不一样的。SSH Key用于与Github通信，GPG Key负责commit签名。
