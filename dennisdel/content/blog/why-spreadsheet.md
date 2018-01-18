---
title: 5 Reasons Why I Switched from Mint to a Spreadsheet
type: blog
date: 2017-01-02T07:13:33+00:00
---
In light of the new year coming in, a lot of people are setting new goals for what they want to accomplish. In 2016, I set to ditch Mint and instead replace it with a spreadsheet. At first, when I chatted with a couple of friends about it, that seemed like a somewhat cumbersome switch &#8211; after all, Mint does a lot of the tracking automatically. I am a huge fan of automation, so I saw how moving back to a more manual way of keeping things in check would be more time-consuming and inconvenient. But as the year went by, I grew to love the spreadsheet budgeting method vs. Mint. Here is why.

## 1. Security of Your Bank Credentials

Of course, [Mint boasts about being secure][1], using two-factor authentication, a secured app and participating in VeriSign security scanning procedures. That said, you need to also account for the fact that they store your bank credentials &#8211; and while encrypted, those are [put in a reversible chain][2]. For banks that do not expose a read API (and this is, in itself, a part of the problem), Mint does direct log in on your behalf with your bank credentials.

Now recall, the last time you logged in with your bank creds, how many operations can you take? Transfer money? See confidential documents? By no means am I saying that Mint will use the credentials to be a part of some mischief, but by giving your confidential credentials to a third-party, you are inherently increasing the potential attack surface on your financial assets.

[According to their own terms][3], they would not be responsible for any losses a user might incur in case of a breach:

> INTUIT SHALL IN NO EVENT BE RESPONSIBLE OR LIABLE TO YOU OR TO ANY THIRD PARTY, WHETHER IN CONTRACT, WARRANTY, TORT (INCLUDING NEGLIGENCE) OR OTHERWISE, FOR ANY INDIRECT, SPECIAL, INCIDENTAL, CONSEQUENTIAL, EXEMPLARY, LIQUIDATED OR PUNITIVE DAMAGES, INCLUDING BUT NOT LIMITED TO LOSS OF PROFIT, REVENUE OR BUSINESS, ARISING IN WHOLE OR IN PART FROM YOUR ACCESS TO THE SITES, YOUR USE OF THE SERVICES, THE SITES OR THIS AGREEMENT, EVEN IF INTUIT HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGES. NOTWITHSTANDING ANYTHING TO THE CONTRARY IN THIS AGREEMENT, INTUIT’S LIABILITY TO YOU FOR ANY CAUSE WHATEVER AND REGARDLESS OF THE FORM OF THE ACTION, WILL AT ALL TIMES BE LIMITED TO A MAXIMUM OF $500.00 (FIVE HUNDRED UNITED STATES DOLLARS).

Chase, for example, [explicitly warns its users][4] about potential risks of using credentials elsewhere on a non-bank website. Also [check their consumer agreement][5].

## 2. Reporting Flexiblity

I like to build a bunch of different projections, trends &#8211; all different formats, views and types. Mint became very constraining in terms of reporting &#8211; it had the data, but it only showed that data in ways it was designed to. That means that any financial goals would need to be organized in the system would be limited to Mint&#8217;s design decisions.

While for a lot of users that might not be a problem, that became a hurdle for me that I easily solved with Excel&#8217;s plenty of ways to display, organize and filter data &#8211; both built-in functions and macros that I (thankfully, as a software engineer) can write myself.

## 3. Ads & Privacy

Yes, I get it &#8211; Mint is a free product, and needs to self-sponsor through ads. However, I am not comfortable with my financial abilities being shared with third parties, no matter to what limited extent, to generate more revenue for the budgeting service. And in the past year, the ads became slightly more invasive and annoying &#8211; when I logged in to Mint, I saw giant ads first before learning about the status of my accounts.

In addition to that, I am not very keen on sharing my financial data with a third-party from a privacy standpoint. In my opinion, transactions are the business of those involved in the transactions &#8211; me, the bank, and vendors who take payment or provide payment. Adding a middle-man here is an unnecessary component (see above about increasing the surface of attack on your personal data).

## 4. Speed of updates

Mint started lagging in showing all transactions, or even updated transactions. In some cases, things that are posted on the bank site will only be posted on Mint in 3-4 days (especially when it came to bank deposits). That is not that big of a problem for general budgeting tasks, but from a personal standpoint &#8211; I want to see where I am _right now_ in terms of finances, so 3-4 day delay was unacceptable.

There were also cases when I would pay off a credit card, and I would still get notifications that a payment is due in an amount that is no longer necessary. Again, not so much of a big issue as it is an annoyance that just stacks up over time.

## 5. Psychological Factor

Going through all the expenses manually every day (there is still a good amount of automation in the prediction and trend models) made me much more aware of what I put money towards and how I can save better. This is extremely important as often I&#8217;d go _&#8220;Oh that&#8217;s just $5&#8221;_ but once I started adding everything up, I realized just how much is going for those minor expenses.

A couple of months in and I&#8217;ve made some good savings simply through the fact that I was constantly aware of how those would impact other financial prospects.

## Conclusion

The spreadsheet approach is obviously not for everyone &#8211; time is valuable and granted, in some cases the benefits outweigh the drawbacks. There are plenty of spreadsheets that are already built and you can download and use for your own budgeting (you don&#8217;t need to write it from scratch).

That said, I am looking forward to seeing one day a standard bank API that allows read access to financial information, allowing reliable and trusted access to information without exposing unnecessary endpoints.

 [1]: https://www.mint.com/how-mint-works/security
 [2]: https://www.quora.com/How-do-mint-com-and-similar-websites-avoid-storing-passwords-in-plain-text
 [3]: https://www.mint.com/terms
 [4]: https://www.chase.com/resources/guard-your-id-and-password?jp_aid_a=63161950&jp_aid_p=col_uk_home/trip2
 [5]: https://chaseonline.chase.com/Content.aspx?ContentId=COLSA1A_LA#agreement-id-4