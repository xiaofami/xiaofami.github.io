---
title: 使用manjaro-arm-tools定制Manjaro ARM镜像
date: 2023-02-06 10:41:46
tags:
- R3300-M
- Manjaro ARM
---
# 安装
```bash
sudo pacman -S manjaro-arm-tools
```
# 下载配置文件
```bash
sudo getarmprofiles -f
```
# 创建配置文件
```bash
cd /usr/share/manjaro-arm-tools/profiles/arm-profiles/devices/
```
随便复制一个然后修改就可以了。我创建的r3300m内容如下：

```config
## Maintained by Spikerguy ##

# Kernel and bootloader stuff
linux
uboot-vim2
plymouth
plymouth-theme-manjaro

# Video driver

# Other device specific packages
crda
fbset
kvim2-firmware
generic-post-install
vim2-post-install
```

基本上就是vim2的精简，然后用主线内核替换了aml内核。自己的配置文件注意备份，每次执行 `sudo getarmprofiles -f` 都会从服务器重新同步配置并清除本地修改内容，切记切记。

# 生成镜像

```bash
sudo buildarmimg -d r3300m -e minimal -v 23.02 -b stable
````

建议新建一个screen session进行以防SSH连接意外中断前功尽弃，同时解决好网络问题否则rootfs和软件包下不动。输出信息节选如下：

```bash
==> WARNING: consolefont: no font found in configuration
  -> Running build hook: [block]
  -> Running build hook: [filesystems]
  -> Running build hook: [fsck]
==> Generating module dependencies
==> Creating gzip-compressed initcpio image: /boot/initramfs-linux.img
==> Image generation successful
(15/16) Reloading system bus configuration...
  Skipped: Current root is not booted.
(16/16) Updating fontconfig cache...
  -> Generating the list of mirrors...
  -> Enabling services...
Enabling service systemd-networkd.service...
Enabling service dhcpcd.service...
Enabling service sshd.service...
Enabling service iwd.service...
Enabling service zswap-arm.service...
Enabling service systemd-oomd.service...
Enabling service irqbalance.service...
Service bootsplash-hide-when-booted.service not found in rootfs, skipping
Service bootsplash-show-on-shutdown.service not found in rootfs, skipping
  -> Applying overlays for minimal edition...
  -> Setting up system settings...
Enabling SSH login for root user for headless setup...
Enabling autologin for first setup...
Correcting permissions from overlay...

==> Creating package list /var/cache/manjaro-arm-tools/img/Manjaro-ARM-minimal-r3300m-23.02-pkgs.txt...
  -> Removing unwanted files from rootfs...
  -> Pruning and unmounting package cache...
==> no candidate packages found for pruning

==> Creating minimal edition rootfs image for r3300m completed successfully

==> Creating minimal edition image for r3300m...
  -> Creating ext4 partitions...
  -> Copying files to image...
  -> Writing the boot loader images...
Boot PARTUUID is 4f9106b7-b65d-487f-8c7d-9d44a4636acd...
Root PARTUUID is cb0d5979-0c87-498b-aaae-6ea8f1423feb...
Root UUID is 44f9ece4-f14d-40cb-bb37-7a0317e76f0f...
  -> Cleaning up image...
  -> Compressing Manjaro-ARM-minimal-r3300m-23.02.img with xz...
xz: Reduced the number of threads from 4 to 1 to not exceed the memory usage limit of 233 MiB
Manjaro-ARM-minimal-r3300m-23.02.img: 363.6 MiB / 2,820.0 MiB = 0.129, 1.3 MiB/s, 36:23
  -> Removing rootfs_aarch64...

