#!/bin/bash
# 半自动推送更新
# -i：接受行内文本作为commit -m 参数
# -f：接受一个文本文件作为commit -m 参数

commitComment=""
echo
while getopts :i:f: opt
do
	case "$opt" in
		f)commitComment=$(cat "$OPTARG");;
		i)commitComment=$(echo "$OPTARG");;
		*);;
	esac
done
git add .
git commit -m "$commitComment"
git push origin blogSource
