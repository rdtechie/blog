---
title: Binding Dynamic Build Definitions to GitHub Repos
type: blog
date: 2016-11-04T07:48:16+00:00
---

As part of the project that I am working on, I need to make sure that I allow the user to specify what GitHub repository they want to bind to their Visual Studio Team Services build definitions. I am using the [As part of the project that I am working on, I need to make sure that I allow the user to specify what GitHub repository they want to bind to their Visual Studio Team Services build definitions. I am using the][1] library for that, but no matter what I tried, the repository just did not show up.
  
![VSTS Logo](/images/postmedia/binding-dynamic-build-definitions-github-repos/vsts.png)

For the process, I was using a typical [BuildHttpClient instance][2]. All seemed smooth, but I always ended up with a failed repository binding in the VSTS UI:

![VSTS Dependency Fail](/images/postmedia/binding-dynamic-build-definitions-github-repos/dependency-fail.png)

And while I got the red exclamation mark there, I got the correct repository binding in the build definition preview:

![Build Definition Preview](/images/postmedia/binding-dynamic-build-definitions-github-repos/repobing.png)

So what's the deal? You'd likely use a code snippet like this:

```csharp
BuildDefinition definition = new BuildDefinition();
definition.Name = configCarrier.Id.ToString();
definition.Project = new Microsoft.TeamFoundation.Core.WebApi.TeamProjectReference()
{
    Name = customParameters["project"],
    Id = new Guid(customParameters["projectId"])
};
definition.Repository = new BuildRepository()
{
    Id = $"{configCarrier.Repo.Url}.git",
    Type = "GitHub"
};

definition.Repository.Properties.Add("connectedServiceId", serviceEndpointId);
definition.Repository.Properties.Add("apiUrl", $"https://api.github.com/repos/{repoOwner}/{repoName}");
definition.Repository.Properties.Add("branchesUrl",
    $"https://api.github.com/repos/{repoOwner}/{repoName}/branches");
definition.Repository.Properties.Add("cloneUrl", $"https://github.com/{repoOwner}/{repoName}.git");
definition.Repository.Properties.Add("refsUrl",
    $"https://api.github.com/repos/{repoOwner}/{repoName}/git/refs");
```

Number one &#8211; **make sure to add the .git prefix** to the repository ID when you are creating a new BuildRepository. But that still won&#8217;t be enough. Take a look at the second part of the above code snippet:

```csharp
definition.Repository.Properties.Add("gitLfsSupport", "false");
definition.Repository.Properties.Add("fetchDepth","0");

definition.Repository.Name = $"{repoOwner}/{repoName}";
definition.Repository.Url = new Uri($"https://github.com/{repoOwner}/{repoName}.git");
definition.Repository.DefaultBranch = "master";
definition.Repository.Clean = "null";
definition.Repository.CheckoutSubmodules = true;
```

Notice that you need to specify values for **gitLfsSupport** and **fetchDepth**. Without those properties in place the binding will not happen, so be careful!

Once these tweaks were made, I could successfully bind my repository to the definition.

 [1]: https://www.nuget.org/packages/Microsoft.TeamFoundationServer.Client/
 [2]: http://stackoverflow.com/questions/32818766/how-to-get-scriptable-build-definitions-using-team-foundation-server-object-mode