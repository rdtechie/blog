---
title: Get Ahead in a Waitlist, or How To Never Trust The Client
type: blog
date: 2017-04-16T20:58:02+00:00
---
As a developer, it is always important to keep in mind one thing &#8211; **never trust the client**. Ever. The client is neither a completely secure entrypoint nor the source of truth moving upstream to the service.

**NOTE:** This issue has already been addressed and the fix is live. Shoutout to [Kyle Rankin][1] for being on top of things and responding to my email.

So that brings us to January 8, 2017, when I discovered [getfinal.com][2]. The gist of the service is that you get a credit card with no single assigned number, so technically if one number gets compromised, you can just regenerate a new number.

Fantastic idea, so I decided to sign up, but once I submitted my email, I also faced this:

![Signup screen](/images/postmedia/never-trust-the-client/signup.png)

Uh oh. That sounds like a pretty long wait. So what can we do? Well, I don&#8217;t necessarily want to spam my Twitter followers with links to services that _**I prefer/try out**_, but I have no problem doing that with email (my family grew to be very tolerant of my shenanigans and sending them links to absurd invitation-only places on the web). So the option is pretty obvious &#8211; let&#8217;s email myself, to my secondary email, the link.

![Email invitation](/images/postmedia/never-trust-the-client/nocard.png)

Great, so I now have a referral link. And hey, let&#8217;s see if I can sign up someone through this link.

I started an incognito window, pasted the URL, and entered some absolutely unusable (but valid) email. The system accepted it, and my number in the queue went down. This got me thinking&#8230;

This doesn&#8217;t seem right. Surely there are more safeguards from just submitting new emails over and over through the system in incognito window? But maybe not? Let&#8217;s try to enter something other than an email:

![Email validation](/images/postmedia/never-trust-the-client/invalid.png)

Ah, ok. So the client-side validation kicks in and it won&#8217;t allow me to submit just anything I want. So let&#8217;s dig deeper.

I fired up Fiddler, to see where the request is actually sent:

![Fiddler screen](/images/postmedia/never-trust-the-client/fiddler.png)

So this all looks pretty typical. Notice that the email is URL encoded and sent via a POST request that includes data representative of both the referring hash and the sign up URL. Great. So let&#8217;s see what the server will do if I sent it just some random string instead of an encoded email.

To my surprise, **it worked**. Server-side, there was no validation to see whether the email submitted was valid. My counter kept going down, but still not fast enough. Time to fire up Visual Studio and write a little console app that can automate this task):

Lo and behold the counter kept going lower&#8230;

![Invitation counter](/images/postmedia/never-trust-the-client/Screenshot-2017-01-08-22.57.58.png)

And lower&#8230;

![Invitation counter](/images/postmedia/never-trust-the-client/Screenshot-2017-01-08-23.19.50.png)

And lower. So while the moral of the story remains the same as the start of the blog post &#8211; never trust the client, how can Final mitigate this?

1. **Add server-side validation for the email address**. If the string is not a valid email, don&#8217;t count it towards the invite system.
2. **IP-range checks for timing.** If you have more than an alloted number of requests coming from the same IP address, there is a high-probability that the same client is issuing the request, and therefore invalidating the requests to shift the position in the waitlist.
3. **Verification of invited emails**. This is surely the easiest way to ensure that emails submitted are actually valid. When a user submits an email, do not move the original user&#8217;s position in the waitlist until they confirmed that the shared email is actually owned by a person.

None of the above will make the system absolutely tamper-resistant, but it will add a number of roadblocks that will just make it not worthwile for others to try and game the backend.

## **Disclosure Timeline**

* **January 8, 2017** &#8211; Disclosed the issue to <security@getfinal.com>.
* **January 16, 2017** &#8211; Kyle Rankin, VP of Engineering at Final reached out acknowledging the issue.
* **April 16, 2017** &#8211; Verified that the issue has since been fixed.

 [1]: https://twitter.com/kylerankin?lang=en
 [2]: https://getfinal.com/