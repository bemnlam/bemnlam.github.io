---
title: "Use Gravatar Everywhere"
summary: Gravatar. Gravatar everywhere.
date: 2020-07-18T12:01:56+08:00
lastmod: 2020-07-18T12:01:56+08:00
draft: false
categories: ["Dev"]
tags: [ "tutorial", "gravatar" ]
thumbnail: /posts/use-gravatar-everywhere/feature.jpg
---

### What is Gravatar

Your public profile on the internet, provided by Wordpress. See https://en.gravatar.com/.

### 1. Upload an image to your gravatar account

If you don't have the gravatar account, create one. Make sure that the email you used to create the account will be the email account you want to link your profile picture.

After that, upload your profile picture to gravatar.

### 2. Use the image everywhere

#### Get your md5 hash of email address

For MacOS user, you should have the md5 utility installed, go to the terminal and check:

```bash
❯ which md5
/sbin/md5
```

After that, generate the md5 has of your email address:

```bash
❯ md5 -s "myemall@address.com"
MD5 ("myemall@address.com") = ca49930cff2f87bd37bfe71ce21467f
```

The gravatar image url is in this format: 


```
https://gravatar.com/avatar/{your md5 hash}?s={size}
```

If you want to have a 200px avatar, use `https://gravatar.com/avatar/ca49930cff2f87bd37bfe71ce21467f?s=200`

use this image url in `<img>` tag:

```html
<img src="https://gravatar.com/avatar/ca49930cff2f87bd37bfe71ce21467f?s=200" />
```

And you are good to go!

