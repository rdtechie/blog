---
title: Running Latest .NET Core on VSTS Hosted Build Agent
type: blog
date: 2016-07-07T07:25:43+00:00
---

Depending on your project, you might need to run the latest version of the [.NET Core SDK][1] on your hosted build agent. Hosted agents are pulled from the [VSTS hosted pool][2]. With great flexibility comes great responsibility, so the build agent has some limitations when it comes to picking the software that needs to be deployed.

Specifically, if you go over the existing constraints, you will notice that there are two that will prevent a simple silent install:

> Q: Does your build depend on software other than [this software][3] that is installed on hosted build resources?
> 
> A: No. Then you can use the hosted pool.
> 
> Q: Do any of the processes for your build need administrator privileges?
> 
> A: No. Then you can use the hosted pool.

So what do you do in this case? The great thing about the .NET Core SDK is the fact that you don&#8217;t really need to perform an install, but rather simply copy the files to the build agent and re-set the PATH environment variable to point to the newly deployed SDK.

> NOTE: The original .NET Core SDK is installed under C:\Program Files\dotnet. You will get an &#8220;Access Denied&#8221; error if you attempt to overwrite the contents.

The solution revolves around some PowerShell trickery. First, you need to create a new script that will download and extract the .NET Core SDK. In my case, I deployed this to my GitHub repo:

```csharp
[reflection.assembly]::LoadWithPartialName("System.Net.Http") | Out-Null
[reflection.assembly]::LoadWithPartialName("System.Threading") | Out-Null
[reflection.assembly]::LoadWithPartialName("System.IO.Compression.FileSystem") | Out-Null

$SourcePath = "https://dotnetcli.blob.core.windows.net/dotnet/Sdk/rel-1.0.0/dotnet-dev-win-x64.latest.zip";
$DestinationPath = "C:\dotnet"
$TempPath = [System.IO.Path]::GetTempFileName()

if (($SourcePath -as [System.URI]).AbsoluteURI -ne $null)
{
    $handler = New-Object System.Net.Http.HttpClientHandler
    $client = New-Object System.Net.Http.HttpClient($handler)
    $client.Timeout = New-Object System.TimeSpan(0, 30, 0)
    $cancelTokenSource = New-Object System.Threading.CancellationTokenSource
    $uri = New-Object -TypeName System.Uri $SourcePath
    $responseMsg = $client.GetAsync($uri, $cancelTokenSource.Token)
    $responseMsg.Wait()

    if (!$responseMsg.IsCanceled)
    {
        $response = $responseMsg.Result
        if ($response.IsSuccessStatusCode)
        {
            $fileMode = [System.IO.FileMode]::Create
            $fileAccess = [System.IO.FileAccess]::Write
            $downloadedFileStream = New-Object System.IO.FileStream $TempPath,$fileMode,$fileAccess
            $copyStreamOp = $response.Content.CopyToAsync($downloadedFileStream)
            $copyStreamOp.Wait()
            $downloadedFileStream.Close()

            if ($copyStreamOp.Exception -ne $null)
            {
                throw $copyStreamOp.Exception
            }
        }
    }
}
else
{
    throw "Cannot copy from $SourcePath"
}

[System.IO.Compression.ZipFile]::ExtractToDirectory($TempPath, $DestinationPath)
Remove-Item $TempPath
```

The URL for the 1.0.0 release is hard-coded in the script &#8211; I am downloading it and extracting locally. Remember that in a hosted agent, no files are persistent, so post-build those are deleted. You will need to re-download the package every single time you want to kick off a new build.

Once the package is deployed, you will need to simply run this snippet of PowerShell code:

```bash
dotnet --version; 
$path = Get-ChildItem Env:path; 
Write-Host $path.Value; 
$pathValue = $path.Value -Replace "C:\\Program Files\\dotnet","C:\dotnet"; 
Write-Host $pathValue; 
$env:Path = $pathValue; 
dotnet --version
```

What this snippet does is get the PATH from the current environment variables, swap it for the right location for the .NET Core SDK and then display it &#8211; for your convenience, I am also showing the _**dotnet**_ version before an after. You can reduce it to just the necessary parts.

After the execution, you will be able to trigger _**dotnet build**_ and _**dotnet run**_ (and other capabilities) with the latest version.

 [1]: https://docs.microsoft.com/en-us/dotnet/articles/core/sdk
 [2]: https://www.visualstudio.com/en-us/docs/build/agents/hosted-pool
 [3]: https://www.visualstudio.com/en-us/docs/build/agents/hosted-pool#software