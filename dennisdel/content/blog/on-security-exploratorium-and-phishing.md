---
title: On Security, Exploratorium and Phishing
type: blog
date: 2016-10-25T05:59:57+00:00
---

If you don&#8217;t know what the Exploratorium is, I highly recommend you take a trip to San Francisco and [include it in your list of places to see][1]. Today, when I saw a blog post come up with their name in it, I didn&#8217;t expect a story about email phishing, but [there it was][2].

![Exploratorium](/images/postmedia/on-security-exploratorium-and-phishing/Screenshot-2016-10-24-22.15.03.png)

The interesting part was this:

> The address of this webpage had been disguised in the link using a [URL shortener][3], which IT reverse engineered with a [URL expander][4] in order to run a virus scan. The page appeared clean; its only apparent intention was to collect passwords. This webpage was being hosted on another server, this one at a server farm in Texas.

It&#8217;s not unheard of phishing links hiding behind URL shorteners, but what&#8217;s interesting is that with some of the modern technologies, there is an added layer of complexity, and not the good kind of complexity, that is being offloaded on the end-user. And as we know, with the less-technical users, that produces bad results.

First, read [this story from Vice Motherboard][5]. Look over the screenshots. Anything out of the ordinary stand out? Notice that one of the URLs listed is pointing to an AMP page.

![AMP link](/images/postmedia/on-security-exploratorium-and-phishing/Screenshot-2016-10-24-22.16.03.png)

If you don&#8217;t know what AMP is, it stands for [Accelerated Mobile Pages][6], a project led by Google to load content much faster on mobile devices. You can read more about it on the [official &#8220;_How It Works_&#8221; page][7].

So what&#8217;s the problem? Well in this case, AMP acts like a CDN for specially designed content. Effectively, it will be fetched from Google&#8217;s servers ([read more about AMP caching][8]). If you read through the AMP spec, you will realize that anyone can create AMP pages, and therefore, end up with an URL like this for their page:

_https://www.google.com/amp/www.yahoo.com/amphtml/celebrity/9-people-prince-counted-among-235204693.html#_

Let&#8217;s set the Chrome test mode to iPhone 6 (can do so through the inspector/developer console) and load up the page:

![AMP Yahoo](/images/postmedia/on-security-exploratorium-and-phishing/Screenshot-2016-10-24-22.25.41.png)

Alright, so we get the green lock here. For a while, users [have been][9] [conditioned][10] to look at the URL bar and the green lock, so that&#8217;s exactly what they got here &#8211; a seemingly legit domain. Granted, AMP pages also show the domain from which the content is originally fetched, but that is easy to ignore, especially for, *_cough_\* less technical users \*_cough_*.

Let&#8217;s now open this page on mobile:

![iPhone Mail](/images/postmedia/on-security-exploratorium-and-phishing/IMG_2765.png)

![iPhone Safari](/images/postmedia/on-security-exploratorium-and-phishing/IMG_2766.png)

Again, URL bar shows google.com, so this must be Google.

Here is another problem though &#8211; while Google is working on adding anti-phishing measures, such as using your account picture, it&#8217;s easy to mis-use the service through Google&#8217;s own log in endpoint:

_https://accounts.google.com/ServiceLogin?service=mail&continue=_

This takes the user to the log in page, and post-login, redirects the user to the URL declared in the **continue** parameter. You can&#8217;t just put any domain in there, since it will actually require a google.com location. But guess what? You can just put an AMP page in there, and it will work:

_https://accounts.google.com/ServiceLogin?service=mail&continue=https://www.google.com/amp/www.yahoo.com/amphtml/celebrity/9-people-prince-counted-among-235204693.html#_

Now you see the problem? In this inception/triple-pseudo-redirect scenario, the user can assume that they start with Google and end up on a malicious page through the auth pipeline.

Compound that with the fact that once an email is compromised, other recipients might assume that inbound mail coming from that account is safe (it&#8217;s their friend/family, after all, and they shared a document with them).

## What can you do to mitigate that?

![Drake GIF](/images/postmedia/on-security-exploratorium-and-phishing/giphy.gif)

**First**, use a password manager. [LastPass is free][11], [1Password is affordable][12]. The good thing about password managers, other than the fact that they allow you to generate strong, random and long passwords, is the fact that they support auto-fill. If all of a sudden your password is not automatically filled into a field &#8211; that&#8217;s a red flag and you are likely outside the boundaries of a legit domain.

**Second**, add two-factor authentication to all accounts that support it (and most modern services do). Spend $10-$15 and [get yourself a YubiKey][13]. GitHub, Google, WordPress and many others support the physical two-factor key.

**Third**, if you don&#8217;t expect a document, file, photo, video or anything else shared with you, chances are the email is a phishing attempt. Either confirm with the recipient that they actually shared something with you or trash the email altogether.

**Fourth**, do not reuse your passwords. Even with two-factor auth on, your password can be compromised through a phishing attack. It will likely be of little impact to the 2FA-protected account, but you should automatically assume that the password will be tried against other services that you might be signed up for. If you re-used the password and a service didn&#8217;t have 2FA enabled, you&#8217;re in for a very bad time.

 [1]: https://binged.it/2ezWRGB
 [2]: https://www.exploratorium.edu/blogs/tangents/we-got-phished-2
 [3]: http://tinyurl.com/
 [4]: http://urlex.org/
 [5]: http://motherboard.vice.com/read/how-hackers-broke-into-john-podesta-and-colin-powells-gmail-accounts
 [6]: https://www.ampproject.org/
 [7]: https://www.ampproject.org/learn/how-amp-works/
 [8]: https://developers.google.com/amp/cache/overview
 [9]: https://safety.yahoo.com/Security/PHISHING-SITE.html
 [10]: http://lifehacker.com/5873050/how-to-boost-your-phishing-scam-detection-skills
 [11]: https://lastpass.com/
 [12]: https://1password.com/
 [13]: https://www.amazon.com/s/ref=nav_ya_signin?url=search-alias%3Daps&field-keywords=yubikey&