---
title: New FoggyCam Release - Support for 2-Factor Auth and Python 3
type: blog
date: 2018-02-17T20:58:02+00:00
slug: new-foggycam-two-factor
news_keywords: [ "nest", "camera", "how-to", "aware", "foggycam" ]
images: ["https://dennisdel.com/images/postmedia/new-foggycam-two-factor/laptop.jpg"]
---

This weekend I've spent some time to rework `foggycam`, [the open-source tool](https://github.com/dend/foggycam) to record Nest camera footage locally and to the cloud.

![Laptop with camera next to it](/images/postmedia/new-foggycam-two-factor/laptop.jpg)

(_Image source: [Pixabay](https://pixabay.com/en/laptop-business-technology-computer-3157391/)_)

There are two major pieces being added. First and foremost, the code is now entirely running on top of Python 3. The best way to describe the reason for this change is that Python 2.7 (and FoggyCam until version 1.2 was running on it) is legacy, and Python 3.x+ is the future. You can read more in [the official wiki](https://wiki.python.org/moin/Python2orPython3), but I felt like I would rather do the changes now rather than later when new features and code piles up.

Second change is that the tool now [supports two-factor authentication](https://nest.com/ca/blog/2017/03/07/extra-security-for-your-nest-account/), [starting with release 1.3](https://github.com/dend/foggycam/releases/tag/1.3). This issue was reported in the [FoggyCam GitHub repo](https://github.com/dend/foggycam/issues/6). Previously, if you had 2FA enabled, the tool would fail and no footage will ever be captured. Now, the users are prompted to enter the verification code, that will then be used to determine whether capture will start or not.

The caveat here is that it adds an extra step when deployed to the cloud or the tool is used in any automated shape - it will be required to connect to the terminal and make sure that the code is entered. After that, the tool will run in mostly autonoums manner.

>**NOTE:** If you have the possibility, **ALWAYS** have two-factor authentication enabled. If your password is ever compromised, it is another layer of protection that can prevent the attacker from accessing your account.

It's also important to note that too many failed attempts to authenticate with invalid codes will result in your Nest account being temporarily locked out - you'll know that's the case if you can't log in through the web UI or getting [429 responses](https://developer.mozilla.org/en-US/docs/Web/HTTP/Status/429) when trying to query the API.