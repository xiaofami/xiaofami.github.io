---
title: Linux命令行创建用户并加入组
date: 2021-09-27 15:30:25
tags:
- Manjaro
- user
- group
---

以下为在Manjaro ARM下通过命令行创建用户“marly”全过程，各步骤已做分解。

1. 查看useradd默认模板

```bash
sudo useradd -D

GROUP=984
HOME=/home
INACTIVE=-1
EXPIRE=
SHELL=/bin/bash
SKEL=/etc/skel
CREATE_MAIL_SPOOL=no
```
2. 创建用户

```bash
sudo useradd marly
```
3. 创建密码
```bash
sudo passwd marly
```
4. 创建home目录
useradd默认情况下不会创建home目录（尽管会根据模板写入passwd文件），所以需要自行创建。
mkhomedir_helper用法：
```bash
mkhomedir_helper {user} [umask [ path-to-skel ]]
```
第一个参数用户名必选，umask与skel路径可选。默认umask为0022，默认skel路径为/etc/skel（模板里可以看到）。skel里面的内容会被复制一份到marly的家目录中。
```bash
sudo mkhomedir_helper marly
```
5. 添加用户备注
勤于写备注是好习惯：
```bash
sudo usermod -c "guess who is marly" marly
```
6. 查看用户组
查看当前用户group：
```bash
groups
```
等价于
查看当前用户group：
```bash
groups $USER
```

查看其他用户group：
```bash
$ groups git

git
```
不需要特殊权限即可查看。

7. 添加用户到group：
```bash
sudo usermod -aG existgroup newuser
```

-aG为追加用户到现有组。

新创建的用户默认会自动创建并加入与用户名同名的组，为了实现各种功能，需要将其添加到更多的组。例如，需要赋予marly管理员权限，就需要将其加入wheel组：
```bash
sudo usermod -aG wheel marly
```
这样marly就有权使用sudo命令了。在debian中sudo组替代了wheel。