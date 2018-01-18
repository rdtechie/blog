---
title: Building Docs for NuGet Packages with VSTS and GitHub Pages
type: blog
date: 2017-05-27T21:24:51+00:00
---

This is one of those questions that gets asked every week or so - I want to build documentation for my package the same way [docs.microsoft.com](https://docs.microsoft.com) does, but on my own server/cluster. While today we do not provide the entire infrastructure as a single open-source entity (but you can certainly [read up on what we do behind the scenes](https://dennisdel.com/blog/how-we-build-documentation-for-.net-based-sdks/)), I thought I would write a short guide on how you can document your own NuGet packages and then publish the documentation on GitHub pages.

## Intro

Let's start with the pre-requisites. You will need:

1. A [NuGet package](https://nuget.org). It's not even a requirement to have your own package - say, you want to document someone else's code - you can do that too.
2. A [Visual Studio Team Services](https://www.visualstudio.com/) account. You can create one absolutely free.
3. A [GitHub](https://github.com) account - just like with VSTS, you can create one at no cost.

Great, now you're ready. You've identified a NuGet package, and you want to have documentation for it. Start with identifying the package ID - it's easy to do so by going to the package page on NuGet.org. For the purposes of this exercise, we will take the most popular JSON parser library - [JSON.NET](https://www.nuget.org/packages/Newtonsoft.Json/):

![NuGet Package Landing Page](/images/postmedia/documentation-nuget-vsts-github/nugetorg-json.png)

The next step would be setting up the GitHub repository. You can just follow the steps outlined in the official [GitHub guide on the topic](https://pages.github.com/), as there is a number of special steps you need to do before you can publish to your site.

## Setting up VSTS

Once the GitHub repository is ready, let's set up the CI job that will produce the documentation. Open VSTS and navigate to your project **Build** view:

![VSTS Build Definition View](/images/postmedia/documentation-nuget-vsts-github/vsts-build-def.png)

Let's create a new build definition - you can start with a definition that has no steps, as what we will be doing is completely custom. The following steps need to be added:

### Download Nue (PowerShell Script)

This specific step will download a product called [Nue - NuGet Extractor](https://github.com/dend/nue). Every time a new release of Nue becomes available, it is placed in my Azure Storage blob, where it can then be re-used in other jobs.

![Download Nue](/images/postmedia/documentation-nuget-vsts-github/download-nue.png)

You can either link to an existing script, or simply copy-paste the following content inline:

```powershell
$url = "https://bindrop.blob.core.windows.net/tools/Nue/Nue/bin/NuePackage.zip"
$output = ($Env:BUILD_REPOSITORY_LOCALPATH + "\nue.zip")
$start_time = Get-Date

New-Item nue-out -type directory
New-Item nue-bin -type directory
New-Item mdoc-fw-output -Type Directory
New-Item mdoc-export -Type Directory

# Download NUE content
Invoke-WebRequest -Uri $url -OutFile $output
Write-Output "Time taken: $((Get-Date).Subtract($start_time).Seconds) second(s)"
```

There are some secondary tasks within this script, that help create container folders, that we will use for a bunch of other things described below.

### Creating & Updating a Package List

Now we need to tell Nue what packages we want to document. Given that it's something we determined earlier, we will need to create a new `packages.csv` file in our VSTS repo (handily, the source will be already cloned when the build job is initiated).

The CSV is nothing more than a combination of a moniker (short-hand package ID - you can create your own), the full NuGet package ID and the version that it requires. You can just use this:

```csv
jsonnet,Newtonsoft.Json,10.0.2
```

![Checkin Package CSV](/images/postmedia/documentation-nuget-vsts-github/checkin.png)

### Extract Nue.zip

Once the build system downloads the Nue archive, we need to extract it on the build agent. Again, VSTS comes to the rescue with a built-in step that allows you to extract the content. Make sure to extract the content to:

`$(Build.Repository.LocalPath)\nue-bin`

That will be the location from which we are referencing the binary later:

![Extract Nue](/images/postmedia/documentation-nuget-vsts-github/extract.png)

### Run Nue on Remote Packages

Time to work on setting up Nue package extraction. Create a new **Command Line** step and use the following parameters:

#### Tool

`$(Build.Repository.LocalPath)\nue-bin\Nue.exe`

#### Arguments

`-m extract -p $(Build.Repository.LocalPath)\packages.csv -o $(Build.Repository.LocalPath)\nue-out -f net46`

What this does is essentially calls Nue with a set of command line arguments that specify where to get the package list, where to place the extracted packages and what framework to extract packages for. Nue follows the standard [Target Framework Moniker (TFM)](https://docs.microsoft.com/en-us/nuget/schema/target-frameworks) convention that you might already be familiar with if you worked with NuGet packages.

### Download mdoc

You will also need to download [mdoc](https://github.com/mono/api-doc-tools) - an open-source tool that generates documentation from managed assemblies. You can do this with this simple script:

```powershell
$url = "https://github.com/mono/api-doc-tools/releases/download/preview-5.0.0.14/preview-mdoc-5.0.0.14.zip"
$output = ($Env:BUILD_REPOSITORY_LOCALPATH + "\mdoc.zip")
$start_time = Get-Date

New-Item mdoc-output -type directory
New-Item mdoc -type directory
New-Item mdoc-fw-out -Type Directory

Invoke-WebRequest -Uri $url -OutFile $output
Write-Output "Time taken: $((Get-Date).Subtract($start_time).Seconds) second(s)"
```

### Extract mdoc

Just like you did previously with Nue, we need to create another extraction step, and dump all mdoc files into `$(Build.Repository.LocalPath)\mdoc`:

![Extract mdoc](/images/postmedia/documentation-nuget-vsts-github/mdoc-extract.png)

### Running mdoc & Integrating /// comments

What you also need to know is that a lot of NuGet packages ship with built-in XML files, generated out of triple-slash comments. We don't want to lose that content as we generate online documentation, so we need to make sure that we do the proper imports.

Notice that the doc XML file is the same name as the assembly, and located in the same folder with it within the package:

![Doc XML file](/images/postmedia/documentation-nuget-vsts-github/xmlfile.png)

I put together a demo script that you can re-use:

```powershell
$exePath = ($Env:BUILD_REPOSITORY_LOCALPATH + "\mdoc\mdoc.exe")
Write-Output $exePath

$libraries = ($Env:BUILD_REPOSITORY_LOCALPATH + "\nue-out\jsonnet-10.0.2")
Write-Output $libraries

$outputFolder = ($Env:BUILD_REPOSITORY_LOCALPATH + "\mdoc-output")
Write-Output $outputFolder

$dependencyPath = ($Env:BUILD_REPOSITORY_LOCALPATH + "\nue-out\dependencies\jsonnet-10.0.2")

$dlls = Get-ChildItem -Path ($libraries + "\*") -Include *.dll
foreach($dll in $dlls)
{
    $reflectionTarget = [io.path]::GetFileNameWithoutExtension($dll.FullName)

    $docPath = ($libraries + "\" + $reflectionTarget + ".xml")
    $documentationXmlExists = Test-Path $docPath

    if ($documentationXmlExists)
    {
        Write-Output "Found XML documentation file!"
        Write-Output $dll.FullName
        & $exePath update -i $docPath -o ($outputFolder) -L ($dependencyPath) $dll.FullName --use-docid
    }
    else
    {
        Write-Output "There is no XML documentation file."
        Write-Output $dll.FullName
        & $exePath update -o ($outputFolder) -L ($dependencyPath) $dll.FullName --use-docid
    }
}
```

What this does, is it effectively goes to the folder where we extracted the package, finds all the dependencies and then executes `mdoc` on top of each and every assembly, with the content extracted from the /// doc files.

### Build Verification

If you followed the instructions correctly until now, it's about time we actually run the build job and see if everything is in order. To do that, simply save and queue the definition. You can run this inside a [hosted agent](https://www.visualstudio.com/en-us/docs/build/concepts/agents/hosted) with no issues.

![Doc Build](/images/postmedia/documentation-nuget-vsts-github/firstbuild.png)

Allegedly, the build went well. This is good, as at this point we can assume that the files generated were more or less in a state which `mdoc` deemed acceptable to process.

### Getting HTML out of XML

Almost there! We now need to convert `mdoc`-generated XML into HTML files. To do that, you will need to use a built-in `mdoc` command, called `mdoc export-html` (you can read more about it in the [official doc](http://docs.go-mono.com/?link=man%3amdoc-export-html(1))).

The command accepts two arguments: the output folder, defined by the `-o` argument, and the input folder that is the default argument. Create a new **Command Line** task and set the output folder to `$(Build.Repository.LocalPath)\mdoc-export` and the default argument to `mdoc-output`, like so:

![Command Line Export](/images/postmedia/documentation-nuget-vsts-github/cmd.png)

### Checking Exported Docs Into Your Repository

Last but not least, we will need to check-in the exported files into your repository. From the start, we did not clone a GitHub repository, so something we will need to fix now. Create a new **PowerShell Script** step, and use the following inline:

```powershell
git clone https://{your_username}:{your_token}@github.com/{your_username}/{your_repo_name}.git --branch=master {your_folder}

$from = "$(Build.Repository.LocalPath)\mdoc-export\*"
$to = "$(Build.Repository.LocalPath)\{your_folder}"  
Copy-Item $from $to -recurse

cd {your_folder}
git add *
git commit -m "Update."
git push
```

Notice that I am using a GitHub auth token - you can generate one by following the [official documentation](https://help.github.com/articles/creating-a-personal-access-token-for-the-command-line/). A good idea for production systems would be to store the token as a secure build variable rather than including it in the inline script directly - the code above is for demo purposes only.

And that's it! Re-run the build, and once you go to your `*.github.io` site, you will see the documentation there!

 ![Hosted Documentation](/images/postmedia/documentation-nuget-vsts-github/hosteddoc.png)

 You can automate this job even further, by tracking when new NuGet package versions are released, and kicking-off a documentation build at the time. But that's a topic for another blog post.
