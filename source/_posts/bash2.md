---
title: bash - bc
date: 2021-04-09 09:46:49
tags:
- bash
- bc
---
# bash中简单的bc计算

``` bash bc_test.sh
#!/bin/bash

var1=3.14
var2=5.2

var3=$(bc << EOF
scale = 4
a1 = $var1 + $var2
a2 = $var1 * $var2
a1 + a2
EOF
)

echo The final result is $var3
```

结果毫无悬念，24.668。注意这里用到了here document语法，行内重定向的一大用途便是方便在行间传递参数调用程序，通常搭配命令替换使用。另外注意，bc中引用外部变量（bash变量）时需要加$，bc中声明的变量是不需要的。