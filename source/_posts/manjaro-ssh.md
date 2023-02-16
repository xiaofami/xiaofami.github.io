---
title: Manjaro使用密钥登录SSH
date: 2023-02-16 08:59:42
tags:
- R3300-M
- Manjaro ARM
- SSH
index_img: /img/ssh.png
---
为了方便在外面连接家里的Manjaro ARM小机，我打算把22端口转发出去，于是安全性有必要加强，使用密钥登录取代弱口令。
# 生产密钥

```bash
$ ssh-keygen -t rsa
Generating public/private rsa key pair.
Enter file in which to save the key (/home/marly/.ssh/id_rsa):
Created directory '/home/marly/.ssh'.
Enter passphrase (empty for no passphrase):
Enter same passphrase again:
Your identification has been saved in /home/marly/tmp/id_rsa
Your public key has been saved in /home/marly/tmp/id_rsa.pub
The key fingerprint is:
SHA256:FNPW7n5ub8l5PKn0/DZXQ7yK0ZqJyZJ9pLVFL6l6A2I marly@manjaro
The key's randomart image is:
+---[RSA 3072]----+
|        o. .     |
|         oo .    |
|        .. .  .  |
|       .    .. o |
|        S  .o + .|
|       E . +.= +.|
|      . = B.X.+.*|
|       o * @o.=B*|
|        ..+ .=o*O|
+----[SHA256]-----+
$ ls ~/.ssh
id_rsa  id_rsa.pub
$ cat ~/.ssh/id_rsa.pub>>authorized_key
```
公钥放在服务器上，私钥存放在本地用于登录，不要在服务器上存放。
另外权限需要格外注意，如果配置不当会产生许多问题，建议按如下配置（id_rsa不建议存储在服务器上）：
```bash
$ chmod 700 ~/.ssh
$ chmod 600 ~/.ssh/id_rsa
$ chmod 600 ~/.ssh/id_rsa.pub
$ chmod 600 ~/.ssh/authroized_keys
```
# 修改ssh_config
```bash
$ sudo vim /etc/ssh/sshd_config
```
主要确认这两行内容：

```config
AuthorizedKeysFile .ssh/authorized_keys
PasswordAuthentication no
```
最后执行
```bash
$ sudo systemctl restart sshd.service
```
重启服务就完事了。