---
title: Testing the Future
type: blog
date: 2013-06-26T01:07:43+00:00
---

…control that will be integrated in the <a href="http://coding4fun.codeplex.com/" target="_blank">Coding4Fun Toolkit</a> &#8211; **FileExplorer**!

You can download the Coding4Fun Toolkit source code <a href="http://coding4fun.codeplex.com/SourceControl/latest" target="_blank">here</a>. Once downloaded, go to **Experimental > FileExplorer**. The sample project carries an alpha implementation of the control, and I would love to <a href="mailto:dend@outlook.com" target="_blank">get your feedback on it</a> &#8211; let me know what you want to see become a part of it.

**NOTE:** This custom control currently works only on Windows Phone 8.

The control will play the role of the standard <a href="http://code.msdn.microsoft.com/windowsapps/File-picker-sample-9f294cba" target="_blank">Windows 8 FilePicker</a>, but on Windows Phone. Its goal is to allow developers to provide an easy-to-use interface to interact with the isolated storage, as well as with the external storage in the context of native phone applications.

## What can the control do at this point?

* Pick a file from the isolated storage (no file format restrictions)
* Pick a file from the external storage, if such is available (restricted to files that have an extension registered with the app)
* Navigate through the folder tree in both the isolated storage and external storage (where available)

In its current implementation, I am using the control as a way to **open files for** **read**. No built-in functionality is introduced to facilitate writing at this point.

## What do I have planned for the control?

* File extension filter for files in the isolated storage (this can be both manifest-based and individual)
* Multi-file select (return a batch of files from one or different locations)
* Folder select
* Windows Phone 7.x support for isolated storage

## Important disclaimer

The control is in its **<u>alpha stage</u>**. DO NOT use it in production. 

 [1]: http://www.dennisdel.com/wp-content/uploads/2013/06/wp_ss_20130625_0001.png