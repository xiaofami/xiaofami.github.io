---
title: Manjaro ARM运行hummingbot
date: 2021-10-26 09:43:48
tags:
- Manjaro
- ARM
- aarch64
- hummingbot
---

# 前言
2021年9月15日，人民银行、网信办、最高人民法院、最高人民检察院、工业和信息化部、公安部、市场监管总局、银保监会、证监会、外汇局联合印发《关于进一步防范和处置虚拟货币交易炒作风险的通知》（银发〔2021〕237号），明确虚拟货币相关业务活动属于非法金融活动。不过掌握虚拟货币的基本概念，以及对其工具具备认知仍具备正面意义。本文介绍了在Manjaro ARM平台运行hummingbot过程，仅供学习用途。

# 在Docker中运行

## 下载一键脚本
```bash
wget https://raw.githubusercontent.com/CoinAlpha/hummingbot/development/installation/docker-commands/create.sh
wget https://raw.githubusercontent.com/CoinAlpha/hummingbot/development/installation/docker-commands/start.sh
wget https://raw.githubusercontent.com/CoinAlpha/hummingbot/development/installation/docker-commands/update.sh
```
## 给脚本添加可执行权限
```bash
chmod a+x *.sh
```
## 创建hummingbot实例
```bash
./create.sh
```
第一步提示hummingbot镜像版本，对于ARM平台当然需要使用ARM标签。hummingbot更新比较频繁，可以到 https://hub.docker.com/r/coinalpha/hummingbot/tags 查看。

## 常用docker命令
列出container：`docker container ps`

查看container实时状态：`dockerc container stats`

启动container：`docker start hummingbot-instance`

连接到container：`docker attatch hummingbot-instance`

断开container：`Ctrl + P 然后 Ctrl + Q` （container在后台继续运行）

至成稿时，最新版本为`version-0.43.1-arm_beta`。

## 小结
刚创建的`hummingbot-instance`约占用374MB内存以及不低于20%的CPU，CPU有时还会满载，1G内存的S905盒子跑起来略吃力。如果用Manjaro ARM Minimal搭建最小化运行环境可能会略微改善。笔者没有交易所账号，没有进行更深入测试。
# 源码安装
源码安装比较麻烦，不过可以实现：
## 源码拉取
```bash
https://github.com/coinalpha/hummingbot
```

## python包安装
官方在树莓派上的教程有些过时了。杂糅下教程中引用的和`setup/requirements-arm.txt`包，共需要这些依赖：
 > 0x-contract-wrappers 0x-order-utils aioconsole aiohttp aiokafka aioresponses attrdict binance cachetools coverage cython diff-cover eth_account eth_bloom ethsnarks-loopring flake8 idna-ssl jwt mypy_extensions nose numpy objgraph pandas pre-commit prompt_toolkit psutil pyinstall pyjwt pyperclip python-binance python-telegram-bot rsa ruamel.yaml signalr-client-aio simplejson sqlalchemy telegram tzlocal ujson web3 websockets 

解决粘贴问题，再加上`QtPy`。

另外值得指出，hummingbot依赖`sqlalchemy`提供的`RowProxy`。但是在sqlalchemy1.4中，`RowProxy`被移除了，所以这个包需要用旧版本。

pip官方源在国内下载很慢，故使用-i选项指定清华镜像。

```bash
pip install 0x-contract-wrappers 0x-order-utils aioconsole aiohttp aiokafka aioresponses attrdict binance cachetools coverage cython diff-cover eth_account eth_bloom ethsnarks-loopring flake8 idna-ssl jwt mypy_extensions nose numpy objgraph pandas pre-commit prompt_toolkit psutil pyinstall pyjwt pyperclip python-binance python-telegram-bot rsa ruamel.yaml signalr-client-aio simplejson sqlalchemy telegram tzlocal ujson web3 websockets QtPy -i https://pypi.tuna.tsinghua.edu.cn/simple

pip install --user SQLAlchemy==1.3.6  -i https://pypi.tuna.tsinghua.edu.cn/simple

```
这样python依赖包就安装好了。

## Miniforge3安装
```bash
wget https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-Linux-aarch64.sh
chmod u+x Miniforge3-Linux-aarch64.sh 
./Miniforge3-Linux-aarch64.sh 
```
装好后，重新登录系统以使`conda`命令生效。
## hummingbot编译
```bash
cd hummingbot
./clean && ./compile
```
## hummingbot运行
在`hummingbot`源码根目录下，执行`bin/hummingbot.py`。首次运行会进行一些初始化配置，按提示操作即可。

## 小结
用源码折腾很麻烦，CPU照样满载，docker至少方便一些。
