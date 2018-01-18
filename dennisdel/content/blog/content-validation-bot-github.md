---
title: Creating a Content Validation Bot for GitHub
type: blog
date: 2016-06-07T00:09:10+00:00
---

As we released the [Visual F# documentation as open-source][1], one thing stood out as a challenge that needed to be tackled &#8211; content validation. There could be several things we could do, such as integrating extra validation rules in the build system or building a GitHub bot. I thought that as a learning experience, I will go the bot route. This post explains how I worked this problem.

First of all, you need to understand that a GitHub bot is nothing ore than a web app that reacts to certain things that happen in a GitHub repository. Those &#8220;happenings&#8221; are called web hooks, and GitHub provides [ample documentation on those][2].

Before I started working on building my own infrastructure, I started looking for an existing template &#8211; with a multitude of bots out there, surely someone already put together a framework for what I needed to do. And it so happens that a fellow Microsoft developer, [Felix Riesenberg][3], created [peer-review-bot][4].

**peer-review-bot** does most of the things that I wanted my bot to do. Once a pull request is created, it will post a message and tag the PR in a way that flags it for the team that it shouldn&#8217;t be merged yet. Unless the PR is tagged with an &#8220;exclusion tag&#8221;, that would determine that it&#8217;s exempt from requiring a review.

Great, so I have that &#8220;template&#8221; piece of code that I wanted. What&#8217;s next? Next, I created a separate GitHub repository where I put the existing source and configured it to use a new GitHub account &#8211; [orcabot][5]. Setting everything up in `config.js` is extremely easy.

![Config File](/images/postmedia/content-validation-bot-github/Screenshot-2016-06-06-16.20.04.png)

If you need more information on how to actually modify the configuration file, I recommend checking [Felix&#8217;s own guide][6].

Let&#8217;s say you have it all configured. Now what? It&#8217;s time to deploy it to Azure. Thankfully, Azure supports deployment directly from GitHub. The benefit of this continuous deployment approach is that with every check-in, Azure will automatically kick-off the build and notify you of any failures. It also gives you access to an easy deployment rollback mechanism. But that&#8217;s a conversation for another topic.

In the Azure Portal, I created a new Web App, and set the deployment source to be the repo where I hosted the peer-review-bot forked and modified code.

![Deployment Source](/images/postmedia/content-validation-bot-github/Screenshot-2016-06-06-16.24.38.png)

In addition to having the code, I now have the code ready to be leveraged. In its original version, it exposes two versions of a target &#8211; `/pullrequest` through `GET` and `/pullrequest` through `POST`. In the case of **orcabot**, I am mostly interested in the `POST` endpoint, that is triggered when something happens in a PR.

In GitHub, open your project settings and select the **Webhooks & services** segment and create a new webhook:

![Webhooks](/images/postmedia/content-validation-bot-github/Screenshot-2016-06-06-16.30.46.png)

The payload URL will vary depending on where your bot is hosted. If all goes well, you will see a new message appear in your PRs, as well as a custom tag:

![PR Post](/images/postmedia/content-validation-bot-github/Screenshot-2016-06-06-16.33.00.png)

It all works, but there are two ways I wanted to extend my bot:

* Currently it will mark the pull request as ready to merge if 2 approvers post a magic key combination &#8211; **LGTM** (or **Looks good to me**). What it doesn&#8217;t yet check is **who** posted that combination. This is not exactly dangerous if there is no auto-merge enabled on two green-lighted reviews, but when that is the case, you want to make sure that only approved developers or reviewers can sign off on the submission.
* Because the repository revolves around content, I wanted to automate content rule checks (e.g. all images must be within the repo, all images must have ALT text).

With the above in mind, I started small. To create a list of approvers, I bootstrapped an `APPROVERS.txt` file:

![Text Editor](/images/postmedia/content-validation-bot-github/Screenshot-2016-06-06-16.37.40.png)

It&#8217;s nothing more than a newline-separated text file that contains the GitHub IDs of those individuals who are cleared to sign-off on submissions.

In `config.js`, I am dynamically loading the file:

```js
var fs = require('fs');
var validatedApprovers = fs.readFileSync('../APPROVERS.txt').toString().split("\n");
```

When the instructional comment is being built, I am making sure that the listed approvers are notified about an inbound PR by separating the values from the array and pre-pending them with an `@`-sign:

```js
// Setup Instructions Comment
if (config.instructionsComment === '') {
    var comment = 'Hi! I\'m your friendly content validation bot. For this PR to be labeled as `ready-to-merge`, ' +
                  'you\'ll need at least ' + config.reviewsNeeded + ' comments from our designated community approvers containing the magic phrase `LGTM` ' +
                  '(`Looks good to me` also works, for those of us that are really verbose).\n\n';
    for(i in validatedApprovers)
    {
        comment += "@" + validatedApprovers[i].replace(/(?:\r\n|\r|\n)/g,' ');
    }
                  
    comment += " - please validate this PR."
    
    config.instructionsComment = comment;
}
```

Easy part is tackled, we now have approvers read and notified. But what about checking for validation only from the approved list?

In `src/bot.js`, I am performing the same read operation to get the list:

```js
var fs = require('fs');

var validApprovers = fs.readFileSync('../APPROVERS.txt').toString().split("\n");

// Remove the extra newline characters from list of approvers.
for (i in validApprovers) {
    validApprovers[i] = validApprovers[i].replace(/(?:\r\n|\r|\n)/g, '');
}
```

In the same `bot.js` file, there is a function called `checkForApprovalComments` &#8211; it will scan the list of comments for the pre-defined &#8220;magic&#8221; letter sequence. Within its logic to test whether the comment was already posted, I am adding an extra condition &#8211; ensure that the user that posted the comment actually counts for the purpose of content validation:

```js
for (var i = 0; i &lt; result.length; i++) { if (result[i].body && lgtm.test(result[i].body) && (validApprovers.indexOf(result[i].user.login.toLowerCase()) &gt; -1)) {
        // Test if we're actually just in the instructions comment
        isInstruction = (result[i].body.slice(1, 30).trim() === config.instructionsComment.slice(1, 30).trim());
        approvedCount = (isInstruction) ? approvedCount : approvedCount + 1;
    }
}
```

And that's it for checking the user!

Now, how about content rules? For that, I created a `rules.json` file that will contain RegEx lookup strings and messages that will be displayed once matches are found.

![Rules for validation](/images/postmedia/content-validation-bot-github/Screenshot-2016-06-06-16.57.28.png)

In `bot.js`, this file is loaded from the get-go:

```js
// Load existing validation rules.
var rules = require('./../rules.json');
```

A convenient helper function I built within the same file helps me go through the rules and match them against the existing content:

```js
function validateChanges(prNumber) {
    (function (pr) {
        // Get a list of files that are changed
        // within the PR.
        github.pullRequests.getFiles({
            user: config.user,
            repo: config.repo,
            number: prNumber
        }, function (error, result) {
            (function (prReference) {
                // We want the comment to be passed by reference,
                // so we wrap it within a JS object.
                var commentContainer = { comment: "" };
                
                if (!error) {
                    // Get the number of files changed, and
                    // add a reference to a counter object
                    // that will keep count of ongoing
                    // iterations.
                    var resultContainer = { count: result.length, validator: 0 };

                    for (i in result) {
                        var rawUrl = result[i].raw_url;

                        if (result[i] && rawUrl) {
                            var request = require('request');

                            (function (resultDoc, url, container, prComment) {
                                // Download the raw file that got changed in this PR.
                                request.get(rawUrl, function (error, response, body) {
                                    container.validator++;
                                    console.log(container.validator + "/" + container.count);

                                    if (!error && response.statusCode == 200) {
                                        // File downloaded just fine, let's get the body.
                                        var content = body;

                                        // Run the text content against the pre-defined rules.
                                        for (j in rules) {
                                            if (content.match(rules[j].lookup)) {
                                                console.log("Matched rule - " + rules[j].lookup);

                                                // Append a notification to the comment
                                                // that there is something off about the content.
                                                prComment.comment = prComment.comment.concat("* [**", resultDoc.filename, "**](", url, ") - ", rules[j].content, "\n");
                                            }
                                        }
                                    }
                                    
                                    // Post comment for rules that match.
                                    if (container.validator == container.count) {
                                        console.log("Trying to post comment: " + prComment.comment);
                                        postComment(prReference, prComment.comment, function (result) { console.log(result); });
                                    }
                                });
                            })(result[i], rawUrl, resultContainer, commentContainer);
                        }
                    }
                }
            })(pr);
        });
    })(prNumber);
}
```

Make sure to also include that function in the module exports:

![Export fragment](/images/postmedia/content-validation-bot-github/Screenshot-2016-06-06-17.00.52.png)

Once done, all you need to do is modify `route/pullrequest.js` to validate content on simple PR actions:

![pullrequest.js](/images/postmedia/content-validation-bot-github/Screenshot-2016-06-06-17.02.17.png)

We only need to perform checks on actual PR actions (e.g. sync, modify, open) and not secondary actions, such as comments.

And now [the bot works][7]!

![Bot working](/images/postmedia/content-validation-bot-github/Screenshot-2016-06-06-17.04.27.png)

It's not yet perfect - I am working on extending the validation logic and adding labels when there are content warnings, as well as improving its performance, so use the code above at your own risk.

 [1]: https://blogs.msdn.microsoft.com/dotnet/2016/05/17/releasing-f-language-documentation-as-open-source/
 [2]: https://developer.github.com/webhooks/
 [3]: http://www.felixrieseberg.com/
 [4]: https://github.com/felixrieseberg/peer-review-bot
 [5]: https://github.com/orcabot
 [6]: http://www.felixrieseberg.com/a-peer-review-bot-for-github/
 [7]: https://github.com/Microsoft/visualfsharpdocs/pull/159