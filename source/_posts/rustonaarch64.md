---
title: Rust on aarch64
date: 2021-09-30 14:13:17
tags:
- Manjaro
- ARM
- aarch64
- rust
---
# 安装
```bash
sudo pacman -Sy rust
```
# 换国内源
参考自[解决Rust -- update crates.io过慢的问题](https://www.cnblogs.com/kuikuitage/p/14199424.html)
```bash
vim ~/.cargo/config
```
添加以下内容：
```bash
# 放到 `$HOME/.cargo/config` 文件中
[source.crates-io]
registry = "https://github.com/rust-lang/crates.io-index"

# 替换成你偏好的镜像源
replace-with = 'sjtu'
#replace-with = 'ustc'

# 清华大学
[source.tuna]
registry = "https://mirrors.tuna.tsinghua.edu.cn/git/crates.io-index.git"

# 中国科学技术大学
[source.ustc]
registry = "git://mirrors.ustc.edu.cn/crates.io-index"

# 上海交通大学
[source.sjtu]
registry = "https://mirrors.sjtug.sjtu.edu.cn/git/crates.io-index"

# rustcc社区
[source.rustcc]
registry = "git://crates.rustcc.cn/crates.io-index"
```
# 查看文档
使用cargo doc生成的文档为网页形式，可以用python建立服务器然后在浏览器中查看。
```bash
# 首先进入doc目录
python -m http.server 8000
```
然后在浏览器中访问即可。python服务器默认端口为8000，无特别要求可省略。