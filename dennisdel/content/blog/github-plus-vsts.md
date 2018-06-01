---
title: Connect GitHub and VSTS with Azure Functions
type: blog
date: 2018-05-28T07:06:02+00:00
slug: github-plus-vsts
images: ["https://dennisdel.com/images/postmedia/github-plus-vsts/header.png"]
news_keywords: [ "vsts", "github", "azure", "functions", "azurefunctions" ]
---

![Logo showing GitHub and VSTS](/images/postmedia/github-plus-vsts/header.png)

In our team (docs.microsoft.com - [we are hiring](https://aka.ms/awesomejobs)), we extensively use both GitHub and VSTS, for a variety of reasons. The problem of connecting the two came along as we were thinking about [our public feedback channel](https://aka.ms/sitefeedback). We ultimately want to have all user suggestions directed to the PM and engineering teams; however, internally all processes revolve around VSTS and engineering work is tracked there. The idea was to build a bot that can create VSTS work items from suggestions in GitHub.

If you've worked with GitHub before, you already know that the easiest way to accomplish that is by using [GitHub webhooks](https://developer.github.com/webhooks/), and whenever a suggestion is added to the issue tracker, we can parse it and log a new item in VSTS. There is a number of considerations that we need to take into account, such as whether the user who tries to log the suggestion has the permission to do so, and whether the received payload actually represents a suggestion request, but we'll get to those.

In our toolbelt, we will be relying on two key tools:

| Component | Description |
|:------|:------|
| **Azure Functions** | A [function](https://docs.microsoft.com/azure/azure-functions/index?WT.mc_id=dennisdel-blog) will be receiving GitHub messages and processing them. |
| **VSTS REST API** | Used to [create work items](https://docs.microsoft.com/rest/api/vsts/?view=vsts-rest-4.1&WT.mc_id=dennisdel-blog) in the internal system. | 

The blog post below covers a lot of the basics, so if you want to skip those and hop right into the code, just open the [GitHub repository that has everything in it](https://github.com/dend/github-vsts-bot), ready for deployment.

## Intro

Let's start by thinking about the tech stack that we're going to use - why should we use a function? A function is an event-driven compute-on-demand capability in Azure, that is designed to perform operations when certain events trigger them. In our case, the trigger is _a new issue submitted to the monitored GitHub repo_. It's an easy and cheap way to run code on-demand without the overhead of maintaining (and, well, paying for) a full-blown VM or service, especially given that our workload is relatively constrained and not long-running.

To get started, let's create a new [function app in the Azure Portal](https://docs.microsoft.com/azure/azure-functions/functions-create-first-azure-function?WT.mc_id=dennisdel-blog):

![Creating a new Azure Function app](/images/postmedia/github-plus-vsts/new-function.png)

Once the function app is provisioned, we can create a new function:

![Create a GitHub-based Azure function](/images/postmedia/github-plus-vsts/create-github-function.gif)

When an event occurs in the GitHub repo ([MicrosoftDocs/feedback](https://github.com/MicrosoftDocs/feedback)), the webhook payload will be delivered to the function, that will process it and determine the next set of actions. I am a big fan of C#, so I thought I would just use the [C# script (*.csx)](https://docs.microsoft.com/azure/azure-functions/functions-reference-csharp?WT.mc_id=dennisdel-blog) capabilities to write the function itself.

## Considerations

As we design the experience, we need to consider several things, that will later tie into the broader functionality set:

* **Trigger keywords.** A suggestion should be logged in VSTS only when a trigger keyword is included in one of the comments.
* **Mentions.** When a user is mentioned, we want to make sure that we can assign the suggestion to them.
* **Name resolution to AAD.** VSTS does not have the same identity model as GitHub, so we will need to have a way to resolve those and get the AAD identity.
* **Knowing item types.** Whenever new items are created in VSTS, we need to make sure that we know _what kind_ of items need to be created.

## Webhook Processor

Let's jump into code! The first thing we need to do inside the processor is [define a list of GitHub usernames](https://github.com/dend/github-vsts-bot/blob/master/src/DocsFeedbackProcessor/run.csx#L18) that are allowed to create new feedback:

```csharp
List<string> approvedUsers = new List<string>{"dend", "thedanfernandez", "powerhelmsman", "meganbradley"};
```

This is intentionally hardcoded for the purposes of the sample - you can, of course, delegate this to a configuration setting, or download the list dynamically. We also need to make sure that the processing is [only happening whenever a new comment is created](https://github.com/dend/github-vsts-bot/blob/master/src/DocsFeedbackProcessor/run.csx#L23), and not when other events are put in place:

```csharp
 log.Info("Received a payload.");

 // Process only if a new comment is created.
 if (payload.action != "created")
 {
     return;
 }
```

The `created` action type is returned to us via the GitHub webhook payload.

In addition to the above, we also need to [only process the trigger if the comment is not empty](https://github.com/dend/github-vsts-bot/blob/master/src/DocsFeedbackProcessor/run.csx#L28) and the user that created it is not the bot that handles suggestions - in our team, we have a designated GitHub user that is a service account. And, last but not least, we need to verify whether the posted comment contains the trigger keyword - `#log-suggestion`.

```csharp
if (payload.comment != null)
{
    // Don't process your own comments, and check against an approve-list of users who can create customer feedback.
    if (payload.comment.user.login.ToString().ToLower() != "botcrane" && approvedUsers.Contains(payload.comment.user.login.ToString().ToLower()))
    {
        if (!string.IsNullOrWhiteSpace(payload.comment.body.ToString().ToLower()) && !payload.comment.body.ToString().ToLower().Contains("#log-suggestion"))
        {
            return;
        }
...
```

Now, assuming that all conditions are met, we can start analyzing the payload. What I want to do first is get all tagged usernames. The easiest way to do that is with the help of regular expressions - every tagged ID starts with `@`. Because VSTS issues can only be assigned to one user, the convention used is that the first tagged user ID is the person we want to assign the VSTS item to:

```csharp
var operationalBody = payload.comment.body.ToString().ToLower();
string microsoftId = string.Empty;

var regex = new Regex(@"[\@].\S*");
var match = regex.Match(operationalBody);
if (match != null)
{
    log.Info("Found a tagged GitHub ID: " + match.Value.ToString());
    var cleanGitHubId = match.Value.ToString().Replace("@", "");
    log.Info("Clean ID: " + cleanGitHubId);
    microsoftId = await ResolveGitHubAliasToIdentity(cleanGitHubId, log);
    log.Info("Discovered Microsoft ID: " + microsoftId);
}
```

It's worth calling out, that the `ResolveGitHubIdentity` is something that [wraps around any organizational API](https://github.com/dend/github-vsts-bot/blob/master/src/DocsFeedbackProcessor/run.csx#L146) that keeps bindings between Azure Active Directory and GitHub identities - there is nothing out-of-the-box that does that for you today, so you might want to have some sort of a database that indexes those for you.

Once there is an AAD identity at hand, you can proceed to creating the VSTS item:

```csharp
log.Info("Task is executing further to create a VSTS item...");
string comment = "{ \"body\": \"Failed to submit internal item.\" }";
string label = "[ \"failed-logged-request\" ]";
try
{
    var vstsItemUrl = await CreateVstsCustomerSuggestion(payload.issue.title.ToString(), payload.issue.body.ToString(), payload.issue.html_url.ToString(), microsoftId, log);
    comment = "{ \"body\": \"🚀 **ATTENTION**: [Internal request](" + vstsItemUrl + ") logged.\" }";
    label = "[ \"logged-request\" ]";
}
catch (Exception ex)
{
    log.Info("Failed to insert issue.");
    log.Info(ex.Message);
}
```

A mock comment and label are created, with the default assumption that the request failed - because until it succeeds, it is in failed state. The comment JSON and label array will be used to talk back to the GitHub API to post a status update after a user requested the suggestion to be logged. When `CreateVstsCustomerSuggestion` is called, the original issue title, body and link are passed into the function, along with the resolved AAD identity. Inside the function is where the magic happens:

```csharp
public static async Task<string> CreateVstsCustomerSuggestion(string title, string description, string linkToIssue, string microsoftId, TraceWriter log)
{
    string url = "";
    string complexDescription = $"{description}<br/><br/>Original GitHub Issue: <a href='{linkToIssue}'>{linkToIssue}</a>";

    var jsonizedTitle = JsonConvert.ToString(title);
    var jsonizedDescription = JsonConvert.ToString(complexDescription);
    var jsonizedId = JsonConvert.ToString(microsoftId);

    string baseString = $@"[
        {{
            ""op"": ""add"",
            ""value"": {jsonizedTitle},
            ""from"": null,
            ""path"":""/fields/System.Title""
        }},
        {{
            ""op"": ""add"",
            ""value"": {jsonizedDescription},
            ""from"": null,
            ""path"":""/fields/System.Description""
        }},
        {{
            ""op"": ""add"",
            ""value"": {jsonizedId},
            ""from"": null,
            ""path"":""/fields/System.AssignedTo""
        }}
    ]";

    log.Info("Creating item...");
    using (var client = new HttpClient())
    {
        client.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue("Basic", Convert.ToBase64String(ASCIIEncoding.ASCII.GetBytes(":" + Environment.GetEnvironmentVariable("VSTS_CREDENTIALS"))));
        var content = new StringContent(baseString, Encoding.UTF8, "application/json-patch+json");
        var response = await client.PostAsync(url, content);
        string contents = await response.Content.ReadAsStringAsync();

        //log.Info(contents);

        var json = JsonConvert.DeserializeObject<dynamic>(contents);
        return json._links.html.href.ToString();
    }
}
```

There are a couple of things worth calling out here. All information related to the issue needs to be JSON-ified (in some cases, unescaped character will cause request failures), in preparation to be POST-ed to the VSTS API. We also need to construct the JSON string with all the information - and yes, I know, I can just serialize a class with all the required properties, but it's just easier to include the default JSON template and fill out the values, given the small size.

The fields that need to be filled out can be obtained via the [VSTS REST API](https://docs.microsoft.com/en-us/rest/api/vsts/wit/work%20item%20type%20categories/list?view=vsts-rest-4.1), for the entity type you want to log the suggestion as.

In the example above, `VSTS_CREDENTIALS` is an environment variable that holds a Personal Access Token with work item creation permissions in the VSTS instance you choose.

Depending on the success or failure of the VSTS API request, the bot will post a response in the issue thread, where the suggestion is being pulled from:

```csharp
if (payload.issue != null)
{
    log.Info($"{payload.issue.user.login} posted an issue #{payload.issue.number}:{payload.issue.title}");

    //Post a comment 
    await SendGitHubRequest(payload.issue.comments_url.ToString(), comment);

    //Add a label
    await SendGitHubRequest($"{payload.issue.url.ToString()}/labels", label);
}
```

`SendGitHubRequest` simply [executes API calls against the GitHub web endpoint](https://github.com/dend/github-vsts-bot/blob/master/src/DocsFeedbackProcessor/run.csx#L87):

```csharp
public static async Task SendGitHubRequest(string url, string requestBody)
{
    using (var client = new HttpClient())
    {
        client.DefaultRequestHeaders.UserAgent.Add(new ProductInfoHeaderValue("username", "version"));

        // Add the GITHUB_CREDENTIALS as an app setting, Value is the "PersonalAccessToken"
        // Please follow the link https://developer.github.com/v3/oauth/ to get more information on GitHub authentication 
        client.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue("token", Environment.GetEnvironmentVariable("GITHUB_CREDENTIALS"));
        var content = new StringContent(requestBody, Encoding.UTF8, "application/json");
        await client.PostAsync(url, content);
    }
}
```

And, here is what it looks like in action:

![Log a new suggestion](/images/postmedia/github-plus-vsts/log-suggestion.gif)

Simple yet efficient!

## Get Code

You can download the full code [here](https://github.com/dend/github-vsts-bot).