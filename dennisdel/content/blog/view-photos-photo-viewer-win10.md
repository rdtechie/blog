---
title: 'Tip of The Day: View Photos with Windows Photo Viewer on Windows 10'
type: blog
date: 2017-01-08T20:36:39+00:00
---

With the release of Windows 10, all photos are now opened by default with the help of the [Photos app][1]. I like the Photos app, but I also enjoy the UI of the traditional Windows Photo Viewer.

To my surprise, I found out that Windows Photo Viewer is still part of the Windows bundle.

![Windows Explorer](/images/postmedia/view-photos-photo-viewer-win10/photoview.png)

What you will need to do is add the Windows Photo Viewer to the &#8220;_**Open With&#8230;**_&#8221; dialog. &#8220;But Den, there is no Photo Viewer EXE in the folder!&#8221; &#8211; valid point, dear reader.

![Windows Explorer](/images/postmedia/view-photos-photo-viewer-win10/photoview2.png)

It relies on specific system calls to be piped through the DLL itself, so you will have to run this PowerShell script (_**NOTE:**_ run it as Administrator):

```bash
New-PSDrive -Name HKEY_CLASSES_ROOT -PSProvider Registry -Root HKEY_CLASSES_ROOT | Out-Null
New-Item -Path $("HKEY_CLASSES_ROOT:\jpegfile\shell\open") -Force | Out-Null
New-Item -Path $("HKEY_CLASSES_ROOT:\jpegfile\shell\open\command") -Force | Out-Null
Set-ItemProperty -Path $("HKEY_CLASSES_ROOT:\jpegfile\shell\open") -Name "MuiVerb" -Type ExpandString -Value "@%ProgramFiles%\Windows Photo Viewer\PhotoViewer.dll,-3043"
Set-ItemProperty -Path $("HKEY_CLASSES_ROOT:\jpegfile\shell\open\command") -Name "(Default)" -Type ExpandString -Value "%SystemRoot%\System32\rundll32.exe `"%ProgramFiles%\Windows Photo Viewer\PhotoViewer.dll`", ImageView_Fullscreen %1"
```

Notice that I am using **jpegfile** as the file target. You can replace that with **pngfile** and **giffile** in case you want to expand the capability to other image formats.

Now, you can right-click on a picture, select &#8220;_**Open With&#8230;**_&#8221; and see Windows Photo Viewer in the list:

![Windows Explorer Picker](/images/postmedia/view-photos-photo-viewer-win10/photoview3.png)

 [1]: https://www.microsoft.com/en-us/store/p/microsoft-photos/9wzdncrfjbh4