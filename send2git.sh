#!/bin/bash
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
                g)echo "hexo g -d";;
                *);;
        esac
done
