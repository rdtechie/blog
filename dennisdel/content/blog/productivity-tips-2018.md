---
title: Productivity Tips - 2018 Edition
type: blog
date: 2017-12-26T01:00:00+00:00
slug: productivity-tips
---

2018 is (almost) upon us and many people are making new resolutions for what they want to achieve in the new year. I wrote about some of [my high-level goals as well](https://dennisdel.com/blog/year-in-review-2017/). The one piece missing in it is the _how_ description, and for that I decided to write this post. Just like the overview post, I want to make this a yearly tradition - a set of tips on how to maximize productivity, based on learnings from the previous year.

![Christmas Tree - Vancouver](/images/postmedia/productivity-tips/tree.JPG)

## Use a task board

Probably the best habit that I picked up today was keeping a task-board for all the things that I need to do. Granted, your company might have a bug tracker system, you might have a to-do list (paper or not), but none of those can combine (at least for me) the power of a task board.

![Trello Board GIF](/images/postmedia/productivity-tips/trello.gif)

I am using [Trello](https://trello.com/) for every task I need to keep track of. It supports multiple boards (so that I can clearly separate personal from work), custom columns (personal and work items belong in different buckets), it's easy to share with others (my wife is also using it with me) and it has a plethora of tools you'd expect from a task-tracking system like assignments, attachments, labeling, etc.

![Bookmark](/images/postmedia/productivity-tips/bookmark.png#center)

I became much more disciplined on always looking at the board for things that need to be done, as well as much more disciplined about actually going to the board to add things that need to be done. Having a central location for those and not having to sift through notebooks, emails, etc. is a huge time-saver.

Some people can have the same thing in a more [analog format], but I personally want to reduce the amount of paper I need to carry around.

## Disable notifications for anything non-essential

![Hear No Evil Monkey](/images/postmedia/productivity-tips/monkey.png#center)

You carry your phone with you. Likely you also have a smart watch that buzzes in sync with when your phone gets a notification. The reality is - most of those notifications are not at all essential to what you are doing during the day.

With each notification, I used to pull up my phone to see what is going on - even if I did not open (act on) the notification, it was still a distraction that interrupted my work rhytm. And guess what? Through the day, those pile up to a significant amount of time. Did you really need to know that someone liked that Instagram photo? Or that you have a new LinkedIn connection?

So I took the extreme route - disabled push notifications on my phone for anything that I know for a fact is not critical to me getting things done (which is close to every app I have installed). Snapchat? Silent. Outlook? Silent. Slack? Silent. You get the idea. I can always open those apps at the end of the work day to see what is up, or at my own time.

The only apps I keep notifications on are nowadays the apps that I use to communicate with friends and family, and that might require immediate attention (e.g. iMessage, Messenger and KakaoTalk).

## Split your email in two - inbox and catch-all

You start your work day, you open your email and...

![Ron Swanson throwing computer in trash](/images/postmedia/productivity-tips/trash.gif)

Just like with notifications, you get non-essential mail. Every time a new email comes in, you have to spend mental cycles to understand the scope of the email, what needs to be done, who needs to be contacted, what other apps you need to fire up to validate something, and other actions that are likely not directly related to _what you are doing or need to do right at the moment the email came in_.

So here is a solution - sort the email. No, [not just for distribution lists](https://superuser.com/questions/664128/how-to-create-a-rule-for-a-contact-group-distribution-list-in-order-to-move-emai).

I created a rule that puts **into the inbox** everything that is:

- **Tagged with a red bang (!)** - clearly whoever is sending it needs my attention NOW.
- **From my manager** - anything coming from my manager is important and requires attention.
- **From my skip-level** - my manager's manager emails are all defaulted to high-priority as well.
- **From VP/CEO** - very important emails related to company/organization.

Everything else that does not fit one of the line-items above will go into a folder called **Catch-All** - I can read everything in the catch-all folder at my own pace, after I am done with other high-priority tasks on my radar.

Remember this one key thing - when you are constantly answering email, you are being **reactive**. You are fighting fires, since every time a new emails comes in, you respond to it, and by the time you finish replying, there is a new email. Your goal is to become **proactive** at addressing correspondence.

## Use a notebook

![Notebook](/images/postmedia/productivity-tips/notebook.png#center)

Just like with the task board, it's a good idea to keep track of all the notes you have in electronic form. Found a small hack that can simplify a telemetry query you're writing? Put it in the notebook. Planning a birthday surprise for your wife? Put it in the notebook. You want **one** place for all the notes, big or small.

I highly recommend [OneNote](https://www.onenote.com/) - it's free, and it's awesome. I do work for Microsoft, but I also really enjoy this product - it allows for intuitive content structuring, and has a pretty reliable search integrated directly into the application. I pretty much stopped using paper notebooks for anything other than writing down notes from learning sessions.

## Automate, automate, automate

![Rocket](/images/postmedia/productivity-tips/rocket.png#center)

I want to maximize my time on important things - interesting projects and my family. This implies that I need to reduce time spent on things that are _routine_. What do I consider routine you might ask? Any little thing that takes away from your time that otherwise doesn't have to because it can be done more efficiently in an automated manner.

Here is a couple of examples of how I optimized routine tasks:

* **Blog Publishing** - set up a Continuous Integration (CI) job in [VSTS](https://www.visualstudio.com/team-services/) that automatically builds and publishes my blog to the cloud. I don't have to manually check in content, build it, copy it to cloud storage - it's all scripted.
* **Social Media** - I manage the [@docsmsft twitter account](https://twitter.com/docsmsft). We often want to highlight some of the most awesome content we publish. I made sure that it's queued for a month in advance, and on each tweet, an automated (read - [IFTTT](https://ifttt.com/)-style) notification is sent to the appropriate team channels to let them know the content announcement is live. I don't need to manually do this every day.
* **Documentation Generation** - I am on the team that publishes a lot of documentation. I formalized all .NET-based Continuous Integration (CI) jobs in well-defined templates that handle all the processing for the user - I don't have to manually set them up.
* **Budgets** - I keep track of my [financials in a spreadsheet](https://dennisdel.com/blog/5-reasons-why-i-switched-from-mint-to-a-spreadsheet/) that do automated tracking of financial snapshots and projections. I don't have to manually try to take snapshots and generate new charts - it's all done on its own.

Need to re-image your machine? [Write a script](https://ryanstutorials.net/bash-scripting-tutorial/) that installs all the software automatically and you don't have to download and install them by hand. Posting to social media across different sites? [Use IFTTT](https://ifttt.com/) to post to many networks at the same time.

You might need to invest some time in learning a scripting language like [bash](https://en.wikipedia.org/wiki/Bash_(Unix_shell)) or [PowerShell](https://en.wikipedia.org/wiki/PowerShell), but that will ultimately pay off long-term!

## Sync to cloud

Both a time-saver and a generally good practice - sync your content to the cloud. I will leave it to your discretion to choose _what_ you want synced, but all I can say is that it really reduces your time in maintaining backups and moving content between computers when you need it the most.

![Sleeping cloud](/images/postmedia/productivity-tips/cloud.gif)

I am running my own O365 subscription (at [$5/mo](https://products.office.com/en-us/business/office-365-business-essentials), you can't beat the deal), so I have direct access to [OneDrive for Business](https://support.office.com/en-us/article/What-is-OneDrive-for-Business-187f90af-056f-47c0-9656-cc0ddca7fdc2) (OD4B) - fantastic tool to keep all the necessary files that need to be synchronized across all my machines, both [Mac](https://itunes.apple.com/ca/app/onedrive/id823766827?mt=12) and [Windows](https://www.microsoft.com/en-us/store/p/onedrive/9wzdncrfj1p3). 

One drawback is that because I have OD4B, I can't easily sync photos from my phone. Luckily, for that I am just relying on a free Dropbox instance (through the years I've accumulated ~9GB of storage) - just enough space to back up a year's worth of whatever goes into my [Camera Roll](https://www.cnet.com/how-to/where-to-find-your-camera-roll-on-ios-8-1/). Then I just move that into OD4B, and voila - I have more space in Dropbox to backup some more photos.

No more connecting the phone to iTunes to back it up, or moving files between machines on flash drives!

## Rely on a calendar

![Calendar icon](/images/postmedia/productivity-tips/calendar.png#center)

Not to sound like captain obvious here, but become **really** disciplined about putting stuff on your calendar. Have a meeting? It's on your calendar. Planning to be out of office? Put it on the calendar. Have an outing to the aquarium? You got it - put it on the calendar. That way you will know for a fact where you are allocating time.

Also make sure that you let others see your calendar. Scope can vary (your wife is probably not interested in your work calendar, and your manager doesn't really want to see that you're taking your kid to soccer practice), but it's important that in your line of work, people that need to be aware of your work are. 

One of the first things that my first manager at Microsoft taught me was how to open up the work calendar for the entire Microsoft to see. Yup, [Outlook has that setting](https://support.office.com/en-us/article/Share-an-Outlook-calendar-with-other-people-353ed2c1-3ec5-449d-8c73-6931a0adab88). The benefit of that was that instantly, all my coworkers knew if I am attending their spec review, or am in a heads-down session.

## Schedule time to answer email

![House MD typing on a keyboard](/images/postmedia/productivity-tips/house.gif)

As a follow-up to previous points, block off time on your calendar to answer emails. No other things - just looking at your inbox and addressing concerns and questions of your partners, engineers and teammates.

It can be 1 hour a day, or 2 hours every two days - if you've noticed, the meta-point of this post is that there is a lot of flexibility in _you yourself_ determining _what is the right time allocation_ for things. I am not trying to claim that there is a magic number of minutes you can spend on email every month to make sure you un-bury yourself from the ever-growing pile of electronic paper.

Generally, I've noticed that for me, an hour and a half a day does wonders (barring any emergencies or live site issues). The rest is highly-productive work on product areas and meetings.

## Schedule time to work on things that are not email or IM

![Girl emoji crossing arms in an X](/images/postmedia/productivity-tips/no.png#center)

Block off chunks of your calendar when you are not available for communication (again, barring any emergencies). Pure, awesome focus time - put on your noise cancelling headphones, set the IM status to "_Do Not Disturb_" and start building that prototype you've been meaning to build for the next version of your product. Or write a blog post. Or put together a specification document. The key here is to focus on getting stuff done instead of reacting to external stimuli. And whoever looks at your calendar knows that this is exactly what you're doing.

## Reduce distractions

![Kanye West appearing unusually happy](/images/postmedia/productivity-tips/distracted.gif)

Stop checking Facebook every 2 minutes. Stop going to Twitter to just see what other opinion is out there every 2 minutes. Stop going back to Facebook after checking Facebook and then Twitter 4 minutes ago. Really - mindless social media consumption eats a significant chunk of your day. Trust me - **you're not missing anything urgent if you are not personally contacted about it**.

I've removed Facebook and Twitter from my phone completely - I don't need them there, because it would only constantly tempt me to open the app and see what's up. Oh I am waiting for the CI job to finish? Let's check Twitter. Oh I am waiting for my machine to update - let's see what Facebook notifications I got. Enough of that! Instead, I can now focus on important things during those time blocks - talk to my spouse, read a page or two of a book, fix a bug in a tool I maintain and other things. Something with a measurable positive output.

This is not to say that you should not use social media - I know I do. But use it **with purpose** and not **at the cost of interrupting your workflow**.

If you really need an "enforcement" nudge, if you are a Google Chrome user, install [StayFocused](https://chrome.google.com/webstore/detail/stayfocusd/laankejkbhbdhmipfmgcngdelahlfoji?hl=en) - it's an extension that can block social media websites at certain time intervals.

Outside social media, distractions can be noises (e.g. talking people), visuals (e.g. a TV running in the background), phone notifications, etc. - your goal is to build an environment for yourself where 100% of your attention is on the tasks that you are trying to accomplish, with no interruptions.

## Be self-aware

![Man shruging](/images/postmedia/productivity-tips/self.png#center)

Know your weaknesses. Understand that you are not as productive as you could be because of factors X, Y and Z. This blog post is not a playbook - it's merely some anecdotal advice that I aggregated myself from my experience. Your personality traits, your work environment, your involvement with different resources all dictate _how_ you can apply better productivity tactics. It's up to you to **understand** what works and what doesn't for you. 

To become productive, you need to learn that you are unproductive.

## Learn to say no

![Sloth saying no](/images/postmedia/productivity-tips/nope.gif)

If you know that for the next meeting you will go into the conference room, but all the time you will be there you will be on your laptop coding, you don't need to be in that meeting. Decline it. If the meeting is not at all relevant to what you do, decline it. You don't need to be in every meeting that lands in your mailbox.

You are not responsible for every single routine task (that you can delegate to appropriate parties). Learn to detect situations where your involvement is not necessary, and put that time to use to something that actually will have an impact on your team and your product.

## Balance

I can't overstate how important it is to productivity to have **a balance** between work and the rest of your life. Nothing recharges you more than taking a break from the task and focus on your family & friends - take a trip, go eat at the neighborhood Korean restaurant, take your kids for a walk or go see a movie.

![Man shruging](/images/postmedia/productivity-tips/persona.jpg)

Your work is important, but so is your personal health, happiness and well-being. I live by the mantra that my success is my family's success - it's a composite metric, rather than a one-sided one. You have to drive two sides to make sure that your overall success is maximized.

Take breaks, replenish your energy, and get back into the battlefield with a fresh mind.

## Conclusion

All of the above can be done only if you know how to _build out discipline_ and _communicate_. You can't just set your IM client to "_Do Not Disturb_" and expect that your team and manager will know that you're not just away from your desk, and might not be able to help when it's urgent. Nobody but you controls how you allocate your time, so no matter how many extensions you install, it will be up to you to know not to do pointless scrolls through your Twitter timeline.

The foundation is _you_ and the rest can be applied in a variety of versions, either derived from the items I listed above, or completely different.

Let's see how this topic evolves for 2019!
