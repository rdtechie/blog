---
title: Release of Hummingbird – distribution list converter
type: blog
date: 2015-11-19T07:44:56+00:00
---


With the release of <a href="https://blogs.office.com/2015/09/22/introducing-availability-of-office-365-groups-in-outlook-2016/" target="_blank">Outlook Groups</a>, I got a lot of questions regarding the possibility of conversion of existing distribution groups to the new model. Instead of having users manually go through the process, I wrote a sample that demonstrates how it’s done with the help of <a href="https://msdn.microsoft.com/en-us/library/office/dd877012(v=exchg.150).aspx" target="_blank">EWS</a> and <a href="https://technet.microsoft.com/en-us/library/cc961766.aspx" target="_blank">Active Directory APIs</a>. So how do you set it up?

Clone the repository here: <a title="https://github.com/Microsoft/hummingbird" href="https://github.com/Microsoft/hummingbird">https://github.com/Microsoft/hummingbird</a>. You will get the project file with the associate source files. Open the project file (<em>Hummingbird.csproj</em>) and save the Visual Studio solution. Next, click on <em>Manage NuGet Packages…</em>

![Visual Studio](/images/postmedia//release-of-hummingbird-distribution-list-converter/image_thumb.png)

In the package manager, notice that there is an alert notifying you about the fact that you need to restore missing packages. Click on <strong>Restore</strong>.

![Visual Studio](/images/postmedia//release-of-hummingbird-distribution-list-converter/image21.png)

Once you have the packages restored, you can build the project and run the application:

![Hummingbird Landing Page](/images/postmedia//release-of-hummingbird-distribution-list-converter/image_thumb2.png)

From here on, you will be able to use the application directly with O365. Click on Settings to configure all application parameters:

![Hummingbird Settings](/images/postmedia//release-of-hummingbird-distribution-list-converter/image3.png)

For the username, use the standard O365 email address. The server URL for the main EWS endpoint is <a title="https://outlook.office365.com/EWS/Exchange.asmx" href="https://outlook.office365.com/EWS/Exchange.asmx">https://outlook.office365.com/EWS/Exchange.asmx</a> – make sure that you also select O365 as the target. Once you enter both the credentials and the server information, click on the respective <em>Save</em> buttons.

Moving forward, you will have everything required for migration. On the main page, you can enter the alias of the DL (skip the domain) and click on<em> Create Backup</em>. The output (as long as the alias is resolved) will be an <em>.xmldl</em> file that contains the original alias, DL owner and list of members. Hummingbird will not automatically delete the distribution list for you, so nothing to worry about. You can use this<em> .xmldl</em> file in the next step when you will create the group. If you want to preserve the alias, you will need to manually delete the DL first. Otherwise, the new group will be created with the new alias and a list of members from the original DL. Every member of the new group will receive a welcome email upon completion.

If you run into any issues, <a href="https://github.com/Microsoft/hummingbird/issues" target="_blank">open a new bug on GitHub</a>.