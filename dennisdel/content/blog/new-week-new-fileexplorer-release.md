---
title: New Week – New FileExplorer Release
type: blog
date: 2013-07-02T02:25:45+00:00
---

To continue the tradition of a weekly FileExplorer build, here is the next update, bringing you the following capabilities and fixes:

## Show the path

You can actually see the current folder tree path in the control when navigating through. You can also select and copy the path (but not modify it at this point).

## Use file format restrictions

As you already know, when accessing the Windows Phone external storage (if any is present, of course), you are only limited to seeing the files that have been explicitly associated with your application. 

However, in a lot of cases you might want to restrict the visible file range even further. For those scenarios, the FileExplorer control now carries two new properties:

* **ExtensionRestrictions** – an enum value that can be one of the following: **None**, **InheritManifest**, **Custom**. When **None** is selected, you will see all files when working with the isolated storage, and only files that have registered file extensions in external storage. **InheritManifest**, on the other hand, might be handy if you want to select a file from the isolated storage and limit the picker to files that are “pre-approved” in the manifest – obviously, this setting is unnecessary when handling external storage, since the policy is enforced by the OS by default. Last but not least, Custom allows you to define a set of your own filters. And more about that below.

* **Extensions** – a generic collection that contains a set of extensions that you want to restrict the picker to. It is only used when the **ExtensionRestriction** property is set to **Custom**. You need to preserve all extensions in the **.[EXT]** format. So if, let’s say, I want to let the user pick only XPS files, I need to add a **.xps** entry to the collection. This property will not allow you to select files from external storage with extensions that have not been registered in the manifest.

As usual, you can download the [latest (79607) checkin][1] and go to **Experimental > FileExplorerExperimental** to see what this control is about.

I would love to hear your feedback and comments.

 [1]: http://coding4fun.codeplex.com/SourceControl/changeset/79607