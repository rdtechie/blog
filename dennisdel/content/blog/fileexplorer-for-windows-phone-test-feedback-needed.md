---
title: FileExplorer for Windows Phone – Test Feedback Needed
type: blog
date: 2013-07-25T07:06:02+00:00
---

I’ve added several changes to the **FileExplorer** control, that will be included in the Coding4Fun Toolkit. 

Before actually becoming an active part of the control set, I want to make sure that it works as it should and where it should, and for that I am distributing it now as a part of an experimental package.

![Storage Control](/images/postmedia/fileexplorer-for-windows-phone-test-feedback-needed/2013072423.52.42.png)

Since the last update, there is a big change that was introduced – the ability to switch the selection type. Now it is possible to:

  * Select a single file
  * Select multiple files
  * Select a single folder
  * Select multiple folders

This option is given through the **SelectionMode** property.

![Control diagram](/images/postmedia/fileexplorer-for-windows-phone-test-feedback-needed/image.png)

When the control is dismissed, the **OnDismiss** event handler is called, the application will get two items in return – a **StorageTarget** reference, that will identify the location of the selected entity(ies), as well as an object than can either be a single <a href="http://msdn.microsoft.com/en-us/library/windows/apps/windows.storage.storagefile.aspx" target="_blank">StorageFile</a>, <a href="http://msdn.microsoft.com/en-us/library/windows/apps/windows.storage.storagefolder.aspx" target="_blank">StorageFolder</a>, <a href="http://msdn.microsoft.com/en-us/library/windowsphone/develop/microsoft.phone.storage.externalstoragefile(v=vs.105).aspx" target="_blank">ExternalStorageFile</a> or <a href="http://msdn.microsoft.com/en-us/library/windowsphone/develop/microsoft.phone.storage.externalstoragefolder(v=vs.105).aspx" target="_blank">ExternalStorageFolder</a>, or it could be a `List<T>` where `T` is one of the aforementioned storage objects. Explicit conversion will be required, depending on the scenario.

Download the sample project <a href="http://sdrv.ms/13GilEB" target="_blank"><strong>here</strong></a> or directly from the <a href="http://coding4fun.codeplex.com/SourceControl/latest#" target="_blank"><strong>CodePlex source control</strong></a> (latest checkin) and <a href="mailto:dend@outlook.com" target="_blank">send me your feedback</a>!

 [1]: http://www.dennisdel.com/wp-content/uploads/2013/07/2013072423.52.42.png
 [2]: http://www.dennisdel.com/wp-content/uploads/2013/07/image.png