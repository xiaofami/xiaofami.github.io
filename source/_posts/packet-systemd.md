---
title: Packet Radio Systemd服务
date: 2022-7-28 15:46:23
tags:
- Systemd
- bpq32
---
# direwolf.service
```service
# /usr/lib/systemd/system/direwolf.service
# direwolf.service

[Unit]
Description=Direwolf management
Documentation=https://tccmu.com
Requires=network-online.target

[Service]
User=marly
Type=oneshot
ExecStart=/usr/bin/screen -dmS direwolf /usr/local/bin/direwolf -c /home/marly/direwolf.conf -p
ExecStop=/usr/bin/killall -s INT direwolf
Restart=on-abnormal
RemainAfterExit=yes
[Install]
WantedBy=multi-user.target
```
# linbpq.service
```service
# /usr/lib/systemd/system/linbpq.service
# linbpq.service

[Unit]
Description=LinBPQ management
Documentation=https://tccmu.com
Requires=network-online.target
Wants=direwolf.service

[Service]
User=marly
Type=oneshot
WorkingDirectory=/home/marly/linbpq/
ExecStart=/usr/bin/screen -dmS linbpq /home/marly/linbpq/linbpq
ExecStop=/usr/bin/killall -s INT linbpq
Restart=on-abnormal
RemainAfterExit=yes
# Use graceful shutdown with a reasonable timeout
TimeoutStopSec=15s
[Install]
WantedBy=multi-user.target
```

这两个服务是以普通用户 **marly** 身份，在screen中运行的。开机时，会优先启动direwolf，然后启动linbpq。注意service文件中的用户名、工作路径、配置文件路径要修改成自己的。

# ax25bind.service
```service
# /usr/lib/systemd/system/ax25bind.service
# ax25bind.service

[Unit]
Description=Bind PTY created by direwolf to axports
Documentation=https://tccmu.com
Requires=direwolf.service
PartOf=direwolf.service

[Service]
User=root
Type=oneshot
ExecStartPre=sleep 3
ExecStart=/bin/bash -c "/usr/local/sbin/kissattach `/usr/bin/ls -l /tmp/kisstnc | /usr/bin/awk '{ print $11 }'` wl2k && exit"
ExecStartPost=/usr/local/sbin/kissparms -c 1 -p wl2k
ExecStop=/usr/bin/killall kissattach
[Install]
WantedBy=multi-user.target
```

将上述service文件放在 `/usr/lib/systemd/system/` 目录中，然后执行
```bash
sudo systemctl daemon-reload
sudo systemctl enable --now direwolf.service
sudo systemctl enable --now linbpq.service
sudo systemctl enable --now ax25bind.service
```
