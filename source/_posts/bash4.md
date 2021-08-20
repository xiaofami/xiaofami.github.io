---
title: bash - 递归
date: 2021-04-23 10:17:11
tags:
- bash
- 递归
---
# bash递归函数测试

``` bash recursion_test.sh
#!/bin/bash
# using recursion

function factorial {
    if [ $1 -lt 1 ]
    then
        echo 0
    elif [ $1 -eq 1 ]
    then
        echo 1
    else
        local temp1=$1
        local temp2=$(factorial $[ $1 - 1 ])
        local result=$[ $temp1 * $temp2 ]
        echo $result
    fi
}

function sumn {
    if [ $1 -lt 1 ]
    then
        echo 0
    elif [ $1 -eq 1 ]
    then
        echo 1
    else
        local temp1=$1
        local temp2=$(sumn $[ $1 - 1 ])
        local result=$[ $temp1 + $temp2 ]
        echo $result
    fi
}

function fbnq {
    if [ $1 -lt 1 ]
    then
        echo 0
    elif [ $1 -lt 2 ]
    then
        echo 1
    else
        local temp1=$(fbnq $[ $1 - 1 ])
        local temp2=$(fbnq $[ $1 - 2 ])
        local result=$[ $temp1 + $temp2 ]
        echo $result
    fi
}

read -p "Enter value: " value
result=$(factorial $value)
totalsum=$(sumn $value)
fibon=$(fbnq $value)
echo "The factorial of $value is: $result"
echo "The total sum of $value is: $totalsum"
echo "FibonacciRecursive of $value is: $fibon"
```

递归实现只有2步：构造递归表达式以及设定初值。