---
title: Manjaro字体配置
date: 2021-09-10 15:28:31
tags:
- Manjaro
- Calibre
- R3300-M
---
参考：[安装Manjaro之后的配置](https://panqiincs.me/2019/06/05/after-installing-manjaro/)

平台还是R3300-M …… 准备用它当做阅读器专心读书，人不在家直接关闭显示器就行了，从外面还能SSH连回来做实验，电费可忽略不计。安装运行Calibre很简单，但是中文字体看起来很奇怪，汇总下网上搜来的解决办法。

# 安装字体
## 安装官方仓库中的字体
```bash
sudo pacman -S ttf-roboto noto-fonts ttf-dejavu
sudo pacman -S wqy-bitmapfont wqy-microhei wqy-microhei-lite wqy-zenhei
sudo pacman -S noto-fonts-cjk adobe-source-han-sans-cn-fonts adobe-source-han-serif-cn-fonts
```
上面的`ttf-roboto noto-fonts`如果系统已经安装了就不需要再装。
# 创建字体配置文件
`/etc/fonts/fonts.conf`里面提示不要修改此文件，所以创建`~/.config/fontconfig/fonts.conf`：
```xml
<?xml version="1.0"?>
<!DOCTYPE fontconfig SYSTEM "fonts.dtd">
<fontconfig>
    <its:rules xmlns:its="http://www.w3.org/2005/11/its" version="1.0">
        <its:translateRule translate="no" selector="/fontconfig/*[not(self::description)]"/>
    </its:rules>

    <description>Manjaro Font Config</description>

    <!-- Font directory list -->
    <dir>/usr/share/fonts</dir>
    <dir>/usr/local/share/fonts</dir>
    <dir prefix="xdg">fonts</dir>
    <dir>~/.fonts</dir> <!-- this line will be removed in the future -->

    <!-- 自动微调 微调 抗锯齿 内嵌点阵字体 -->
    <match target="font">
        <edit name="autohint"> <bool>false</bool> </edit>
        <edit name="hinting"> <bool>true</bool> </edit>
        <edit name="antialias"> <bool>true</bool> </edit>
        <edit name="embeddedbitmap" mode="assign"> <bool>false</bool> </edit>
    </match>

    <!-- 英文默认字体使用 Roboto 和 Noto Serif ,终端使用 DejaVu Sans Mono. -->
    <match>
        <test qual="any" name="family">
            <string>serif</string>
        </test>
        <edit name="family" mode="prepend" binding="strong">
            <string>Noto Serif</string>
        </edit>
    </match>
    <match target="pattern">
        <test qual="any" name="family">
            <string>sans-serif</string>
        </test>
        <edit name="family" mode="prepend" binding="strong">
            <string>Roboto</string>
        </edit>
    </match>
    <match target="pattern">
        <test qual="any" name="family">
            <string>monospace</string>
        </test>
        <edit name="family" mode="prepend" binding="strong">
            <string>DejaVu Sans Mono</string>
        </edit>
    </match>

    <!-- 中文默认字体使用思源宋体,不使用 Noto Sans CJK SC 是因为这个字体会在特定情况下显示片假字. -->
    <match>
        <test name="lang" compare="contains">
            <string>zh</string>
        </test>
        <test name="family">
            <string>serif</string>
        </test>
        <edit name="family" mode="prepend">
            <string>Source Han Serif CN</string>
        </edit>
    </match>
    <match>
        <test name="lang" compare="contains">
            <string>zh</string>
        </test>
        <test name="family">
            <string>sans-serif</string>
        </test>
        <edit name="family" mode="prepend">
            <string>Source Han Sans CN</string>
        </edit>
    </match>
    <match>
        <test name="lang" compare="contains">
            <string>zh</string>
        </test>
        <test name="family">
            <string>monospace</string>
        </test>
        <edit name="family" mode="prepend">
            <string>Noto Sans Mono CJK SC</string>
        </edit>
    </match>

    <!-- 把Linux没有的中文字体映射到已有字体，这样当这些字体未安装时会有替代字体 -->
    <match target="pattern">
        <test qual="any" name="family">
            <string>SimHei</string>
        </test>
        <edit name="family" mode="assign" binding="same">
            <string>Source Han Sans CN</string>
        </edit>
    </match>
    <match target="pattern">
        <test qual="any" name="family">
            <string>SimSun</string>
        </test>
        <edit name="family" mode="assign" binding="same">
            <string>Source Han Serif CN</string>
        </edit>
    </match>
    <match target="pattern">
        <test qual="any" name="family">
            <string>SimSun-18030</string>
        </test>
        <edit name="family" mode="assign" binding="same">
            <string>Source Han Serif CN</string>
        </edit>
    </match>
    
    <!-- Load local system customization file -->
    <include ignore_missing="yes">conf.d</include>
    <!-- Font cache directory list -->
    <cachedir>/var/cache/fontconfig</cachedir>
    <cachedir prefix="xdg">fontconfig</cachedir>
    <!-- will be removed in the future -->
    <cachedir>~/.fontconfig</cachedir>

    <config>
        <!-- Rescan in every 30s when FcFontSetList is called -->
        <rescan> <int>30</int> </rescan>
    </config>

</fontconfig>
```
晚上试试看字体是否会正常一些。

更新：经测试，配置字体后使用Calibre-Viewer看书字体渲染效果满意。
## 手动安装字体
刷新字体命令：`fc-cache -fv`
```bash
Font directories:
        /home/youname/.local/share/fonts
        /usr/local/share/fonts
        /usr/share/fonts
        /home/youname/.fonts
        /usr/share/fonts/TTF
        /usr/share/fonts/adobe-source-code-pro
        /usr/share/fonts/adobe-source-han-sans
        /usr/share/fonts/adobe-source-han-serif
        /usr/share/fonts/cantarell
        /usr/share/fonts/droid
        /usr/share/fonts/encodings
        /usr/share/fonts/gsfonts
        /usr/share/fonts/liberation
        /usr/share/fonts/misc
        /usr/share/fonts/noto
        /usr/share/fonts/noto-cjk
        /usr/share/fonts/util
        /usr/share/fonts/wenquanyi
        /usr/share/fonts/wps-office
        /usr/share/fonts/encodings/large
        /usr/share/fonts/wenquanyi/wqy-microhei
        /usr/share/fonts/wenquanyi/wqy-microhei-lite
        /usr/share/fonts/wenquanyi/wqy-zenhei
/home/youname/.local/share/fonts: skipping, no such directory
/usr/local/share/fonts: skipping, no such directory
/usr/share/fonts: caching, new cache contents: 0 fonts, 15 dirs
/usr/share/fonts/TTF: caching, new cache contents: 148 fonts, 0 dirs
/usr/share/fonts/adobe-source-code-pro: caching, new cache contents: 30 fonts, 0 dirs
/usr/share/fonts/adobe-source-han-sans: caching, new cache contents: 7 fonts, 0 dirs
/usr/share/fonts/adobe-source-han-serif: caching, new cache contents: 7 fonts, 0 dirs
/usr/share/fonts/cantarell: caching, new cache contents: 11 fonts, 0 dirs
/usr/share/fonts/droid: caching, new cache contents: 27 fonts, 0 dirs
/usr/share/fonts/encodings: caching, new cache contents: 0 fonts, 1 dirs
/usr/share/fonts/encodings/large: caching, new cache contents: 0 fonts, 0 dirs
/usr/share/fonts/gsfonts: caching, new cache contents: 35 fonts, 0 dirs
/usr/share/fonts/liberation: caching, new cache contents: 12 fonts, 0 dirs
/usr/share/fonts/misc: caching, new cache contents: 1 fonts, 0 dirs
/usr/share/fonts/noto: caching, new cache contents: 615 fonts, 0 dirs
/usr/share/fonts/noto-cjk: caching, new cache contents: 73 fonts, 0 dirs
/usr/share/fonts/util: caching, new cache contents: 0 fonts, 0 dirs
/usr/share/fonts/wenquanyi: caching, new cache contents: 5 fonts, 3 dirs
/usr/share/fonts/wenquanyi/wqy-microhei: caching, new cache contents: 2 fonts, 0 dirs
/usr/share/fonts/wenquanyi/wqy-microhei-lite: caching, new cache contents: 2 fonts, 0 dirs
/usr/share/fonts/wenquanyi/wqy-zenhei: caching, new cache contents: 3 fonts, 0 dirs
/usr/share/fonts/wps-office: caching, new cache contents: 14 fonts, 0 dirs
/home/youname/.fonts: caching, new cache contents: 0 fonts, 0 dirs
/usr/share/fonts/TTF: skipping, looped directory detected
/usr/share/fonts/adobe-source-code-pro: skipping, looped directory detected
/usr/share/fonts/adobe-source-han-sans: skipping, looped directory detected
/usr/share/fonts/adobe-source-han-serif: skipping, looped directory detected
/usr/share/fonts/cantarell: skipping, looped directory detected
/usr/share/fonts/droid: skipping, looped directory detected
/usr/share/fonts/encodings: skipping, looped directory detected
/usr/share/fonts/gsfonts: skipping, looped directory detected
/usr/share/fonts/liberation: skipping, looped directory detected
/usr/share/fonts/misc: skipping, looped directory detected
/usr/share/fonts/noto: skipping, looped directory detected
/usr/share/fonts/noto-cjk: skipping, looped directory detected
/usr/share/fonts/util: skipping, looped directory detected
/usr/share/fonts/wenquanyi: skipping, looped directory detected
/usr/share/fonts/wps-office: skipping, looped directory detected
/usr/share/fonts/encodings/large: skipping, looped directory detected
/usr/share/fonts/wenquanyi/wqy-microhei: skipping, looped directory detected
/usr/share/fonts/wenquanyi/wqy-microhei-lite: skipping, looped directory detected
/usr/share/fonts/wenquanyi/wqy-zenhei: skipping, looped directory detected
/var/cache/fontconfig: not cleaning unwritable cache directory
/home/youname/.cache/fontconfig: cleaning cache directory
/home/youname/.fontconfig: not cleaning non-existent cache directory
fc-cache: succeeded
```
查找字体位置一目了然。过去一般习惯把字体文件直接丢到`~/.fonts`中，但是`/etc/fonts/fonts.conf`中提到
```xml
<!-- the following element will be removed in the future -->
<dir>~/.fonts</dir>
```
所以还是老实放到`/usr/share/fonts/`里面合适的目录中更合适。
