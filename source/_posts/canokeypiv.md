---
title: Canokey使用PIV解锁bitlocker
date: 2024-12-25 21:42:49
tags:
- Archlinux
- EndeavourOS
- Canokey
- bitlocker
- openssl
index_img: https://upload.wikimedia.org/wikipedia/ru/d/de/BitLocker_icon.png
---
Windows支持使用智能卡作为bitlocker的解锁设备，自然Canokey也不例外，具体过程如下。
# 安装yubico-piv-tool
```bash
sudo pacman -S yubico-piv-tool #Archlinux
sudo apt install yubico-piv-tool # Ubuntu
```

验证能否正常读取：

```bash
yubico-piv-tool -r canokeys -a status

Version:        5.4.0
Serial Number:  【不给看】
CHUID:  【不给看】
CCC:    【不给看】
Slot 9a:
        Algorithm:      RSA2048
        Subject DN:     CN=【不给看】
        Issuer DN:      CN=【不给看】
        Fingerprint:    【不给看】
        Not Before:     Dec 24 08:32:34 2024 GMT
        Not After:      Dec 24 08:42:33 2123 GMT
PIN tries left: 3
```

我已经把证书导入了9a插槽，输出结果大致如上。

有一点需要注意。在Windows系统中，如果你之前执行了`gpg --card-status`查看opengpg模块，那么可能会遇到这种情况：

```bash
yubico-piv-tool -r canokeys -a status

Failed to connect to yubikey: Error in PCSC call.
Try removing and reconnecting the device.
```

解决方法很简单，重新插拔Canokey物理密钥，然后再执行即可。猜测执行`gpg --card-status`后PCSC端口被占用，导致*yubico-piv-tool*读取智能卡失败。

Linux中也存在类似现象。执行`yubico-piv-tool -r canokeys -a status`后，第一次运行`gpg --card-status`会提示`gpg: OpenPGP card not available: General error`，只需再执行一次`gpg --card-status`就正常了。
# 创建证书
创建openssl配置文件。名字随意，比如`2.cof`：

```2.cnf
[ req ]
default_bits = 2048
prompt = no
encrypt_key = no
default_md = sha384
distinguished_name = dn
days=3650

[ dn ]
C=CN
ST=按需输入
L=按需输入
O=按需输入
OU=按需输入
CN=按需输入
emailAddress = 按需输入
```

解释（参考：[使用OpenSSL工具生成CSR文件](https://support.huawei.com/enterprise/zh/doc/EDOC1100296985/5ae80acf)）：
* C：Country Name，国家名称，例如：CN。（可选）
* ST：State or Province Name，州或省的名称，例如：JiangSu。（可选）
* L：Locality Name，城市名称，例如：NanJing。（可选）
* O：Organization Name，公司名称，例如：CMCC。（可选）
* OU：Organizational Unit Name，部门名称，例如：06DC-esight。（可选）
* CN：Common Name，证书使用者的名称，填写访问的具体域名，不支持通配符场景。

保存后，在当前目录执行
```bash
openssl req -new -x509 -config 2.cnf  -keyout server.key -out server.csr -addext extendedKeyUsage=1.3.6.1.4.1.311.67.1.1 -addext keyUsage=keyEncipherment -days 3650
openssl pkcs12 -export -out server.pfx -inkey server.key -in server.csr
```
即可得到**server.pfx**文件，这正是我们想要的。

需要注意，上面的配置文件中不要试图用**req_extensions**把extendedKeyUsage和keyUsage放进配置文件，实测无效。按照[Missing X509 extensions with an openssl-generated certificate](https://security.stackexchange.com/questions/150078/missing-x509-extensions-with-an-openssl-generated-certificate)说法，

    Extensions in certificates are not transferred to certificate requests and vice versa

有几种变通方式，本文中使用了 **-addext** 进行追加。可以输出 **server.csr** 验证是否成功添加：

```bash
openssl x509 -in server.csr -text -noout 
（节选）
        X509v3 extensions:
            X509v3 Extended Key Usage:
                1.3.6.1.4.1.311.67.1.1
            X509v3 Key Usage:
                Key Encipherment
            X509v3 Subject Key Identifier:
```

可见 **extendedKeyUsage** 与 **extendedKeyUsage** 已经被正确添加到证书中。
# 导入Canokey
```bash
yubico-piv-tool -r canokeys -s 9a -i server.pfx -KPKCS12 -a import-key -a import-cert #放到了9a插槽里，这个有什么统一规范吗
yubico-piv-tool -r canokeys -a set-chuid # Canokey官方文档建议
```
至此Canokey就可以插到Windows电脑上用于设置解锁bitlocker了。在Windows系统中，使用自签证书需要修改注册表键值，可以参考[Canokey PIV 应用之 Bitlocker 磁盘加密](https://hui-shao.com/canokey-piv-bitlocker/)和[Setting Up BitLocker with YubiKey as Smart Card](https://nathanaelfrey.com/2021/01/09/setting-up-bitlocker-with-yubikey-as-smart-card/)，讲得很具体。
