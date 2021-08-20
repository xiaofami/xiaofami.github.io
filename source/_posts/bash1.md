---
title: bash - for
date: 2021-04-08 11:09:47
tags:
- bash
- for
---
# bash中简单的for循环

``` bash 
#!/bin/bash for_test.sh
sum=0
i=$(echo {1..5})
echo "The content of list:$i"
for var in $i
do
    echo "The current value is:$var"
    sum=$[$sum+$var]
    echo "The sum is: $sum"
done
echo "The final sum is: $sum"
```

感觉bash更适合编程入门，足够简单，少量知识就可以写出实用脚本实现对系统的自动化管理。许多“现代”语言虽然语法看起来“简单”，但是隐藏了许多细节，初学者到头来只会机械地调用模块，对于实际发生了什么毫无头绪，反而容易迷失方向。