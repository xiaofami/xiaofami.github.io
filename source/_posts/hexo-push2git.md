---
title: hexo源码半自动化推送
date: 2021-09-17 14:51:24
tags:
- linux
- hexo
- git
---
```bash 
#!/bin/bash
# autohexo.sh
# 半自动推送更新
# -i：接受行内文本作为commit -m 参数
# -f：接受一个文本文件作为commit -m 参数
# -g：构建页面并推送，无参数
commitComment=""
echo
function commit2git {
	git add .
	git commit -m "$1"
	git push origin blogSource
}
while getopts :i:f:g opt
do
        case "$opt" in
                f)commitComment=$(cat "$OPTARG")
                  commit2git "$commitComment";;
                i)commitComment=$(echo "$OPTARG")
                  commit2git "$commitComment";;
                g)hexo g -d;;
                *);;
        esac
done
```
很简单的脚本，通过终端输入或者提供一个文本文件传递`commit -m`的参数，能够略微简化提交博客源码的流程。

用例：
```bash
./autohexo.sh -gi "更新日志"
```