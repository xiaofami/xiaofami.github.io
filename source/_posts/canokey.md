---
title: nRF52840刷CanoKey 
date: 2024-8-13 16:09:49
tags:
- CanoKey
- nRF52840
- E104BT5040U
index_img: /img/E104BT5040U.jpg
---

先前给**STM32F103C8T6**成功刷入了**Gnuk**固件，测试各项功能正常。不过受限于自身配置，**STM32F103C8T6**能实现的功能比较有限，**Gnuk**项目也已停滞多年，偶然间发现了给 **nRF52840** 刷 **CanoKey** 的一个项目，准备动手试一试。

项目地址：https://github.com/canokeys/canokey-nrf52

# 硬件
参照项目说明，淘宝62元下单两只 **EBYTE E104BT5040U** 。具体规格参见[于此](https://www.ebyte.com/product-view-news.html?id=1030)。
# 固件编译
编译环境为Windows 11 WSL2，Ubuntu 24.04。

之前编译Gnuk时编译环境已搭建完毕，不需要安装其他依赖。不过注意需要手动为**python**创建符号链接，否则编译程序调用**python**命令时会报错：

```bash
sudo ln -s /usr/bin/python3 /usr/bin/python
```

常规拉取源码并配置：

```bash
$ git clone https://github.com/canokeys/canokey-nrf52
$ cd canokey-nrf52/
$ git submodule update --init --recursive
$ mkdir build
$ cd build
$ cmake -DCROSS_COMPILE=/usr/bin/arm-none-eabi- -DCMAKE_TOOLCHAIN_FILE=../toolchain.cmake -DCMAKE_BUILD_TYPE=Release ..

-- The C compiler identification is GNU 13.2.1
-- The ASM compiler identification is GNU
-- Found assembler: /usr/bin/arm-none-eabi-gcc
-- Detecting C compiler ABI info
-- Detecting C compiler ABI info - done
-- Check for working C compiler: /usr/bin/arm-none-eabi-gcc - skipped
-- Detecting C compile features
-- Detecting C compile features - done
-- NRF5_SDK_DIR: /home/pico/canokey-nrf52//nrf_sdk/nRF5_SDK_17.1.0_ddde560
Please download the 17.1.0 version SDK from https://www.nordicsemi.com/Products/Development-software/nRF5-SDK/Download#infotabs
  and extract it to /home/pico/canokey-nrf52//nrf_sdk/nRF5_SDK_17.1.0_ddde560
CMake Error at nrf_sdk/nRF5_SDK.cmake:9 (message):
  NRF5 SDK not found
Call Stack (most recent call first):
  CMakeLists.txt:47 (include)
```

按照提示下载对应版本 **SDK** 压缩包，我这里需要下载 **nRF5_SDK_17.1.0_ddde560.zip** ，然后丢到 `canokey-nrf52\nrf_sdk/` 目录中，**unzip** 即可。完毕后会得到 `canokey-nrf52\nrf_sdk\nRF5_SDK_17.1.0_ddde560` ，然后重新执行**cmake**命令：

```bash
~/canokey-nrf52/build$ cmake -DCROSS_COMPILE=/usr/bin/arm-none-eabi- -DCMAKE_TOOLCHAIN_FILE=../toolchain.cmake -DCMAKE_BUILD_TYPE=Release ..
-- NRF5_SDK_DIR: /home/pico/canokey-nrf52//nrf_sdk/nRF5_SDK_17.1.0_ddde560
-- Found PkgConfig: /usr/bin/pkg-config (found version "1.8.1")
patching file include/mbedtls/config.h
patching file include/mbedtls/ecp.h
patching file library/ecp_curves.c
patching file library/version_features.c
patching file programs/test/query_config.c
patching file include/mbedtls/config.h
patching file include/mbedtls/ecp.h
patching file library/ecp_curves.c
patching file library/version_features.c
patching file programs/test/query_config.c
patching file include/mbedtls/ecp.h
patching file library/ecp.c
patching file include/mbedtls/ecp.h
patching file library/ecp.c
patching file tests/suites/test_suite_ecp.data
patching file library/ecp.c
CMake Deprecation Warning at canokey-core/canokey-crypto/patched/mbedtls/CMakeLists.txt:23 (cmake_minimum_required):
  Compatibility with CMake < 3.5 will be removed from a future version of
  CMake.

  Update the VERSION argument <min> value or use a ...<max> suffix to tell
  CMake that the project does not need compatibility with older versions.


-- Found Python3: /usr/bin/python3 (found version "3.12.3") found components: Interpreter
-- Performing Test C_COMPILER_SUPPORTS_WFORMAT_SIGNEDNESS
-- Performing Test C_COMPILER_SUPPORTS_WFORMAT_SIGNEDNESS - Success
-- Configuring done (1.3s)
-- Generating done (0.1s)
-- Build files have been written to: /home/pico/canokey-nrf52/build
```

最后编译固件：
```bash
make canokey_flash.uf2
```

build目录中，需要关注 **canokey.hex** （大小439K）与 **canokey_flash.uf2** （大小312K）两个文件。按照项目说明，还应当自行编译并刷入[Adafruit_nRF52_Bootloader](https://github.com/canokeys/canokey-nrf52)这个bootloader。这个bootloader支持U盘拖曳形式刷**UF2**格式固件，非常便利。不过参照 [为 nRF52840 Dongle 刷入 CanoKey 固件](https://kwaa.dev/canokey-nrf52)一文，如果不想刷bootloader，也可以用[nRF Connect for Desktop](https://www.nordicsemi.com/Products/Development-tools/nrf-connect-for-desktop)写入**canokey.hex**。该网友相关描述如下：

> 下载 nRF Connect for Desktop，打开 Programmer 选中设备（正确的会正常显示 Device memory layout，没记错的话叫 DFU Bootloader），把之前的 canokey.hex 文件扔进去点击 Write 按钮。搞定！

**canokey.hex**比**canokey_flash.uf2**固件体积整整大出 **40\%**，尚不清楚差在哪里，项目对此未作说明。

> canokey.hex is a raw firmware file in text format, so it's bigger than binary formats. Flash tools such as J-Link and DAP-Link recognize this format. —by z4yx 

# bootloader编译
## 搭建编译环境
首先配置编译环境，需要额外安装一些依赖：

按照README安装[Nordic's nRF5x Command Line Tools](https://www.nordicsemi.com/Software-and-Tools/Development-Tools/nRF-Command-Line-Tools)
```bash
$ wget https://nsscprodmedia.blob.core.windows.net/prod/software-and-other-downloads/desktop-software/nrf-command-line-tools/sw/versions-10-x-x/10-24-2/nrf-command-line-tools_10.24.2_amd64.deb
$ sudo dpkg -i ./nrf-command-line-tools_10.24.2_amd64.deb
Selecting previously unselected package nrf-command-line-tools.
(Reading database ... 153542 files and directories currently installed.)
Preparing to unpack .../nrf-command-line-tools_10.24.2_amd64.deb ...
Unpacking nrf-command-line-tools (10.24.2) ...
Setting up nrf-command-line-tools (10.24.2) ...

=============================================================
The J-Link SW and documentation package is required for nrf command line tools to work.
To install the version of J-Link that was tested and verified with nrf command line tools execute one of the following:
sudo apt install /opt/nrf-command-line-tools/share/JLink_Linux_V794e_x86_64.deb --fix-broken

$ sudo apt install /opt/nrf-command-line-tools/share/JLink_Linux_V794e_x86_64.deb --fix-broken
```
再安装其他依赖：
```bash
sudo apt-get install python3-intelhex pipx
pipx install adafruit-nrfutil
```

装好后重启一次terminal使环境变量生效，编译环境至此就搭建好了。
## 拉取源码
```bash
sudo apt install python3-intelhex
git clone https://github.com/adafruit/Adafruit_nRF52_Bootloader
cd Adafruit_nRF52_Bootloader
git submodule update --init
```
## 编译
先测试编译环境是否正常：
```bash
$ make BOARD=feather_nrf52840_express all

*****************省略***********************

linker garbage collection into account
Memory region         Used Size  Region Size  %age Used
           FLASH:       32592 B        38 KB     83.76%
BOOTLOADER_CONFIG:          88 B         2 KB      4.30%
 MBR_PARAMS_PAGE:           0 B         4 KB      0.00%
BOOTLOADER_SETTINGS:          4 KB         4 KB    100.00%
             RAM:       19824 B       224 KB      8.64%
       DBL_RESET:           0 B          4 B      0.00%
          NOINIT:          62 B        128 B     48.44%
 UICR_BOOTLOADER:           4 B          4 B    100.00%
UICR_MBR_PARAM_PAGE:           4 B          4 B    100.00%
   text    data     bss     dec     hex filename
  32680     680   23310   56670    dd5e _build/build-feather_nrf52840_express/feather_nrf52840_express_bootloader-0.9.2.out
Create feather_nrf52840_express_bootloader-0.9.2.hex
Create feather_nrf52840_express_bootloader-0.9.2_nosd.hex
Create update-feather_nrf52840_express_bootloader-0.9.2_nosd.uf2
/home/pico/Adafruit_nRF52_Bootloader/lib/uf2/utils/uf2conv.py:182: SyntaxWarning: invalid escape sequence '\s'
  words = re.split('\s+', line)
Converting to uf2, output size: 73216, start address: 0x0
Wrote 73216 bytes to _build/build-feather_nrf52840_express/update-feather_nrf52840_express_bootloader-0.9.2_nosd.uf2
Create feather_nrf52840_express_bootloader-0.9.2_s140_6.1.1.hex
Zip created at _build/build-feather_nrf52840_express/feather_nrf52840_express_bootloader-0.9.2_s140_6.1.1.zip
```

正常生成了UF2固件。不过现在还不能为 **E104-BT5040U** 编译bootloader，因为这个项目当下根本就不支持**E104-BT5040U**。翻了翻历史ISSUE，有人尝试过为 **Nordic NRF52840 dongle (PCA10059)** 折腾过，不过有一些问题没能解决，开发者最终没有为其添加支持：

https://github.com/adafruit/Adafruit_nRF52_Arduino/issues/200

> we understand, it is just too difficult for us to become the support manager for a board we dont own, didn't design. it will disappoint people who have support questions and we don't want to do that. please continue to use your fork :)

**E104-BT5040U**大体上就是[Nordic NRF52840 dongle (PCA10059)](https://infocenter.nordicsemi.com/pdf/nRF52840_Dongle_User_Guide_v2.1.1.pdf)的克隆，从针脚定义到模块功能保持一致。官方放弃对**Nordic NRF52840 dongle (PCA10059)**的开发移植相当于给**E104-BT5040U**宣判了死刑。。。还是直接用 **nRF Connect for Desktop** 刷hex格式固件吧，既方便又安全。**E104-BT5040U**自带的bootloader直接编译自 **Nordic SDK 16.0**，利用**nRF Connect for Desktop**刷固件时它会校验外部bootloader（如果有）签名，如果不是**Nordic**签名就不会修改内部bootloader。
# 烧录canokey固件
将 **E104-BT5040U** 插到电脑USB口，然后运行**nRF Connect for Desktop**烧录，相比ST-Link V2简单很多，等硬件到货后回来更新烧录结果。

更新：今天 **E104-BT5040U** 到货后第一时间运行**nRF Connect for Desktop**烧录了**canokey.hex**固件。手上的这两只自带**Nordic**官方bootloader，进入bootloader模式（DFU模式）只需要按RST按钮就可以了，然后在**nRF Connect for Desktop**中便可以被正常识别然后进行烧录固件等操作。

# 初始化
刷好了固件后还不能直接使用，插在电脑USB接口上毫无动静，因为还需要进行初始化设置。参照README，这个操作需要在Linux系统中使用 **pcsc_scan** 程序和项目提供的初始化脚本，看来没办法在Windows下操作。试过[WSL直通USB](https://learn.microsoft.com/zh-cn/windows/wsl/connect-usb)的办法，但是 `usbipd list` 看不到这个设备所以行不通。打算物理机安装Linux进行后续操作。

更新：之前刷了几次固件，在Windows和Linux下都无法识别到USB设备。后来尝试用一根USB公转母延长线刷就OK了。我用来刷固件的电脑只有USB3接口，感觉是接口问题。刷好后Window右下角会弹出 **检测到Canokey Go to console.canokeys.org to connect** 的提示，此时再进入Linux系统进行后续初始化操作。

Linux发行版选用了**Archlinux**。依赖已由软件源提供，可直接用pacman安装：
```bash
sudo pacman -S pcsc-tools ccid perl-libintl-perl libfido2
```

**pcsc-tools** 一站式提供了 **pcscd**、**pcsc_scan**和**scriptor**，格外便利。

**perl-libintl-perl** 如果没有，脚本会报 *Can't locate Locale/TextDomain.pm in @INC (you may need to install the Locale::TextDomain module)* 错误。

```bash
sudo systemctl enable --now pcscd
sudo pcsc_scan
```
如无意外会出现如README所示的一堆信息。

```bash
$ ./device-config-init.sh 'Canokeys Canokey [OpenPGP PIV OATH] (00000000) 00 00'

以下信息省略，请参见README
```

这里需要关注的是 **[OpenPGP PIV OATH] (00000000)** 。刚刷好的Canokey是没有序列号的，该脚本运行后会写入序列号，而且我试过重刷固件后似乎序列号没有变化。这时再次运行 **device-config-init.sh** 脚本就需要将括号里的一堆0替换成实际序列号，否则无法初始化。这步顺利结束后，**OpenPGP**就能用了，可以通过 `gpg --card-status` 查看信息。Linux上执行 `gpg --card-status` 有可能会提示读取失败，但在Windows中一切正常，这应该是Linux设置导致的，无需恐慌，可以参照[基本设置](https://docs.canokeys.org/zh-hans/userguide/setup/)进行配置，Windows用户可以跳过不看。
# 使用体验
**OpenPGP**自不必说，之前折腾**Gnuk**时很熟悉了。**U2F**测试也正常，**EBYTE E104-BT5040U** 主板上的**sw**按键已被默认配置为确认键，进行**U2F**认证时只需要输入 **FIDO2 PIN** 然后按**sw**即可。等待按**sw**键时，**sw**这边的LED会闪烁，所以你不太可能搞错按键去按RST键。**FIDO2 PIN**可以在Windows 11的 **账户 > 登录选项 > 安全密钥 > 使用物理安全密钥登录到应用** 设置中进行首次设定或者修改。Canokeys的pin码很多，注意不要混淆。唯一遗憾之处是**EBYTE E104-BT5040U**外壳没有引出按钮，又不可能用一次拆一次，所以实用性打了折扣。鉴于它就是**Nordic NRF52840 dongle**的克隆，有空时找找看有无合适的第三方外壳。