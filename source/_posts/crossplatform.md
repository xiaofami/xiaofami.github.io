---
title: hexo跨平台写作
date: 2021-09-02 09:50:08
tags:
	- hexo
	- git
---
换新电脑后利用git直接拉取的代码不是完整的hexo环境，缺失了`node_modules`（参见`.gitignore`）和主题（如果使用git clone 安装了第三方主题）。

# 恢复node_modules
随便新建一个文件夹，进入后执行`hexo init`，完成后把`node_modules`移动到刚才的hexo目录中。

# 安装主题
以**next**为例，在hexo目录下执行`git clone https://github.com/theme-next/hexo-theme-next themes/next`。如果之前在hexo根目录下使用了` _config.next.yml`进行配置，那么就不需要重新配置主题，推荐这种配置方式。

# 解决 `TypeError: line.matchAll is not a function` 问题
在`_config.yml`中，将**hightlight**一段中**enable**字段由true修改为false即可。