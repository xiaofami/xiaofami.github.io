---
title: Manjaro安装配置docker
date: 2021-08-20 15:51:21
tags:
- Manjaro
- Docker
- Arm
---
主要来源：[在 Manjaro Linux 系统使用 Docker](https://blog.huangz.me/2020/docker-on-linux.html)

# 提要
硬件平台还是百视通R3300-M …… 安装Manjaro Arm 21.04后已升级到21.08，内核版本 **5.13.0-1-MANJARO-ARM #1 SMP PREEMPT Wed Jun 30 23:07:51 +03 2021 aarch64 GNU/Linux**

# 安装Docker
``` bash
sudo pacman -Syu
sudo pacman -S docker
```
# 启动服务
``` bash
sudo systemctl start docker.service
```
# 添加到系统启动项
``` bash
sudo systemctl enable docker.service
```
# 添加当前用户到Docker组
这样当前用户就有足够权限操作docker而不必sudo权限。
``` bash
sudo usermod -aG docker $USER
```
# 换国内源
打开或创建 /etc/docker/daemon.json 文件：
``` bash
{
    "registry-mirrors": [
        "https://registry.docker-cn.com"
    ]
}
```
registry.docker-cn.com 是 Docker 的官方中国镜像， 除此之外还有其他一些第三方镜像可选：


| 镜像| 地址 |
| :----: | :----: |
| Azure中国 | https://dockerhub.azk8s.cn |
| 中科大 | https://docker.mirrors.ustc.edu.cn |
| 七牛云 | https://reg-mirror.qiniu.com |
| 网易云 | https://hub-mirror.c.163.com |
| 腾讯云 | https://mirror.ccs.tencentyun.com |

保存文件之后重启一下 Docker 服务：

``` bash
sudo systemctl daemon-reload
sudo systemctl restart docker
```
# 其他操作
``` bash
docker search redis
docker pull redis
docker pull redis:rc
docker images
docker run --name myredis -d redis
docker ps
docker stop myredis
docker rm myredis
docker info
```

# 下步计划
之前在docker里运行过dokuwiki,tiddlywiki,minecraft server等等。跑minecraft server性能不太行，破坏方块有可感知延迟。