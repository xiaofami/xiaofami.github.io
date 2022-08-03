---
title: R3300-M刷入Linux实验计划
date: 2022-08-03 14:55:48
tags:
- Manjaro
- arm64
- aarch64
- Armbian
---
参考 https://github.com/d51x/armbian-s905 ，计划再次试验将Linux系统刷入R3300-M盒子的emmc分区。
试验内容：
1. 试验能否将Armbian刷入R3300-M，验证可行性；
2. 试验能否通过uEnv.txt方式启动最新版Manjaro ARM系统；
3. 试验能否将Manjaro ARM刷入 R3300-M。

为方便调试，笔记本电脑通过UART与盒子通信，观察盒子启动状态。如果UART无法交互，可通过在u-boot启动文件中指定printenv观察。

首先弄清几个启动文件的关系

**boot.cmd与boot.scr**
boot.cmd为纯文本文件，通过mkimage生成boot.scr:
```bash
mkimage -C none -A arm -T script -d /boot/boot.cmd /boot/boot.scr
```

**uEnv.txt** 与 **boot.scr**
根据[uEnv.txt vs boot.scr](https://stackoverflow.com/questions/28891221/uenv-txt-vs-boot-scr)的说法，uEnv.txt可以预设置u-boot的环境变量，先于bootcmd运行。boot.scr可以执行u-boot脚本程序，同样先于bootcmd运行。不过我高度怀疑这段描述的准确性，具体参见下文。
补充：**bootcmd**与**bootargs**为u-boot中的环境变量。

**boot.ini**
boot.ini是一个纯文本文件。通过观察ophub发布的镜像可知，boot.ini读取了uEnv.txt，并将 **APPEND** 参数传递给了 **bootargs**这个环境变量。

**boot.ini**与**boot.scr**
参考 https://wiki.odroid.com/odroid-n2/software/boot_sequence ，boot.ini与boot.scr是bootloader支持的两种启动脚本。boot.ini是纯文件，便于修改。这个文件最初被Hardkernel's ODROID的开发板使用。如果文件首行是 **ODROIDN2-BOOT-CONFIG** ，那么bootloader就会开始执行boot.ini文件。(这解释了为什么Amlogic盒子的boot.ini文件首行都是这个)

boot.scr是传统形式的u-boot脚本。脚本开头为一段长度64字节的二进制头，包含了整个文件的校验信息以防文件损坏或被修改。其余的语句以test形式为主，设置环境变量或执行命令。由于boot.scr文件的特性，对其做出变更后，需要使用 **mkimage** 重新生成，具体命令参见前文。

个人猜测，在Amlogic设备上，bootloader会优先试图利用 **boot.ini** 启动，如果 **boot.ini** 不存在或者加载失败，再利用 **boot.scr** 尝试启动。两个文件的执行命令大体上是等价的。可以通过printenv命令检查具体优先顺序。

至此我们的第二步试验已有眉目。我们使用的 **Manjaro ARM 22.06 VIM2 Minimal** 版本 **/boot** 分区只包含 u-boot.bin，dtbs目录以及extlinux目录。在先前的测试中，我将 **aml_autoscript aml_autoscript.zip u-boot.ext** 文件复制了过来，删掉了u-boot.bin并在extlinux.conf中配置了合适dtb，测试系统正常启动，主线内核也关机重启正常。不过尝试使用 **uEnv.txt** 启动时，由于既没有boot.scr，也没有 boot.ini，所以启动毫无意外地失败了。

小结：Amlogic设备上，bootloader读取boot.scr或者boot.ini启动，uEnv.txt被上述两个文件加载。boot.scr使用mkimage编译，boot.ini纯文本随便改。

最后再补充一些关于extlinux.conf的知识，参考自[Using Distro Boot With Xilinx U-Boot](https://xilinx-wiki.atlassian.net/wiki/spaces/A/pages/749142017/Using+Distro+Boot+With+Xilinx+U-Boot):
bootloader会优先试图加载/extlinux/extlinux.conf，如果没有找到，则查询 **boot_targets** 寻找备用文件，比如上面提到的 **boot.scr**。
extlinux.conf具有很多优点，但是不幸的是我们现在试图将Linux安装到emmc，厂商的老旧bootloader不支持extlinux这一特性。这也是放弃extlinux转而折腾boot.ini boot.scr uEnv.txt的原因所在。
