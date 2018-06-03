---
title: Summer of Docs - Documenting .NET Libraries
type: blog
date: 2018-06-01T04:43:54+00:00
slug: summer-of-docs-net
mages: ["https://dennisdel.com/images/postmedia/summer-of-docs-net/city.jpg"]
news_keywords: [ "docs", "summer", "docfx", "documentation", "net", "dotnet" ]
---

Summer is here, the city finally feels like you can take pictures of it from above without being "head in the clouds", and that also means that it's time to document how we generate .NET documentation on [docs.microsoft.com](https://docs.microsoft.com).

![View of Vancouver from above](/images/postmedia/summer-of-docs-net/city.jpg)

A while ago I wrote a post about [documenting NuGet packages](https://dennisdel.com/blog/building-docs-for-nuget-packages-with-vsts-and-github-pages/), and while it was a generally good description of high-level tools, it also missed the key detail - how to [use DocFX](https://dotnet.github.io/docfx/) to render the docs. 

More than that, I want to show how to do that on a platform other than Windows; all instructions in this article can be followed on a Mac (and if you have some time on your hands, Linux) with the exception of YAML generation, because it's currently [blocked by a bug](https://github.com/docascode/ECMA2Yaml/issues/8) with the ECMA2YAML extension.

## Getting and Configuring DocFX

First thing you need to do is [download and install DocFX](https://github.com/dotnet/docfx/releases). Once the download completes, make sure to extract it in a folder of your choice.

Next, you need to install Mono. On a Mac, you can just use Homebrew (`brew install mono`) or download it [directly from the Mono website](https://www.mono-project.com/download/stable/).

Once done, you can navigate to a folder where you want to initialize your documentation, and run:

```bash
mono --arch=32 $HOME/Downloads/docfxtest/docfx.exe init
```

Obviously, the path can be different, depeneding on where you downloaded DocFX. This will create the skeleton for the documentation. 

![Initializing documentation](/images/postmedia/summer-of-docs-net/docfxinit.gif)

## Generating Compatible Documentation

Next, we need to make sure that we get the [`ECMA2YAML` extension](https://www.nuget.org/packages/Microsoft.DocAsCode.ECMA2Yaml/). On our team, we rely on documentation for .NET assemblies that is generated with the help of [`mdoc`](https://github.com/mono/api-doc-tools) - an open-source documentation generation tool that creates ECMAXML from assemblies and their Roslyn-generated XML documentation files. By default, DocFX cannot read in ECMAXML files, so we need the extension.

The easy way to operate with `ECMA2YAML` on is to download the extension locally (thanks [NuGet.org](https://nuget.org) for having that functionality), extracting it and using the `/tools/ECMA2Yaml.exe` binary to translate ECMAXML to DocFX-ready YAML. Refer to [my previous article](https://dennisdel.com/blog/building-docs-for-nuget-packages-with-vsts-and-github-pages/) if you need to know how to run `mdoc` and generate ECMAXML docs.

You can use two parameters - `-s`, to specify where the XML files are coming from, and `-o` for the target folder where you will place the output.

![Generating YAML documentation](/images/postmedia/summer-of-docs-net/generate-yaml.gif)

When the files are generated, make sure to copy the YAML files wherever you originally triggered `docfx init`, in the `api` folder. It's OK to replace the existing `TOC.yml` as it's there just for placeholder purposes.

Once the build completes, run:

```
mono --arch=32 $HOME/Downloads/docfxtest/docfx.exe server _site
```

This will provision a new web server running locally on port 8080:

![Rendering documentation](/images/postmedia/summer-of-docs-net/docfx-run.gif)

## Room for Improvement

Of course, the process here is somewhat manual and if you are running a Windows VM, you can already automate this, similar to what we are doing on [docs.microsoft.com](https://docs.microsoft.com). Once ECMA2YAML is fixed to account for *nix paths, we will be able to put this within an agent that runs across all platforms that can run `mono`. In some of the next installments of the _Summer of Docs_ I will talk about how we can Docker-ize the process and make it more extensible.