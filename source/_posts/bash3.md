---
title: bash - 数组
date: 2021-04-22 11:20:54
tags:
- bash
- 函数
---
# bash中简单函数数组传递

``` bash array_test.sh
#!/bin/bash
# array variable to function test
function testit {
local newarray
newarray="$@"
echo "The new array value is: ${newarray[*]}"
}
myarray=(1 2 3 4 5)
echo "The original array is ${myarray[*]}"
testit ${myarray[*]}
```
书中使用命令展开进行传值

``` bash
newarray=($(echo "$@"))
```
经过试验，这种方式也可以：

``` bash
newarray=("$@")
```
从输出来看一致，不过内在是否存在区别？

我自己来解答：

1. `newarray="$@"` : newarray不是数组；
2. `newarray=("$@")` : newarray是数组（套了圆括号）
3. `newarray=("$*")` : newarray不是数组

对于第3点可以回顾一下`$@`与`$*`的区别。`$@`中每个元素是独立的，`$*`只有一个元素。另外无论newarray是否为数组，`${newarray[*]}`都可以完整输出内容，因为当newarray不是数组的情况下，全部内容都在`${newarray[0]}`中，从标准输出来看没区别。

对于for而言数组与否没区别，它只会根据当前IFS分割元素。

再次回顾书中的方式：

``` bash
newarray=($(echo "$@"))
```

这种方式看似愚笨，实则非常鲁棒。通过命令展开将不确定的输入类型输出成普通字符串，再套括号变成数组，值得品味。