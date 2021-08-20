---
title: bash - pdftk删除页码脚本
date: 2021-05-19 14:47:04
tags:
- bash
- 递归
---
# pdftk删除页码脚本

最近把《Linux命令行与shell脚本编程大全》翻了一遍，想演练一下，于是写出了下面这个脚本，用于调用pdftk删除给定页码生成新文档。编写调试过程中，对bash函数传参、位置参数调用等概念有了更深入的理解，特别是shift，用于处理数量未知的位置参数格外好用。

``` bash pdftool.sh
#!/bin/bash
# 对pdftk的简单封装，用于删除指定的页码，以空格分隔，支持形如"5-7"的页码范围。页码输入不必按顺序，类似"12 6-8 1 3"输入是可以正常工作的。

#isPdftkinstalled作用为检查pdftk是否可用，若可用则执行pdftk --version
function isPdftkinstalled {
    echo
    if [ -z $(whereis pdftk | gawk '{print $2}') ]
    then
        echo "pdftk未安装或未加入PATH，请检查。"
        echo "提示：pdftk已加入Deepin官方源，您可以通过 sudo apt install pdftk 简单安装。"
    else
        echo $(pdftk --version)
    fi
    echo
}

#getCouples作用为对输入的页码进行处理，支持输入单页或页码范围，将其转换为数对（获取范围前后页码，以冒号分隔）
function getCouples {
    local couples=''
    local left_end=''
    local right_end=''
    while [ -n "$1" ]
    do      
        arg1=$(echo "$1" | gawk -F"[- ]" '{print $1}')
        arg2=$(echo "$1" | gawk -F"[- ]" '{print $2}')
        left_end=$[ $arg1 - 1 ]
        #对应页码范围情况
        if [ -n "$arg2" ]
        then
            right_end=$[ $arg2 + 1 ]
        else
        #对应单页情况
            right_end=$[ $arg1 + 1 ]
        fi
        couples=$(echo $couples $left_end:$right_end)
        shift
    done
    #数对排序处理，注意sort是针对行的排序，故需要将空格转换成换行
    couples=$(echo $couples | tr " " "\n" | sort -t ':' -k 1 -n)
    couples=$(refineCouples $couples)
    echo $couples
}

#refineCouples作用为合并相邻数对，供getCouples调用
function refineCouples {
    local args=''
    local isNabour=''
    local Num1=$(echo $1 | cut -d ":" -f1)
    local Num2=$(echo $1 | cut -d ":" -f2)
    local Num3=''
    local Num4=''
    shift
    while [ -n "$1" ]
    do
        Num3=$(echo $1 | cut -d ":" -f1)
        Num4=$(echo $1 | cut -d ":" -f2)
        isNabour=$[ $Num2 - $Num3 ]
        if [ $isNabour -eq 1 ]
        then
            Num2=$Num4
        else
            args=$(echo $args $Num1:$Num2)
            Num1=$Num3
            Num2=$Num4
        fi
        shift
    done
    args=$(echo $args $Num1:$Num2)
    echo $args
}

#generateRanges作用为将数对转换为pdftk可用的页码范围
function generateRanges {
    local first_Bit=$(echo $1 | cut -d ":" -f1)
    local Num1=''
    local Num2=''
    local args=''
    while [ -n "$1" ]
    do
        Num1=$(echo $1 | cut -d ":" -f2)
        if [ -n "$2" ]
        then
            Num2=$(echo $2 | cut -d ":" -f1)
            if [ $Num1 -gt $Num2 ]
            then
                Num2=$Num1
            fi
        else
            Num2="end"
        fi
        shift
        args=$(echo $args $Num1-$Num2)
    done

    if [ $first_Bit -gt 0 ]
    then
        args=$(echo 1-$first_Bit $args)
    fi
    echo $args
}

#此函数作用为合并相邻页码范围，在使用refineCouples后已无使用必要，可删除
function refineRanges {
    local args=''
    local isNabour=''
    local Num1=$(echo $1 | cut -d "-" -f1)
    local Num2=$(echo $1 | cut -d "-" -f2)
    local Num3=''
    local Num4=''
    shift
    while [ -n "$1" ]
    do
        Num3=$(echo $1 | cut -d "-" -f1)
        Num4=$(echo $1 | cut -d "-" -f2)
        isNabour=$[ $Num3 - $Num2 ]
        if [ $isNabour -eq 1 ]
        then
            Num2=$Num4
        else
            args=$(echo $args $Num1-$Num2)
            Num1=$Num3
            Num2=$Num4
        fi
        shift
        echo $Num1
    done
    args=$(echo $args $Num1-$Num2)
    echo $args   
}

pdfFile=$1
shift
if [ $# -lt 2 ]
then
    echo "Usage:pdftool [filename] [discard pages]"
    exit
fi

pagesConserved=$(generateRanges $(getCouples $*))
pdftk_command=$(echo pdftk $pdfFile cat $pagesConserved output new_$(basename ${pdfFile}))
#echo $pdftk_command
$pdftk_command
```
根据大佬指点，使用bash自身的字符串展开替代cut命令：

