---
title: Launching Windows Store Apps From Desktop
type: blog
date: 2012-11-28T15:16:00+00:00
---

As Windows 8 adoption is growing (as a matter of fact, in the first month [there were more than 40 million licenses sold][1]), so is the number of Windows Store applications. I use some of the Windows Store delivered applications, such as Music, Netflix, Bing Weather and Bing Search quite often, but I also spend a lot of time in Visual Studio, which means that I am not in the Windows 8 shell, but I have access to the taskbar. I was looking for a quick way to launch those applications from the desktop mode, and found an easy solution – URI associations. 

Some Windows Store applications come with custom URI associations, which means that the application can be launched from anywhere in the OS, given that there is a scheme-to-app association in the system. 

Registered application URI schemes are available in the Windows Registry. For example, here are some of them that are bound to stock apps: 

* **Bing Finance** – `bingfinance:`
* **Maps** – `bingmaps:` 
* **News** – `bingnews:` 
* **Search** – `bingsearch:` 
* **Sports** – `bingsports:` 
* **Travel** – `bingtravel:` 
* **Weather** – `bingweather:` 
* **Music** – `microsoftmusic:` 
* **Video** – `microsoftvideo:` 
* **Messages** – `mschat:` 
* **Calendar** – `wlcalendar:` 
* **People** – `wlpeople:` 
* **Games** – `xboxgames:`

All these associations are located in `HKEY\_CURRENT\_USER\Software\Microsoft\Windows\Shell\Associations\UrlAssociations`. Other applications can also register their own URI schemes, so the list might be quite long. 

Here comes the tricky part. If you just create a shortcut to, let’s say, **microsoftmusic:** (talking about a .lnk file), you will quickly realize that Internet Explorer will be intercepting the URI scheme association and will be asking you if you want to launch the application. 

What you could have, instead, is a PowerShell script, wrapped like this:

```bash
$Cmdy = new-object -comObject "Shell.Application"
$Cmdy.ShellExecute('microsoftmusic:')
```

Save this file anywhere. For this blog post, I named the file **Music.ps1**. If you worked with PowerShell before, you know by now that in order to execute a PS script, you need to right-click on the file and select **Open with PowerShell**. However, this process can once again be simplified. Create a new shortcut that executes the script, having the target pointing to the script: 

```bash
powershell.exe "C:\Users\Den\Desktop\Music.ps1"
```

By default, the security policy for PowerShell scripts is quite strict. To allow running scripts directly, open the PowerShell console as an administrator and run this command:

```bash
set-executionpolicy remotesigned
```

More details about the `set-executionpolicy` cmdlet can be found [here][2]. 

**SECURITY WARNING:** Before setting the script execution policy for your system, make sure you are aware of potential security implications, as this will remove the “no script” restriction on your Windows instance.

Once this is complete, you’ve got yourself a fully-functioning shortcut to a Windows Store application in desktop mode.

 [1]: http://thenextweb.com/microsoft/2012/11/27/microsoft-we-have-sold-40-million-windows-8-licenses-thus-far/
 [2]: http://technet.microsoft.com/en-us/library/ee176961.aspx