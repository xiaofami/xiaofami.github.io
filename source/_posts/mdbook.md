---
title: 使用mdbook本地查看rust教程
date: 2021-10-03 22:23:16
tags:
- rust
- mdbook
- aarch64
---
首先推荐两个教程：
*. [Rust 程序设计语言（第二版 & 2018 edition） 简体中文版](https://github.com/KaiserY/trpl-zh-cn)
*. [通过例子学 Rust](https://github.com/rust-lang-cn/rust-by-example-cn)

以上教程均可在线阅读，不过也可下载到本地阅读。以[通过例子学 Rust](https://github.com/rust-lang-cn/rust-by-example-cn)为例：

```bash
$ git clone https://github.com/rust-lang-cn/rust-by-example-cn
$ cd rust-by-example-cn
$ cargo install mdbook
$ mdbook build
$ mdbook serve
```
在arm设备上远程操作，建议新建screen以免意外连接丢失重新来过。另外我需要从其他设备访问文档页面，默认的`mdbook server`只允许localhost访问，需要略微修改：

```bash
mdbook serve -n 0.0.0.0
```

这样局域网其他设备就可以在浏览器中通过3000端口阅读文档了。如果需要更换端口号，可以通过`-p`自行指定。
