---
title: On Importance of Documentation
type: blog
date: 2016-10-30T21:04:06+00:00
---

This October marks a year since my switch from working on client software to working on the unified Microsoft documentation experience. Throughout the past year I had to learn a tremendous amount of absolutely new (to me, at least) things that totally changed my perception of what the importance of documentation is.

#### Building Documentation Systems is Not Easy

I like to think that this is what I looked like when I was first coming in, thinking &#8220;_well of course, publishing systems &#8211; we&#8217;ll get this done_&#8220;:

![Birdman](/images/postmedia/on-importance-of-documentation/birdman.gif)

Here is me a month in, realizing the sheer amount of complexity involved both in the publishing process as well as in getting a balance between the internal and external needs:

![Thinking GIF](/images/postmedia/on-importance-of-documentation/thinking.gif)

When it comes to documentation, it&#8217;s often not as simple as &#8220;_spin up a new website and just start hosting it there_&#8220;. There are requirements and expectations from the user &#8211; how they want to see content organized, structured and presented. The needs also vary between users who are using _Platform X_ vs. users who are used _Platform Y_. That translates into systems that need to abstract out a lot of those under the hood of a unified experience. That is both time and resource consuming.

On the other hand, at scale, you also have multiple creators involved &#8211; people that actually write the documentation. Take yourself as an example. What editor do you like to use daily to write a document? How about your favorite JavaScript editor? What do you use for Markdown editing? Notice that by now, you are lucky if for the three questions above, you have two common editors. Now take that and apply to content that is describing how to work with different platforms (e.g. content related to Node.js vs. content related to building apps with Visual Studio for Universal Windows Platform). Writers have their own set of tools that make them productive &#8211; unifying that and creating a single standard is a significant undertaking that you can&#8217;t just push as &#8220;_Alright, here is what we start using starting Monday_.&#8221;

And now take all of the above and apply them to the Microsoft scale, where we work on tens of thousands of pieces of content. And a lot of them are generated from automated code-scanning tools.

#### Code Comments are Never Enough

![Thinking Master Chief](/images/postmedia/on-importance-of-documentation/think_chief.jpg)

While at first glance, &#8220;_never_&#8221; might seem like an exaggeration, I learned first hand that it isn&#8217;t. You want detailed docs. You want docs that tell you _why_ you are doing certain things and not just _how_. After writing several tools, setting up several dev environments for a number of other tools &#8211; no, comments are never enough. Even two months in, sometimes I would look back and realize that I have no idea what I was doing. Hours later, the realization comes: &#8220;_Oh yeah, I forgot there is a parameter somewhere that is forced in a certain value so now I have to re-define it within the extension_&#8220;.

Not something that you want to write an essay within your code, and guaranteed you are not the first and last to stumble over a certain issue &#8211; so spend an hour writing a doc that outlines how something works.

#### Writing Documentation Helps You

That is, regardless of whether you are a developer, writer, manager or marketing person. In my own position, as a PM, I strongly believe that a great PM knows how to write great copy. And for that to happen, you need practice. Practice in making your documentation more accessible, more engaging and covering the customer needs.

You want to be able to put together coherent, thought-through pieces that make the user both delighted with the quality, but also with the ability to finish the needed task from A-Z.

The above will benefit you long-term and way beyond just your career.

#### Documentation is Not &#8220;Write and Forget&#8221;

![Men in Black](/images/postmedia/on-importance-of-documentation/forget.gif)

More often than not, you and your users will refer to the same piece of documentation over and over, over the span of weeks, months and even years. Maintenance here is never an after-thought but an expected part of the lifecycle (speaking of which, do take a break and listen to this Freakonomics podcast &#8211; &#8220;[In Praise of Maintenance][1]&#8220;).

As you plan investment into your docs, account for the fact that you will need to make changes, additions and remove obsolete parts of those. Documentation is not a blog post (and I see the irony here) where it attracts attention for a couple of days and then dies down. It&#8217;s an evergreen organism that people rely on in business and personal life.

#### Documentation is also a Product

Too often I hear that documentation is something that compliments a product, but is not the product itself. The reality is &#8211; documentation for a tool or service is just as important as the product itself. It is important to always collect, assess and react to customer feedback, it is important to keep it updated and it&#8217;s even more important to _**write it**_.

Don&#8217;t assume that users will figure things out, and for new problems that they will encounter docs will be written. Taking that path will lead you down the road you don&#8217;t want to go.

#### Documentation Goes Beyond Technical Writing

Think about the last time you used a developer doc. What went into it? Depending on the product or language that you were looking at, you will realize that the doc contained some code samples, screenshots, animations, links to a videos (or any combination of thereof).

All that is key to creating great documentation, just as much as it is key to be _**writing**_ great content. Make your documentation engaging by providing multiple ways for your users to consume it. Enable your users to download a sample and execute it to see how the app works, enable them to watch an interactive video that shows step-by-step how things work.

Personally, I am not a fan of walls of text &#8211; what if what I am reading is not even relevant to me? In what ways can one show appreciation for users&#8217; time and effort put towards learning your tool/language/product? By having them actually see that the things they need are the things you are offering vs. making them sift through mountains of articles only to realize that what you described isn&#8217;t even covering their scenario.

#### In Conclusion

I am sure that as months and years go by, more lessons will be learned, more caveats will be discovered to everything I wrote above, and even more documentation will be written. The one important lesson that stuck with me, though, is this &#8211; it&#8217;s never as easy as &#8220;_write and click Publish_&#8220;.

 [1]: http://www.podcastone.com/embed?progID=437&pid=1686724