---
title: 'Non-Store Windows Phone Apps: Integrate With the Settings Hub'
type: blog
date: 2014-03-16T23:04:41+00:00
---

Let’s say you are developing an application that needs to integrate in the Settings Hub. For most applications, this is not at all necessary – if you are not altering the behavior of the device (e.g. through global settings that go beyond the application), you do not need to do this. However, for experimentation purposes, it is, in fact, possible to integrate your app in there.

> **NOTE:** I’ve already talked about this in my <a href="http://stackoverflow.com/a/19592283/303696" target="_blank">StackOverflow answer</a>, but putting together this blog post for documentation purposes.

First step, create a new Windows Phone application. There is no difference in the type of the application that you are creating, but since this is a simple demo, I am going to go ahead and create a blank app:

![Visual Studio Dialog](/images/postmedia/non-store-windows-phone-apps-integrate-with-the-settings-hub/image_thumb1.png)

Without making any changes to the app, run it on a device or the emulator. Notice that by default, the application is listed along with all other applications, so nothing out of the ordinary at this point.

![Windows Phone screenshot](/images/postmedia/non-store-windows-phone-apps-integrate-with-the-settings-hub/wp_ss_20140316_0002.png)

If you are already working with Windows Phone, you should know that the application placement in terms of launch location is determined in the application manifest file (_WMAppManifest.xml_). By default, and if you are using the latest Visual Studio + Windows Phone SDK couple, you will get the ‘visual designer’ for the manifest.

![Visual Studio settings](/images/postmedia/non-store-windows-phone-apps-integrate-with-the-settings-hub/image_thumb2.png)

Not exactly what’s needed for the purpose of this post, because we don’t have a way to modify the target launch ‘hub’. Instead, right-click on the manifest file in Solution Explorer and select View Code:

![View Code](/images/postmedia/non-store-windows-phone-apps-integrate-with-the-settings-hub/image_thumb3.png)

What I need here is a HubType attribute, that is not listed by default:

![App settings](/images/postmedia/non-store-windows-phone-apps-integrate-with-the-settings-hub/image_thumb4.png)

So just adding it in there, with the target value of **268435456** will do the trick. However, be aware that since you already deployed the application as a ‘normal app’ (belonging to the standard launch hub), you need to make sure that you uninstall the app first, and then re-deploy it, for it to appear in the Settings hub. Notice the change:

![App settings](/images/postmedia/non-store-windows-phone-apps-integrate-with-the-settings-hub/wp_ss_20140316_0003.png)

There is no simple way to uninstall the app from the Settings Hub, however, because there is no ‘tap-and-hold’ way to pick the ‘Uninstall’ option. The way to do it would be to re-deploy another app, with the same **ProductID** (from _WMAppManifest.xml_). Even if you use the same application with HubType removed, you will need to create a different one to replace it.

 [1]: http://www.dennisdel.com/wp-content/uploads/2014/03/image1.png
 [2]: http://www.dennisdel.com/wp-content/uploads/2014/03/wp_ss_20140316_0002.png
 [3]: http://www.dennisdel.com/wp-content/uploads/2014/03/image2.png
 [4]: http://www.dennisdel.com/wp-content/uploads/2014/03/image3.png
 [5]: http://www.dennisdel.com/wp-content/uploads/2014/03/image4.png
 [6]: http://www.dennisdel.com/wp-content/uploads/2014/03/wp_ss_20140316_0003.png