---
title: Tech Support Scam Site - Beware of Jammed Safari
type: blog
date: 2018-02-06T04:43:54+00:00
slug: support-jam-safari
mages: ["https://dennisdel.com/images/postmedia/safari-lock/safari-problem.png"]
news_keywords: [ "safari", "ios", "techical", "security", "safety", "privacy" ]
---

Recently I've been reading a tech site on my iOS device when a new tab opened and went into the background - something I've seen before caused by rogue ads that are fetched via normal means (e.g. embedded in a legit page), so my next steps were not unusual - go to the tab and close it. Here is what I faced:

![Safari locked by a tech support scam](/images/postmedia/safari-lock/safari-problem.png)

Once the tab opened, I instantly recognized it as one of those tech support scams. Clearly they want to automatically call whatever number it is programmed to call, which I can only assume will go to one of those call centers where you will be asked to provide some private information to unblock the phone from some scary virus that might be stealing your info from your iPhone.

To add the vibe of legitimacy, the site also pretends like it's Apple, and points out that it detected "illegal activity" - laughable, no?

Looking closer at the URL:

```
www.security-breach-info.info/11/index11.html?phone=SUCKIT
```

The phone number here is deliberately masked by me into something that nobody will call, and obviously you can see it in the screenshot above. Ingenious. So what happens if I cancel out and don't call anything?

Safari locks up completely. Given that it's sandboxed and no external process can affect other processes, I can just exit out:

![Exit Safari](/images/postmedia/safari-lock/exit-safari.png)

But what is happening that Safari is being jammed to a dead-end where, if left open, it just crashes? Apparently whoever owns the site, created some malicious JavaScript that runs in a loop - this can be inspected by using an external view-source tool:

![Bad JS](/images/postmedia/safari-lock/bad-js.png)

Looks like your run-of-the-mill script kiddie stuff, where you lock the browser by overloading the JS engine. Cool, so time to report this domain for pretending to be someone else, right?

A bit of a WHOIS magic and we get the information on the domain owner, and reveals that the domain was registered on GoDaddy:

![WHOIS information on domain owner](/images/postmedia/safari-lock/whois.png)

Ideally, we should be able to contact GoDaddy and report domain abuse, so that's what I did:

![GoDaddy contact](/images/postmedia/safari-lock/contact-godaddy.png)

I got a canned response that mentioned that the current abuse email is just for general complains, and that I need to assign a "bucket" to my report, depending on which I need to file the report to the appropriate channel. Which I did:

![GoDaddy contact](/images/postmedia/safari-lock/godaddy-part-2.png)

And then there was no response. The GoDaddy policy is that they don't follow-up on reported domain abuse cases, which is fine, however, today, at the time of publication, the domain is alive and well, still with GoDaddy. If you know a better way to report it, please let me know, because while tech-savvy people can see what this is about, those that aren't are likely to get scammed.