---
title: "Welcome"
date: 2020-04-16T10:55:25+08:00
draft: false
tags: ["tutorial", "hugo"]
---

# Hello world!

## How to add a new blog post

Go to `blog` folder
```bash
hugo new posts/name-of-the-new-post.md
```

Write your post. Back to `blog` folder  and then
```bash
hugo server -D
```

Then you can preview your blog locally.

### Deploy production

Change `draft=true` in the blog post and then
```bash
hugo
```

Push to remote `master`.

Done.
