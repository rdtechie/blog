---
title: PSA - Do not make your Nest cam public just to access the stream
type: blog
date: 2018-01-06T01:00:00+00:00
slug: psa-nest
news_keywords: [ "nest", "camera", "psa", "security" ]
images: ["https://dennisdel.com/images/postmedia/psa-nest/psa.png"]
---

![Nest logo with a lock](/images/postmedia/psa-nest/psa.png)

We really love the Nest Cam in our apartment. I was recently investigating how the Nest cam works from the inside, as I thought I could access the stream directly. The short answer - you can't, because the stream is behind DRM protection. 

However, I've also realized that a lot of other people are looking for a similar solution, and the approach taken is not only wrong, but flat-out dangerous. What appears to be the mainstream "workaround" is to share the camera as a public one, and then Nest will generate a link that can be embedded in other web pages. Then, users can pick up the [m3u8 link](https://en.wikipedia.org/wiki/M3U) to their stream and use it with third-party software to keep track of the camera and capture the stream.

**Please, DO NOT MAKE YOUR CAMERA PUBLIC** unless you want the content to be public. The URLs generated follow a very predictable pattern, and the camera unique identifier can be easily substituted. More than that - some of the generated links are indexed by various search engines, and are (somehow) included in various code repositories.

When you make the camera public, **do not ever trust advice that nobody will be able to guess the URL** - they will. If it is facing the internet with no authentication - it will be discovered.