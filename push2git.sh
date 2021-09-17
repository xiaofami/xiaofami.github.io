#!/bin/bash
# 推送更新

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
#echo $1
#echo $commitComment
git add .
git commit -m "$commitComment"
git push origin blogSource