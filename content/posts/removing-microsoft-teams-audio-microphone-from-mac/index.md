---
title: Removing "Microsoft Teams Audio" microphone from Mac
date: 2025-06-01T11:00:00
draft: false
summary: Fixes a persistent virtual microphone issue on Mac by removing the leftover Microsoft Teams audio driver.
categories:
  - Leisure
tags:
  - msteams
thumbnail: /posts/{{file_name}}/feature.jpg
---

I came across with a wired issue when having FaceTime call recently. 
1. When a FaceTime call is made, people cannot hear my voice. 
2. Check the microphone settings in the dropdown of the top menu bar FaceTime icon and turns out it connect to a microphone named "Microsoft Teams Audio" by default every time. 
3. I need to switch to use another microphone in order to get my voice back.

There is a discussion thread on Apple Community, such as [this one](https://discussions.apple.com/thread/256044430?sortBy=rank). One of the answer suggest to remove that audio device from **Audio MIDI Setup**. However, it can't be removed because the "-" button is grey out. Some users reported this virtual microphone is still there after Teams has been uninstalled.

The solution that works for me is to delete **MSTeamsAudioDevice.driver**. under `/Library/Audio/Plug-Ins/HAL`.

1. Go to `/Library/Audio/Plug-Ins/HAL` (You can do this by open Terminal and type `open /Library/Audio/Plug-Ins/HAL`)
2. Delete the `MSTeamsAudioDevice.driver` folder
3. Restart the Mac
4. Check the Audio MIDI Setup again. The "Microsoft Teams Audio" microphone should be gone by now

### Reference

https://www.reddit.com/r/LogicPro/comments/vbkdcn/comment/ihtpo69/?utm_source=share&utm_medium=web3x&utm_name=web3xcss&utm_term=1&utm_content=share_button