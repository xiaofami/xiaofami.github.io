---
title: 晾衣绳天线研究（篇三）
date: 2022-09-19 14:30:15
tags:
- 业余无线电
- 天线
- ham
---

之前测试天线发射指标一直不理想，14MHz的SWR始终降不下来。经过学习后得知馈线的屏蔽层也需要连接。之前由于没有 **SL16-J**的公对公连接头，所以仅仅使用六角螺丝刀连接了内导体，外屏蔽层为开路状态。使用铜线连接屏蔽层后天线终于可以自然谐振在14MHz，算是一大收获，接收效果也有改善。等到连接头到货后估计还能减少一些损耗，SWR也会更稳定。
再来审视下这个天线的特性。这个天线如果不考虑馈线，和一个折叠偶极子天线（folded dipole antenna）并无别样。折叠偶极子天线相较于普通的偶极子天线具备如下优点：
1. 阻抗高，约300Ω，与传输线匹配更好；
2. 带宽更高；
3. 信噪比更高。

不过普通的偶极子天线使用同轴线（coax）馈电，我的这个天线使用双头线（ladder line），馈电位置都是天线中央。这种搭配双头线使用的天线，一般称之为双联天线（doublet antenna），它具备如下特点：
1. 馈线是天线的一部分。虽然对馈线长度要求并不严格（假设天线左臂右臂长度均为L1，馈线长L2），当L1+L2等于操作频率的四分之一波长时，阻抗匹配最好，此时馈线末端呈现的阻抗大概为50Ω；
2. 馈线使用平行线（双头线），以减小损耗。一般可选450Ω或600Ω传输线，不过电视用的300Ω馈线也可以。需要指出，电视的300Ω馈线便宜易得，约合1.2元/米，前面两种国内没发现哪里有卖。不同于同轴线，双头线易受环境干扰。尽量将其远离金属、不要与房屋外墙平行放置、不要放在地上，也不要大角度弯折甚至缠起来，否则会发生预期之外的阻抗变化或者电磁泄露；
3. 由于双头线损耗较小，所以双联天线在配合天调的情况下比较适合多段操作。

想更深入了解 doublet antenna 推荐阅读 [Introducing the "All-Band" Doublet:What the Student and the Instructor Should Keep in Mind](https://ftp.unpad.ac.id/orari/library/library-sw-hw/amateur-radio/ant/docs/Introducing%20the%20All-Band%20Doublet.htm)


另外在查找 doublet antenna 天线资料时发现了另一类有意思的天线： **Wide-Band Folded Dipole**，简称 **WBFD**，即宽频折叠偶极子天线。它与普通FD天线的区别在于在馈电点正对面插入了一个阻值800至900Ω的无感电阻，然后配合1:16的变换器实现阻抗匹配，以得到宽广范围内较低的SWR值。不过代价是增益比同规格 doublet antenna 低了约6.3dB。而且低SWR不总意味着天线能够高效发射，在操作频率低于某一阈值时，天线指标迅速恶化，作为低SWR的代价，无感电阻承受了大部分功率。感兴趣可以移步至[Notes on the Terminated Wide-Band "Folded Dipole"](http://on5au.be/content/a10/wire/wbfd.html)深入了解。

最后在此缅怀作者 **L. B. Cebik, W4RNL**，本文引用的两篇文献均出自他的手笔，愿他安息。