``` bash pdftool.sh
#!/bin/bash
# 对pdftk的简单封装，用于删除指定的页码，以空格分隔，支持形如"5-7"的页码范围。页码输入不必按顺序，类似"12 6-8 1 3"输入是可以正常工作的。

#isPdftkinstalled作用为检查pdftk是否可用，若可用则执行pdftk --version
function isPdftkinstalled {
    echo
    if [ -z $(whereis pdftk | gawk '{print $2}') ]
    then
        echo "pdftk未安装或未加入PATH，请检查。"
        echo "提示：pdftk已加入Deepin官方源，您可以通过 sudo apt install pdftk 简单安装。"
    else
        echo $(pdftk --version)
    fi
    echo
}

#getCouples作用为对输入的页码进行处理，支持输入单页或页码范围，将其转换为数对（获取范围前后页码，以冒号分隔）
function getCouples {
    local couples=''
    local left_end=''
    local right_end=''
    while [ -n "$1" ]
    do      
        arg1=$(echo "$1" | gawk -F"[- ]" '{print $1}')
        arg2=$(echo "$1" | gawk -F"[- ]" '{print $2}')
        left_end=$[ $arg1 - 1 ]
        #对应页码范围情况
        if [ -n "$arg2" ]
        then
            right_end=$[ $arg2 + 1 ]
        else
        #对应单页情况
            right_end=$[ $arg1 + 1 ]
        fi
        couples=$(echo $couples $left_end:$right_end)
        shift
    done
    #数对排序处理，注意sort是针对行的排序，故需要将空格转换成换行
    couples=$(echo $couples | tr " " "\n" | sort -t ':' -k 1 -n)
    couples=$(refineCouples $couples)
    echo $couples
}

#refineCouples作用为合并相邻数对，供getCouples调用
function refineCouples {
    local args=''
    local isNabour=''
    #local Num1=$(echo $1 | cut -d ":" -f1)
    #local Num2=$(echo $1 | cut -d ":" -f2)
    local Num1=${1%%:*}
    local Num2=${1##*:}
    local Num3=''
    local Num4=''
    shift
    while [ -n "$1" ]
    do
        Num3=${1%%:*}
        Num4=${1##*:}
        isNabour=$[ $Num2 - $Num3 ]
        if [ $isNabour -eq 1 ]
        then
            Num2=$Num4
        else
            args=$(echo $args $Num1:$Num2)
            Num1=$Num3
            Num2=$Num4
        fi
        shift
    done
    args=$(echo $args $Num1:$Num2)
    echo $args
}

#generateRanges作用为将数对转换为pdftk可用的页码范围
function generateRanges {
    local first_Bit=${1%%:*}
    local Num1=''
    local Num2=''
    local args=''
    while [ -n "$1" ]
    do
        Num1=${1##*:}
        if [ -n "$2" ]
        then
            Num2=${2%%:*}
            if [ $Num1 -gt $Num2 ]
            then
                Num2=$Num1
            fi
        else
            Num2="end"
        fi
        shift
        args=$(echo $args $Num1-$Num2)
    done

    if [ $first_Bit -gt 0 ]
    then
        args=$(echo 1-$first_Bit $args)
    fi
    echo $args
}

pdfFile=$1
shift
if [ $# -lt 2 ]
then
    echo "Usage:pdftool [filename] [discard pages]"
    exit
fi

pagesConserved=$(generateRanges $(getCouples $*))
pdftk_command=$(echo pdftk $pdfFile cat $pagesConserved output new_$(basename ${pdfFile}))
#echo $pdftk_command
pdftk_command
```

可见使用bash本身的字符串替换更加高效灵活，通过#或%的数量可以制定首次匹配或最长匹配，用来截取文件名或后缀很有用。