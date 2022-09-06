---
title: 晾衣绳天线研究（篇二）
date: 2022-09-06 15:35:10
tags:
 - ham
 - dipole
 - eznec
---
之前搭建的天线指标不是很理想。发射指标暂不提，接收增益感觉也不够。之前守听7050频率，能勉强听到沈阳的朋友呼叫外地友台，报告对方信号59，不过我这里什么都听不到。底噪其实还算理想，求精电源配合磁环29MHz底噪不起表，7、14MHz底噪大概S3左右。拿EZNEC大致仿真了最普通的半波长偶极子天线，俯仰角90°达到最大增益6.55dbi，beamwidth为35.9~144.1°范围。方向性不佳的原因是高度不够，书上推荐不小于0.2λ，实际越高越好。
[Experimenting with a clothesline style folded dipole](https://www.youtube.com/watch?v=OoHoHocQdc4)是 **VK3YE** 将 **VA2ERY** 文章付诸实践的视频。他在自家院子里很随意地拉了一条约5米长的晾衣绳，高度没有一人高，两条线最大距离约0.5米。 **VK3YE** 在不同的馈电点位置用天分仪进行了测试，结果没有惊喜，毕竟这条使用1:4的巴伦的天线过于随意，而且偏长了。
**W4RNL** 撰写的[Modeling and the Logic of Question Resolution](http://on5au.be/content/amod/amod117.html)通读了一遍，该文对Folded Dipole进行了建模，可作为参考。**W4RNL** 已经化作了 **silent key** ，愿他安息。
重新建模后再次仿真计算，结果表明配合300Ω馈线情况下，天线在14MHz完美谐振，驻波1.1左右。我之前制作的天线过长了，而且长出的天线没有减掉，劣化了天线指标，有空时应该将天线剪短。至于方向性，Beamwidth33.3~146.7°，照旧90°最大 Orz 或许我应该专注通联卫星 😂