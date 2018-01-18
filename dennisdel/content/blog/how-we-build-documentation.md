---
title: How We Build Documentation for .NET-based SDKs
type: blog
date: 2017-04-14T03:11:25+00:00
---
If you are following the news around our [new technical documentation experience][1], you probably know that last week we revamped our managed reference experience and [launched the .NET API Browser][2]. In today&#8217;s post, I thought I would go into the nitty-gritty of the process and talk about how exactly we generate reference documentation for .NET Framework and related managed SDKs.

As a starting point, it&#8217;s worth clearly defining what we see as &#8220;managed reference&#8221;. This is an umbrella term that describes all API documentation that relates to SDKs or toolkits built on top of the .NET platform. In abstract terms, we document official SDKs that ship [ECMA 335 assemblies][3] (aka managed DLLs).

Typically, we would use [vanilla DocFX][4] as the primary ingestion & publishing engine &#8211; simply connect a GitHub repository, pull the source, and voila &#8211; you have yourself the documentation you can work with. At our scale, however, we&#8217;ve encountered several roadblocks, specifically around the following areas:

  * **Versioning** &#8211; it&#8217;s much easier to maintain a clear separation of versions when you have a set of binaries vs. source code commits.
  * **Multi-framework support** &#8211; Microsoft ships .NET Framework, .NET Core, .NET Standard, Xamarin, etc. &#8211; there is a lot of overlap in terms of content that needs to be documented, and writing de-duping automation post-build.
  * **Reliability** &#8211; source is always in flow, and as changes happen and are rolled back, the same will apply to documentation. Especially for pre-release software, you don&#8217;t want an accidental commit to result in a doc that goes out to the public. Constraining to a set of ready-to-go binaries means only &#8220;approved&#8221; SDKs get documented.

Let&#8217;s now talk architecture. We chose to standardize on the [ECMA XML format][5], the result of the fantastic work [on the Xamarin team][6]. Not only this format gives us enough flexibility in terms of documenting pretty much everything there is to document inside managed DLLs, but its tooling was specifically designed to support the 3 core scenarios that I mentioned above. At the core of the process stays [mdoc][7], a tool that can generate ECMA XML from a set of assemblies that we pass to it.

More than that, [Joel Martinez][8] worked hard to add multi-framework support, so that we don&#8217;t treat separate sets of DLLs as their own little world, but rather a part of the same common core. But I digress. Here is how we roll:

## Step 1: Get all the necessary assemblies

We work with individual teams to get access to the final compiled assemblies that they release to the public. An ingestion service effectively accesses different shares and NuGet packages to copy the DLLs in a centralized location that our team manages. Yes, I said NuGet too &#8211; there is [this tool][9] that allows extraction of assemblies from a set of NuGet packages and puts them in the right places.

Within the centralized location, we organize individual SDKs and their versions by &#8220;monikers&#8221; &#8211; a short name that describes a shippable unit. For example, the moniker for **.NET Framework 4.7** is **netframework-4.7**. This is the same short name that you see in the **?view=** parameter on <https://docs.microsoft.com/dotnet/api>.

The ingestion agent does a hash-compare to see if there are changes to binaries before checking them into their final destination.

## Step 2: Trigger a documentation pass

Now that we have all the DLLs in place, the build agent picks up the baton as it&#8217;s now time to generate ECMA XML. Because we organized DLLs by monikers, we can use the [mdoc frameworks mode][10] to bulk-reflect assemblies. In frameworks mode, mdoc aggregates namespace, type and member information in independent `FrameworksIndex/{moniker}.xml` files that enumerate everything that is available within a certain &#8220;moniker&#8221; or &#8220;framework&#8221; &#8211; remember when I mentioned that monikers are **shippable units**?

The contents of the aforementioned `{moniker}.xml` file might look something [like this][11]:

![Moniker](/images/postmedia/how-we-build-documentation/moniker.png)

