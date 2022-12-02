---
title: 彩色图片转为黑白
date: 2022-12-02 14:27:33
tags:
 - 图像处理
---
由于众所周知的原因，公众号LOGO需要修改成黑白色。可以使用[ImageMagick](https://imagemagick.org/)这个工具来实现，在此之前我们曾用它进行过图片格式转换，同样便利。
```bash
magick 0.jpg -colorspace Gray 1.jpg #Windows下
convert 0.jpg -colorspace Gray 1.jpg #Linux下
```