==> Time elapsed: 48.47 minute(s)
```

生成镜像花费了48分钟，其中足足36分钟用在了压缩镜像上。受内存限制，xz只利用了一个处理器线程，拖慢了压缩速度。有条件还是用PC操作为宜。

镜像位于 `/var/cache/manjaro-arm-tools/img/` ：
```bash
ls -lh /var/cache/manjaro-arm-tools/img/
total 364M
-rw-rw-rw- 1 root root 364M Feb  7 10:18 Manjaro-ARM-minimal-r3300m-23.02.img.xz
-rw-r--r-- 1 root root 3.9K Feb  7 10:13 Manjaro-ARM-minimal-r3300m-23.02-pkgs.txt
```
镜像总共包含软件包205个，十分精简，这几天我抽空测试下能否正常启动。

[manjaro-arm-tools](https://gitlab.manjaro.org/manjaro-arm/applications/manjaro-arm-tools)使用方式作为附录全文转载，供参考：

# Manjaro ARM Tools
Contains scripts and files needed to build and manage manjaro-arm packages and images.

This software is available in the Manjaro repository.

*These tools only work on Manjaro based distributions!*


## Known issues
Check the [Issues](https://gitlab.manjaro.org/manjaro-arm/applications/manjaro-arm-tools/-/issues) page.

## Dependencies
These scripts rely on certain packages, other than what's in the `base` package group, to be able to function. These packages are:
* parted (arch repo)
* libarchive (arch repo)
* git (arch repo)
* qemu-user-static-binfmt (arch repo)
* dosfstools (arch repo)
* pacman (arch repo)
* polkit (arch repo)
* gnugpg (arch repo)
* wget (arch repo)
* zstd (arch repo) - unzstd used for early package verification and zstd image compression
* systemd-nspawn with support for `--resolv-conf=copy-host` (arch repo)

### Optional Dependencies
* gzip (arch repo) (for `builddockerimg`)
* docker (arch repo) (for `builddockkerimg`)
* mktorrent (arch repo) (for torrent support in `deployarmimg`)
* rsync (arch repo) (for `deployarmimg`)
* bmap-tools (AUR or manjaro repo) (for BMAP support in `buildarmimg`)
* btrfs-progs (arch repo) (for btrfs support in `buildarmimg`)
* grub-efi-arm64 (AUR) (for generic-efi image support in `buildarmimg`)

# Installation (Manjaro based distributions only)
## From Manjaro repositories (both x64 and aarch64)
Simply run `sudo pacman -S manjaro-arm-tools`.

## From gitlab (tagged or GIT version)
* Download the `.zip` or `.tar.gz` file from https://gitlab.manjaro.org/manjaro-arm/applications/manjaro-arm-tools.
* Extract it.
* Copy the contents of `lib/` to `/usr/share/manjaro-arm-tools/lib/`.
* Copy the contents of `bin/` to `/usr/bin/`. Remember to make them executable.
* Create `/var/lib/manjaro-arm-tools/pkg` folder.
* Create `/var/lib/manjaro-arm-tools/img` folder.
* Create `/var/lib/manjaro-arm-tools/tmp` folder.
* Create `/var/cache/manjaro-arm-tools/img` folder.
* Create `/var/cache/manjaro-arm-tools/pkg` folder.
* Install `binfmt-qemu-static` package and make sure `systemd-binfmt` is running

# Usage
## buildarmpkg
This script is used to create packages for ARM architectures.
It assumes you have filled out the PACKAGER section of your `/etc/makepkg.conf`.

Options inside `[` `]` are optional. Use `-h` to see what the defaults are.

**Syntax**

```
sudo buildarmpkg -p package [-a architecture] [-k] [-i packages] [-b branch]
```

To use one or more local packages, put them all in the desired directory, named `packages` in the example below, before running the utility:
```
sudo buildarmpkg -p package [-a architecture] [-k] [-i packages] [-b branch]
```

To build an aarch64 package against arm-unstable branch use the following command:

```
sudo buildarmpkg -p package -a aarch64 -b unstable
```

You can also build `any` packages, which will use the aarch64 architecture to build from.

```
sudo buildarmpkg -p package -a any
```

The built packages will be copied to `$PKGDIR` as specified in `/usr/share/manjaro-arm-tools/lib/manjaro-arm-tools.conf` and placed in a subdirectory for the respective architecture.
Default package destination is `/var/cache/manjaro-arm-tools/pkg/`.

## signarmpkgs
This script uses the GPG identity you have setup in your /etc/makepkg.conf to sign the packages in the current folder.

```
cd <folder with built packages>
signarmpkgs
```

## buildarmimg
For a list of supported devices and editions, please look at the Profiles repository linked below.

This script will compress the image file and place it in `/var/cache/manjaro-arm-tools/img/`

Profiles that gets used are from this [Gitlab](https://gitlab.manjaro.org/manjaro-arm/applications/arm-profiles) repository.

**Syntax**

```
sudo buildarmimg [-d device] [-e edition] [-v version] [-n] [-x] [-i packages] [-b branch] [-m] [-z compression]
```

To build a minimal image version 18.07 for the raspberry pi 3 on arm-unstable branch with bmap support:

```
sudo buildarmimg -d rpi3 -e minimal -v 18.07 -b unstable -m
```

To build a minimal version 18.08 RC1 for the odroid-c2 with a new rootfs downloaded:

```
sudo buildarmimg -d oc2 -e minimal -v 18.08-rc1 -n
```

To build an lxqt version with one or more local packages installed for the rock64:

```
sudo buildarmimg -d rock64 -e lxqt -i packages
```

To build an xfce version with one or more local packages installed for the rock64, put them all in the desired directory, named `packages` in the example below, before running the utility:

```
sudo buildarmimg -d rock64 -e xfce -i packages
```

To build a kde-plasma edition for the Pinebook Pro with btrfs filesystem:

```
sudo buildarmimg -d pbpro -e kde-plasma -p btrfs
```

To build a factory image for the Pinebook Pro, with BSP uboot:
```
sudo buildarmimg -d pbpro-bsp -e kde-plasma -f
```
A log is located at /var/log/manjaro-arm-tools/buildarmimg-$(date +%Y-%m-%d-%H:%M).log

## buildemmcinstaller (depricated)
This script does almost the same as the `buildarmimg` script.

Except that it always creates a minimal image, with an already existing image inside it, only to be used for internal storage (eMMC) deployments.

**Syntax**
```
sudo buildemmcinstaller [-d device] [-e edition] -v version [-f flashversion] [-n] [-x] [-i packages]
```

So to build an eMMC installer image for KDE Plasma 19.04 on Pinebook:
```
sudo buildemmcinstaller -d pinebook -e kde-plasma -v 19.04 -f first-emmc-flasher
```
Be aware that the device, edition and version, most already exist on the OSDN download page, else it won't work.


## buildrootfs
This script does exactly what it says it does. It builds a very small rootfs, to be used by the Manjaro ARM Installer and `buildarmimg`. Right now only supports `aarch64`.

**Syntax**
```
sudo buildrootfs
```

To build an aarch64 rootfs:
```
sudo buildrootfs
```

A log is located at /var/log/manjaro-arm-tools/buildrootfs-$(date +%Y-%m-%d-%H:%M).log

## builddockerimg
This script is similar to `buildrootfs`, except that it builds a rootfs ready for package building and turns it into a docker image, that can be uploaded to DockerHub.

**Syntax**
```
sudo builddockerimg
```
This uploads the docker file directly to the Manjaro ARM acccount on DockerHub.

A log is located at /var/log/manjaro-arm-tools/builddockerimg-$(date +%Y-%m-%d-%H:%M).log

## deployarmimg (depricated)
This script will create checksums for and upload the newly generated image. It assumes you have upload access to our OSDN server.
If you don't, you can't use this.

**Syntax**

```
deployarmimg -i image [-d device] [-e edition] [-v version] -k email@server.org [-t] [-u osdn-username]
```

To upload an image to the raspberry pi minimal 18.07 folder use with torrent:

```
deployarmimg -i Manjaro-ARM-minimal-rpi3-18.07.img.xz -d rpi3 -e minimal -v 18.07 -k email@server.org -t
```

## getarmprofiles
This script will just clone or update the current profile list in `/usr/share/manjaro-arm-tools/profiles/`.
So nothing fancy.

This would enable users to clone the profiles repository, make any changes they would like to their images and then build them locally.
So if you made changes to the profiles yourself, don't run `getarmprofiles` and you will still have your edits.

But if you messed up your profiles somehow, you can start with the repo ones with:
```
sudo getarmprofiles -f
```