---
title: Manjaro配置管理
date: 2021-08-20 09:37:26
tags:
- Manjaro
---
参考：[manjaro 切换国内源及软件安装](https://www.jianshu.com/p/2d096cd9ad61)

# 换国内源

    sudo pacman-mirrors -i -c China -m rank
    sudo pacman-mirrors -g
    sudo pacman -Syyu

# 安装ARU包管理工具 

    sudo pacman -S yay

原本想通过ARU安装RTL8189ETV启动，但是包依赖linux mainline kernel，貌似不行。手动编译也没成功。

# pacman.conf选项自定义

添加了Color和ILoveCandy选项，第一个使pacman产生彩色输出，第二个把pacman下载进度条变成吃豆子，虽然没什么用还是设置了。

# pacman常用命令

参考：[Pacman Overview](https://wiki.manjaro.org/index.php/Pacman_Overview)

1. 安装更新

To update the package database and update all packages on the system

    user $ sudo pacman -Syu

To force a full refresh of the package database and update all packages on the system. You must do this when switching branches or switching mirrors.

    user $ sudo pacman -Syyu

To force a full refresh of the package database, update all packages on the system and allow packages to be downgraded. Downgrading should be only be needed when switching to an older branch. For example, switching from Testing to Stable.

    user $ sudo pacman -Syyuu

2. 搜索软件包

To search the Manjaro repositories for available packages you can use the command pacman -Ss keyword. It will search both the package name and the description for the keyword. For example, to search for packages containing the keyword smplayer you could use:

    user $ pacman -Ss smplayer

You can search your installed packages in the same manner using -Qs instead of -Ss. To search your installed packages for smplayer:

    user $ pacman -Qs smplayer

Once you have found a package you can use pacman -Qi to get more information about an installed packages or pacman -Si for packages in the repos. Following the example above you could use

    user $ pacman -Si smplayer

Finally, for a list of all installed packages on your system, enter the following command:

user $ pacman -Ql

3. 安装软件包
To install a software package, the basic syntax is `pacman -S packagename`. However, installing a package without updating the system will lead to a partial upgrade situation so all the examples here will use pacman -Syu packagename which will install the package and ensure the system is up to date. For example, to install smplayer the command is:

    user $ sudo pacman -Syu smplayer

You will then be presented a list of software to install. You may notice this list has more packages than you requested. This is because many packages also have dependencies which are packages that must be installed in order for the software you selected to function properly.


Pacman can also directly install packages from the local system or a location on the internet. The format of that command is pacman -U packagelocation. For example, to install a copy of your package cache you could do something like:

    user $ sudo pacman -U /var/cache/pacman/pkg/smplayer-19.5.0-1-x86_64.pkg.tar.xz

Alternatively, you could get it directly from one of Manjaro's mirrors:

    user $ sudo pacman -U https://mirror.alpix.eu/manjaro/stable/community/x86_64/smplayer-19.5.0-1-x86_64.pkg.tar.xz

4. 删除软件包
To remove a software package, the basic syntax is sudo pacman -R packagename. We could remove the smplayer package we installed above with:

    user $ sudo pacman -R smplayer

This will remove the package, but will leave all the dependencies behind. If you also want to remove the unneeded dependencies you could use pacman -Rsu packagename as seen in this example:

    user $ sudo pacman -Rsu smplayer

Sometimes when you try to remove a package you will not be able to because there are other packages which depend on it. You can use pacman -Rc packagename to remove a package and everything that depends on it. Be careful to heed the above warning when using this option.

    user $ sudo pacman -Rc smplayer

The most nuclear option is pacman -Rcs packagename. This will remove everything that depends on packagename and continue to do so on its dependencies. This should really only be used in exceptional circumstances such as when removing an entire desktop environment and trying not to leave anything behind.

Pacman usually also creates backup configuration files when deleting packages. To remove those, you can add n to any of the examples above. For example:

    user $ sudo pacman -Rn smplayer
    user $ sudo pacman -Rsun smplayer
    user $ sudo pacman -Rcn smplayer
