---
title: Rust模块小结
date: 2022-04-02 15:42:01
tags:
- Rust之Packages,Crates与Modules
---
Rust官方教程中Packages,Crates与Modules一章略有些晦涩，特别是Packages与Crates的关系。这部分翻来覆去读了几遍，结合别人项目和[Rust Packages vs Crates](https://jeffa.io/rust_packages_vs_crates)大概弄懂了。

# Package
**Package** 为其中的最高单位：
```rust
$ cargo new my-project
     Created binary (application) `my-project` package
```

执行`cargo new`命令，便得到了一个`package`，大概对应其他语言中的 **project** ?

**Package** 具备如下特点：

1. **Package** 至少包装了一个 **crate**;
2. **Package** 是可发布的;
3. **Package** 可包含一个或零个 **library crate**;
4. **Package** 可包含多个 **binary crate**;
5. 当将**Package**添加到自己的依赖时（在Cargo.toml中添加），实际上是使用了package中的 library crate。

# Crate

1. crate 是一种组织代码的形式;
2. crate不是binary就是library;
3. crate不能独立发布，只能作为package的成员发布;
4. 对于编译器，crate更多起到命名空间作用