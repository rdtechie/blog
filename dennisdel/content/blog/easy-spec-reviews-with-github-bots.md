---
title: 'Easy Spec Reviews with GitHub & Bots'
type: blog
date: 2017-04-16T18:14:46+00:00
---
As a Program Manager, part of my job is to [write technical specification][1] documents. Our team recently switched to using our very own system (yes, we use the [docs.microsoft.com][2] infrastructure internally too) to write technical specs &#8211; content is on GitHub and Markdown-based. As part of that came the question &#8211; how do we aggregate comments when people review them?

One solution that came up during a weekend hack session was to use GitHub for review comments as well. But how do we make sure that there is a consistent experience across the board? Well&#8230; by auto-creating GitHub issues and embedding links to them in the spec themselves. I thought I would use some of the [infrastructure that I&#8217;ve already put in place][3], and re-purpose it to the spec review needs. This resulted in [SpecBot][4].

Generally, it works like any other GitHub bot &#8211; with the help of web hooks through an Azure-hosted node.js application. When a new commit happens, we send a **push** event to the bot. See what happens next:

If the **x-github-event** is **push**, then we can use [node-github][5], piped through a **bot** helper class. Once we get the commit, the only thing we need to check is whether the file was added (at this time, I skipped retroactive addition of review items to existing specs), placed in the target directory and is a Markdown file (specs are only **.md**).

At this point, we need to start reading the content from the doc, if we indeed detected one:

I am still using the **bot** helper class to perform the content pull &#8211; once the GitHub API returns it, it will be in Base64-encoded format, hence there is a need to transform the data into a readable UTF-8 string.

Something to keep in mind with Markdown files that we use is that we also append YAML metadata, to it. There is a variety of reasons for that, but one of the big ones is organizational &#8211; it&#8217;s a relatively cheap way to add any information related to the content without affecting the content itself. As an example, all specs have a **keywords: spec** metadata entry, as well as a **title**.
  
View this raw to see how the YAML header is structured.

Now, lucky for us, we have [yaml-front-matter][6] to read the header content. Once we identify that it has the spec metadata and a filled title, a new issue is created for the spec:

![Spec Review](/images/postmedia/easy-spec-reviews-with-github-bots/specreview.png)

The issue links back to the file, for easy discoverability. The last step is updating the file itself, and that is done by pulling the content, adding an extra line that points to the issue (GitHub API will return the issue URL) at the very end of the file, encoding it back into a Base64 string and committing it into the repo.

Voila, an easy way to organize spec review comments!

 [1]: https://softwareengineering.stackexchange.com/questions/179554/what-is-the-difference-between-technical-specifications-and-design-documents
 [2]: https://docs.microsoft.com
 [3]: https://www.dennisdel.com/content-validation-bot-github/
 [4]: https://github.com/dend/specbot
 [5]: https://kaizensoze.github.io/node-github/
 [6]: https://www.npmjs.com/package/yaml-front-matter