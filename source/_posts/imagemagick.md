---
title: 使用imagemagick处理图片
date: 2021-09-17 10:25:35
tags:
- linux
- imagemagick
- 图像处理
---
> Use ImageMagick® to create, edit, compose, or convert digital images. It can read and write images in a variety of formats (over 200) including PNG, JPEG, GIF, WebP, HEIC, SVG, PDF, DPX, EXR and TIFF. ImageMagick can resize, flip, mirror, rotate, distort, shear and transform images, adjust image colors, apply various special effects, or draw text, lines, polygons, ellipses and Bézier curves.

利用imagemagick可以对图片进行从简单到复杂的各种处理。

# 格式转换
场景：微信公众号封面不接受webp格式图片，需要进行转换：
``` bash
convert 封面4.webp 封面4.jpg
```
再也不需要下载安装臃肿迟缓捆绑广告试用版还添加水印的软件了。
# 图片合并
## 一张图片一页：
``` bash
convert 1.jpg 2.jpg 3.jpg total.tif
```
得到一个3页的图片文件，类似PDF。当然，也可以一步到位，直接转换为PDF：
```bash
convert 1.jpg 2.jpg 3.jpg total.pdf
```
有可能会提示类似错误：
```bash
convert-im6.q16: attempt to perform an operation not allowed by the security policy `PDF' @ error/constitute.c/IsCoderAuthorized/408.
```
ImageMagick的默认安全策略禁止这种转换，可以通过修改ImageMagick安全策略文件取消限制：
```bash
sudo vim /etc/ImageMagick-*/policy.xml
```
将` <!-- <policy domain="module" rights="none" pattern="{PS,PDF,XPS}" /> -->`这一行取消注释并保存，即修改为
```bash
<policy domain="module" rights="none" pattern="{PS,PDF,XPS}" />
```
这样输出图片为PDF就没问题了。

备注：我在Deepin上测试，得到的“PDF”文件打不开，用file查看是图片格式：

> output.pdf: JPEG image data, JFIF standard 1.01, resolution (DPI), density 72x72, segment length 16, Exif Standard: [TIFF image data, big-endian, direntries=14, height=3264, bps=0, description=smart, manufacturer=HUAWEI, model=CND-AN00, orientation=upper-left, xresolution=200, yresolution=208, resolutionunit=2, software=CND-AN00 10.1.1.166(C00E140R3P1), datetime=2021:08:14 08:02:45, width=2448], baseline, precision 8, 2448x3264, components 3

Deepin上convert版本：`Version: ImageMagick 6.9.10-23 Q16 x86_64 20190101 https://imagemagick.org Copyright: © 1999-2019 ImageMagick Studio LLC`

在Manjaro ARM 21.08上测试没问题，得到了正常的PDF文件。Manjaro ARM 21.08上convert版本为`Version: ImageMagick 7.1.0-6 Q16-HDRI aarch64 2021-09-04 https://imagemagick.org Copyright: (C) 1999-2021 ImageMagick Studio LLC`。另外Manjaro上不需要修改policy文件，默认就正常运行。
# 按a4纸张规格输出
```bash
convert screenshot-2021-09-14-222216.png -page a4 1.pdf
```

其他功能还有很多，类似resize等等，具体可查阅man手册。