The rest of the XML files are pretty boring &#8211; they contain all type information, parameters, information on purpose of APIs &#8211; your typical documentation stuff. What&#8217;s interesting is that none of those files contain any framework metadata, so if, for example, you are documenting the System namespace, it will be one **System.xml** that will contain everything for all .NET Framework, .NET Core, .NET Standard and Xamarin. It&#8217;s the **{moniker}.xml** that will determine what from that namespace actually belongs to the framework.

In some special cases, developers also ship documentation files &#8211; those XML files that the Roslyn/mono compilers output based on triple-slash comments inside your code (because remember &#8211; the comments are not preserved in binaries). Depending on the team, some developers want to not lose the /// documentation, and since we can&#8217;t get it from binaries, we have a special build step in place that uses the same **mdoc** tooling to convert doc XML to ECMA XML, and then perform another pass in frameworks mode and do the diff check to make sure no type information was lost.

## Step 3: Check in the XML files

Once the files are generated, we check them into the content repository. If you are a frequent visitor of the [dotnet/docs][12] repo, you might&#8217;ve noticed the addition of an [xml folder][13]. That&#8217;s where the build artifacts are actually published.

Our technical writers and community contributors can go into the repo where the XML files are checked in and add any additional content they want, such as remarks, examples, schemes, diagrams, etc.

## Step 4: Prepare & publish

What many of you might not know is that regardless of what format the files come into the publishing pipeline, they always come out as [YAML][14]. As you can imagine, we support documenting many things, like [Azure CLI][15], [.NET in form of Markdown articles][16], [Java SDK documentation][17], etc. We can&#8217;t just shoehorn everything into ECMA XML, as it was not designed for anything beyond .NET.

On the other hand, the publishing pipeline needs to understand standard markup across the board, hence &#8211; YAML for everything. There is a number of processors in place that convert all inputs to a YAML output.

The same happens for ECMA XML &#8211; a YAML processor generates the necessary YAML and checks that output in its final, publishing, destination, along with many other .NET reference pieces. From there on, it gets converted to HTML, hosted and rendered on [docs.microsoft.com][1].

Here is a fun fact for you &#8211; we actually do support Markdown inside ECMA XML! Yes, you can do that via a custom **format** element:

```xml
<format type="text/markdown">![CDATA[
## Your Markdown Here
]</format>
```

This is only allowed inside certain regions of the XML file (more details in the next installment) but our processor will interpret that in a different way than the rest of the XML. So if you, the end-user, are not familiar with the XML format, you can still leverage Markdown inside ECMA XML with no functionality loss.

## What&#8217;s next?

Even more automation. There are quite a few steps in the process that require manual intervention, and our main goal here is to automate even the smaller details.

## Questions?

Don&#8217;t hesitate to reach out [via Twitter][18] or [any other means][19] you find and I would be more than happy to answer your questions.

 [1]: https://docs.microsoft.com
 [2]: https://docs.microsoft.com/en-us/teamblog/announcing-unified-dotnet-experience-on-docs
 [3]: https://www.ecma-international.org/publications/standards/Ecma-335.htm
 [4]: http://dotnet.github.io/docfx/
 [5]: http://docs.go-mono.com/?link=man%3amdoc(5)
 [6]: https://www.xamarin.com/
 [7]: https://github.com/mono/api-doc-tools
 [8]: https://twitter.com/JoelMartinez
 [9]: https://github.com/dend/nue
 [10]: https://github.com/mono/api-doc-tools/releases/tag/preview-5.0.0.5
 [11]: https://github.com/dotnet/docs/blob/master/xml/FrameworksIndex/netframework-4.7.xml
 [12]: https://github.com/dotnet/docs
 [13]: https://github.com/dotnet/docs/tree/master/xml
 [14]: https://en.wikipedia.org/wiki/YAML
 [15]: https://docs.microsoft.com/en-us/cli/azure/
 [16]: https://docs.microsoft.com/en-us/dotnet/articles/framework/development-guide
 [17]: https://docs.microsoft.com/en-us/java/api/com.microsoft.applicationinsights.extensibility.initializer
 [18]: https://twitter.com/DennisCode
 [19]: https://www.dennisdel.com/about/