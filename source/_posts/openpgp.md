---
title: openpgp智能卡使用
date: 2024-8-12 09:14:29
tags:
- Gnuk
- ST-LINK V2
- openpgp
index_img: /img/yubico.jpg
---

参考教程配置好了自己的第一张 **openpgp** 智能卡。整个流程不复杂，主要包含如下流程：

1. 在电脑上生成主密钥，建议设置密码；
2. 在电脑上为主密钥添加3个子密钥，分别为 **Signature key**，**Encryption key** 和 **Authentication key** ；
3. 备份主密钥和子密钥到冷存储；
4. 将3个子密钥转移到 **openpgp** 智能卡；
5. 删除电脑上的私钥。

# 生成主密钥
```bash
$ gpg --quick-generate-key   'pico <pico@tccmu.com>'  ed25519 cert never
We need to generate a lot of random bytes. It is a good idea to perform
some other action (type on the keyboard, move the mouse, utilize the
disks) during the prime generation; this gives the random number
generator a better chance to gain enough entropy.
gpg: /home/pico/.gnupg/trustdb.gpg: trustdb created
gpg: directory '/home/pico/.gnupg/openpgp-revocs.d' created
gpg: revocation certificate stored as '/home/pico/.gnupg/openpgp-revocs.d/AF56371B281E0063A9310FC32D946EC9EEAD7B06.rev'
public and secret key created and signed.

pub   ed25519 2024-08-12 [C]
      AF56371B281E0063A9310FC32D946EC9EEAD7B06
uid                      pico <pico@tccmu.com>
```

记住 **AF56371B281E0063A9310FC32D946EC9EEAD7B06** 这个长度40的字符串，它的后16位是 **2D946EC9EEAD7B06** ，一会儿都要用到。
# 生成子密钥
```bash
gpg --quick-add-key AF56371B281E0063A9310FC32D946EC9EEAD7B06 ed25519 sign never
gpg --quick-add-key AF56371B281E0063A9310FC32D946EC9EEAD7B06 cv25519 encr never
gpg --quick-add-key AF56371B281E0063A9310FC32D946EC9EEAD7B06 ed25519 auth never
```

需要根据提示输入主密钥密码。有效期可以自由设置，比如 **1y** 就是1年，**never** 为永不过期。

现在查看一下密钥概况：

```bash
$ gpg -K
gpg: checking the trustdb
gpg: marginals needed: 3  completes needed: 1  trust model: pgp
gpg: depth: 0  valid:   1  signed:   0  trust: 0-, 0q, 0n, 0m, 0f, 1u
/home/pico/.gnupg/pubring.kbx
-----------------------------
sec   ed25519 2024-08-12 [C]
      AF56371B281E0063A9310FC32D946EC9EEAD7B06
uid           [ultimate] pico <pico@tccmu.com>
ssb   ed25519 2024-08-12 [S]
ssb   cv25519 2024-08-12 [E]
ssb   ed25519 2024-08-12 [A]
```
主密钥与子密钥均已成功创建。

# 备份密钥
在将密钥转移到 **openpgp** 智能卡前，先备份密钥：

```bash
gpg -o pico.pri.gpg --export-secret-keys 2D946EC9EEAD7B06 #备份主密钥
gpg -o pico.sub.gpg --export-secret-subkeys 2D946EC9EEAD7B06 # 备份子密钥
```
同样需要输入主密钥密码。一些教程采用了 **-a --export-secret-key** 一次导出全部密钥，也是没有问题的。

# 生成撤销证书
```bash
$ gpg -o pico.rev.asc --gen-revoke 2D946EC9EEAD7B06

sec  ed25519/2D946EC9EEAD7B06 2024-08-12 pico <pico@tccmu.com>

Create a revocation certificate for this key? (y/N) y
Please select the reason for the revocation:
  0 = No reason specified
  1 = Key has been compromised
  2 = Key is superseded
  3 = Key is no longer used
  Q = Cancel
(Probably you want to select 1 here)
Your decision? 0
Enter an optional description; end it with an empty line:
>
Reason for revocation: No reason specified
(No description given)
Is this okay? (y/N) y
ASCII armored output forced.
Revocation certificate created.
```

将 **pico.pri.gpg**、**pico.sub.gpg**、**pico.rev.asc** 三个文件复制到冷存储中保存好，以防天灾人祸导致物理密钥损毁。

# 转移密钥到 openpgp 智能卡
通过 `gpg --card-status` 命令正确获取到 **openpgp** 智能卡信息后，便可以进行密钥转移操作
```bash
$ gpg --edit-key 2D946EC9EEAD7B06
gpg (GnuPG) 2.4.4; Copyright (C) 2024 g10 Code GmbH
This is free software: you are free to change and redistribute it.
There is NO WARRANTY, to the extent permitted by law.

Secret key is available.

sec  ed25519/2D946EC9EEAD7B06
     created: 2024-08-12  expires: never       usage: C
     trust: ultimate      validity: ultimate
ssb  ed25519/CF5A73D0BA2FC74D
     created: 2024-08-12  expires: never       usage: S
ssb  cv25519/28C26521533835B5
     created: 2024-08-12  expires: never       usage: E
ssb  ed25519/11C45E2A6DCE1712
     created: 2024-08-12  expires: never       usage: A
[ultimate] (1). pico <pico@tccmu.com>
```

分别用 **key** 选中 1,2,3 号密钥，然后执行 **kettocard** 转移到**openpgp**智能卡，最后save保存。

# 删除密钥
```bash
gpg --delete-secret-keys 2D946EC9EEAD7B06
```

执行完毕后 `gpg -K` 命令便无法查询到该密钥。**pico.pri.gpg**、**pico.sub.gpg**、**pico.rev.asc** 三个文件也要从电脑上彻底删除。

# 智能卡其他设置
执行 `gpg --edit-card` 进入卡片编辑，进行修改pin、添加公钥url等操作。

# 参考材料
1. [An abridged guide to using ed25519 PGP keys with GnuPG and SSH](https://musigma.blog/2021/05/09/gpg-ssh-ed25519.html) 本文生成密钥部分借鉴于此，特点是没有用引导程序而是手动创建；
2. [GPG 物理密钥从安装到日常使用](https://blog.lamgc.moe/2021/02/26/gpg-smart-card-from-installation-to-use-tutorial/) 本文中密钥导出备份以及转移到卡片部分借鉴于此；
3. [GnuPG 使用指南](https://blog.moe233.net/posts/18974f8b/) 深度好文，读了这篇文章我的这篇就没必要看了 ... 不过写都写了，还是发出来吧。