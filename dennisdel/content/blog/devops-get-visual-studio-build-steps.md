---
title: Getting Build Steps with Visual Studio Team Services .NET API
type: blog
date: 2016-10-30T00:36:15+00:00
---
One of the features that I love the most about [Visual Studio Team Services][1] is the ability to build my code in the cloud. In my project I have a requirement for dynamic build provisioning, which works well. However, I recently tried to figure out how can I get the list of steps from a build definition, and was hitting a roadblock up until I got some help [from Chris Patterson][2].

I am using the .NET client libraries for accessing the Team Services capabilities (you can easily get the right packages [through NuGet][3]).

![.NET Libraries](/images/postmedia/devops-get-visual-studio-build-steps/sdk.png)

In my code, I was using the standard call to get the a list of definitions:

```csharp
var credentials = new VssBasicCredential(UserName, Token);
var buildClient = new BuildHttpClient(new Uri(Url), credentials);
var definitions = await buildClient.GetDefinitionsAsync(project: parameters["project"]);
```

However, for each definition I would only get a [BuildDefinitionReference][4] instance:

![Definition Reference Code](/images/postmedia/devops-get-visual-studio-build-steps/defreference.png)

So what&#8217;s missing here? Build steps. Of course, there is [the REST API][5] that you can leverage for this scenario, but in this case you&#8217;d have to write a custom implementation of the reader (parse out JSON, select the right node, and then transform raw JSON into a list of objects).

Luckily, the right functionality is already built into the SDK, and I wrote a simple helper method to do just what I needed in terms of getting the build steps:

```csharp
public async Task<IEnumerable> GetBuildDefinitionSteps(IDictionary<string, string> parameters)
{
    var buildClient = new BuildHttpClient(new Uri(Url), new VssBasicCredential(UserName, Token));
    var definition =
        await buildClient.GetDefinitionAsync(parameters["project"], Parse(parameters["definitionId"]));


    return definition.Steps.Select(step => new BuildStep {Name = step.DisplayName, Inputs = step.Inputs}).ToList();
}
```

As long as you have the definition ID (this is not the name, but rather the numeric identifier), you can successfully get a list of steps as now you will bet getting a real BuildDefinition instance that has the **Steps** property:

![Definition Reference Code](/images/postmedia/devops-get-visual-studio-build-steps/definition.png)

 [1]: https://www.visualstudio.com/team-services/
 [2]: https://twitter.com/chrisrpatterson
 [3]: https://www.nuget.org/packages/Microsoft.TeamFoundationServer.Client/
 [4]: https://www.visualstudio.com/en-us/docs/integrate/extensions/reference/client/api/tfs/build/contracts/builddefinitionreference
 [5]: https://www.visualstudio.com/en-us/docs/integrate/api/build/definitions#get-a-build-definition