---
title: It's Time to Ditch SMS 2-Factor Verification
type: blog
date: 2018-02-24T22:04:10+00:00
slug: ditch-sms-2fa
news_keywords: [ "security", "sms", "opinion", "2fa", "technology" ]
images: ["https://dennisdel.com/images/postmedia/ditch-sms-2fa/heading.jpg"]
---

It's 2018, and it's time we understand that **SMS 2-factor authentication is not a good way to double-check the users' credentials**. It's been shown many times that phone numbers can be compromised. 

![Phone laying screen down on the pavement](/images/postmedia/ditch-sms-2fa/heading.jpg)
(_Image sourced from [Pixabay](https://pixabay.com/en/iphone-6-apple-ios-iphone-ios-8-458150/)._)

## The problem

Here are just some examples of how cellphone number and customer data can be at risk:

| Security Issue | Date |
|-----|-----|
| [T-Mobile exposes endpoint with account details](https://www.engadget.com/2017/10/11/t-mobile-website-flaw-social-engineering-hacks/) | October 2017 |
| [Cellphone accounts hijacked to go after cryptocurrency owners](https://www.nytimes.com/2017/08/21/business/dealbook/phone-hack-bitcoin-virtual-currency.html) | August 2017 |
| [Hackers able to hijack cellphone accounts](https://www.fastcompany.com/40432975/how-to-steal-a-phone-number-and-everything-linked-to-it) | July 2017 |
| [Thieves able to port cellphone numbers](https://www.nbcchicago.com/news/local/Thieves-Able-to-Hack-Cell-Phones-Through-Porting-373934121.html) | March 2016|

I can go on. The problem is so bad that the US Federal Trade Commission issued [its own blog post](https://www.ftc.gov/news-events/blogs/techftc/2016/06/your-mobile-phone-account-could-be-hijacked-identity-thief) documenting how these schemes work, referencing the [Red Flags Rule guidance](https://www.ftc.gov/tips-advice/business-center/guidance/fighting-identity-theft-red-flags-rule-how-guide-business). And yet, we are proven over and over again that social engineering works against the consumer interests.

Phone numbers are not reliable. Phone numbers can be hijacked. Phone numbers change. Phone numbers stop working when you are traveling and not roaming. Phone numbers don't work when you are using in-flight Wi-Fi. Phone numbers can stop receiving text messages/calls for a million of other reasons, effectively either (**1**) locking users out of an account or (**2**) compromising the account altogether. And, as last week has shown, something that was registered as a 2FA number [can potentially be used for completely non-security reasons](https://www.theverge.com/2018/2/14/17014116/facebook-2fa-two-factor-authentication-auto-post-replies-status-updates-bug).

And yet, there are are still services that offer 2FA **only** through SMS.

## What are the alternatives?

There are several, and depending on the service, some might be more convenient than others. [Outlook](https://outlook.com) uses [Microsoft Authenticator](https://docs.microsoft.com/en-us/azure/multi-factor-authentication/end-user/microsoft-authenticator-app-how-to):

![Microsoft Authenticator asking for confirmation](/images/postmedia/ditch-sms-2fa/authenticator.png)

The way it works is it skips passwords altogether - once you connect the app to the account, you can remotely confirm the login by approving or denying the notification, and using TouchID (super-convenient, if you are on your iPhone) validating the request. This method stil assumes that your device has an active Internet connection

There are alternatives where you can confirm your identity even if the device where you are authenticating has an Internet connection, and the "second factor" does not - apps like [Authy](https://authy.com/), [Microsoft Authenticator](https://www.microsoft.com/en-us/store/p/microsoft-authenticator/9nblgggzmcj6) (yes, it supports standard tokens that are [refreshed every 30 seconds](https://en.wikipedia.org/wiki/Time-based_One-time_Password_Algorithm)) or [Google Authenticator](https://www.google.com/landing/2step/) solve the problem singlehandedly.

Or use [U2F](https://en.wikipedia.org/wiki/Universal_2nd_Factor)-compatible devices like [the YubiKey](https://en.wikipedia.org/wiki/YubiKey) which is probably the [best way to go about secure authentication](https://www.yubico.com/2016/02/use-of-fido-u2f-security-keys-focus-of-2-year-google-study/) since it relies on a physical token be connected to the authenticating device.

These methods survive phone number changes, and the only way to compromise them is to be in physical posession of an unlocked device. Not to say that operational security is not important, because people will [find a way](http://thedailywtf.com/articles/Security_by_Oblivity) [to compromise even the token-based approach](https://stackoverflow.com/questions/1983879/ocr-an-rsa-key-fob-security-token), but it still is magnitudes safer than relying on SMS messages or phone calls.

It's by no means a trivial change on the provider side to properly implement token-based 2FA (either physical or numeric), but ultimately it will help users much more in the long run.

It's time SMS 2FA goes the way of the floppy disk.