---
title: hexo使用git管理
date: 2021-08-20 10:44:36
tags:
- hexo
- git
- github
---
# 生成密钥及配置（略）

网上教程有很多

# 生成站点并推送到github

    hexo g -d

# 推送站点源码到github

``` git .gitignore
.DS_Store
Thumbs.db
db.json
*.log
node_modules/
public/
```

``` bash 
git add .
git commit -m 'hexo 源文件推送'
git push origin hexoSource
```
远程分支名用自己的
# 拉取源码到本地
``` bash
git clone -b blogSource https://github.com/12321/12321.github.io.git
```
