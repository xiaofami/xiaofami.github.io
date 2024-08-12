---
title: ffmpeg剪辑音视频命令
date: 2024-8-12 08:59:41
tags:
- ffmpeg
index_img: /img/ffmpeg.jpg
---
Sublime Text缓存里发现的一些东西，留存备用。

```bash
ffmpeg -i 1.wav -vn -ar 44100 -ac 2 -b:a 192k output.mp3
ffmpeg -i filename.mp4 filename.mp3
ffmpeg -i 国际歌.mp3 -ss 00:00:00 -to 00:00:98 -c copy 国际歌2.mp3
ffmpeg -ss 0 -t 30 -i file.mp3 file.wav
ffmpeg -c:v h264_qsv -i "http://XXXXXXXXX.flv?phone=admin&code=admin" -c:v h264_qsv file.mp4 # 录制flv视频流，调用核显加速
```