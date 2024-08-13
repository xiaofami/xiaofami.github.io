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

**canokey.hex**比**canokey_flash.uf2**固件体积整整大出**40%**，尚不清楚差在哪里，项目对此未作说明。

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