---
title: Rust结构体实验
date: 2022-04-02 14:05:04
tags:
- Rust
---
Rust官方教程读到智能指针一章就有些迷糊了，毕竟上次接触指针还是N年前的 **谭浩强** C语言 XD 而且只看不练基础没法牢固，所以打算对前面章节进行一些实验，研究下可行的编程范例。

这个例子是对结构体的实验。之前用python时 **字典 + 列表** 足以应对绝大部分场景。Rust中 **Vec** 有些类似列表，不过 **Vec** 中成员类型要求一致。 **Vec** 提供了push和pop方法用于增删成员，也可以通过索引或者get方法调用成员。注意get方法返回 **Option<&T>** 类型需要自己match一下。

此外有几点需要留意：

1. 迭代器。使用迭代器会发生所有权的转移！所以该借用（borrow）就借用吧。
2. 字符串。需要留意 **+** 运算符对于字符串的实现，大致看起来这样：
```rust
fn add(self, s: &str) -> String {
```  
所以对于一般 `let s3 = s1 + &s2` 的情形， **s1** 所有权会发生转移。

如果要避免所有权转移的麻烦，使用`format!`即可。
```rust
#[derive(Debug)]
struct Rect1 {
    id: u64,
    name: String,
}
impl Rect1 {
    fn new(id:u64, name: String) -> Rect1 {
        Rect1 {
            id,
            name,
        }
    }
}
fn main() {
    let mut id: u64;
    let mut name: String;
    let mut clbox: Vec<Rect1> = Vec::new();

    for i in 0..5 {
        id = i;
        name = "a".to_string() + &id.to_string();
        //name = format!("{}{}", "a", &id.to_string());
        //let tmp_rect = Rect1::new(id, name);
        clbox.push(Rect1::new(id, name));
    }

    for item in &clbox {
        println!("{} - {}", item.id, item.name);
    }
    println!("\n");
    for item in &clbox {
        println!("{:?}", item);
    }
}
```