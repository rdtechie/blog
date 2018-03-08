---
title: Migrating UserVoice Ideas to GitHub
type: blog
date: 2018-03-06T15:16:00+00:00
slug: migrating-uservoice-github
news_keywords: [ "uservoice", "github", "migrate", "feedback" ]
images: ["https://dennisdel.com/images/postmedia/migrating-uservoice-github/heading.jpg"]
---

We are all about GitHub on the [docs.microsoft.com](https://docs.microsoft.com) team. We host documentation there and just recently we launched content feedback that's [storing comments in GitHub issues as well](https://docs.microsoft.com/en-ca/teamblog/a-new-feedback-system-is-coming-to-docs). Today, we moved all site feedback to GitHub as well.

![Stacked mailboxes by the side fo the road](/images/postmedia/migrating-uservoice-github/heading.jpg)

(_Source: [Pixabay](https://pixabay.com/en/wood-outdoors-nature-rural-3046186/)_)

Prior to the move, all our site suggestions and feedback were on UserVoice, and as we kept consolidating the feedback triage locations, site feedback was [next in line](https://github.com/MicrosoftDocs/feedback/issues). But how do we accomplish this?

Manually moving things over was not exactly my style, so I thought I would script it. There were two key things in place that helped me - the [UserVoice Python SDK](https://developer.uservoice.com/docs/api/python-sdk/) and [PyGitHub](https://github.com/PyGithub/PyGithub). You can get the same script that I used by looking at [my tools repo](https://github.com/dend/tools/blob/master/uservoice-to-github/migrate.py).

Following the script, first thing we need to define all the required automation credentials. That is - the API keys.

{{< gist dend ff826c7a46e32d0d9e2e0fc3ae6f6b3f >}}

For UserVoice, you can get that by going to `https://{your_account}.uservoice.com/admin/settings/api`:

![UserVoice API keys](/images/postmedia/migrating-uservoice-github/api-keys.png)

If you are not using SSO-based authentication, you can safely skip `USERVOICE_SSO_KEY`.

Once you have the API keys, you can specify them in the string variables I showed above - `USERVOICE_API_KEY` and `USERVOICE_API_SECRET`. 

For GitHub, you can get a standard Personal Access Token (PAT) via the developer console - `https://github.com/settings/tokens`. Make sure that it has **repo-level** access to be able to create new issues.

![GitHub Personal Access Token configuration](/images/postmedia/migrating-uservoice-github/github-token.png)

Last but not least, `GITHUB_TARGET_REPO` should be set to the GitHub repo ID where the issues will be created. 

Now, we need to jump to some extra cleanup pre-processing - it so happens that some suggestions contain profanities, and I wanted to make sure that we avoid posting those on GitHub once we move the issues over. After a bit of research, I've stumbled across [this answer on Stack Overflow](https://stackoverflow.com/a/3533322) that showed how to implement a rudimentary filtering mechanism that works well enough for my scenario. 

That's how [`purifier.py`](https://github.com/dend/tools/blob/master/uservoice-to-github/purifier.py) came to life - we can import a new `ProfanitiesFilter` class:

{{< gist dend 9722dba265c1f49224b9e304e16c8b9b >}}

Now we can initialize both the UserVoice and GitHub clients, and start getting the list of suggestions that were posted:

{{< gist dend 778f7fd443222e2847a3781f15958328 >}}

When getting the list of suggestions, I thought I would get a mirror array that contains only ideas that are still open - that means nothing that's marked as **completed** or **declined**:

{{< gist dend 0ae2458fd1daf5a28a063d225149f344 >}}

Last but not least, once the ideas are ready - moving them over to GitHub is relatively easy with the help of `create_issue` - depending on the existing labels you have in your GitHub repo, you can map UserVoice statuses to new GitHub issue labels.

In addition, I've also added an attribution string that will be representative of _who_ originally opened the idea - that will be appended to the issue text:

{{< gist dend 5cbdb233ac6e169f3954146042ab4f19 >}}

And [there we have it](https://github.com/MicrosoftDocs/feedback/issues)!

![New GitHub issue migrated from UserVoice](/images/postmedia/migrating-uservoice-github/new-issue.png)

30 minutes of coding saving hours of manual work - just like automation was supposed to work!