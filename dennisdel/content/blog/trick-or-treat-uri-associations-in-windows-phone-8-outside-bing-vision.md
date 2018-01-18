---
title: URI Associations In Windows Phone 8 Outside Bing Vision
type: blog
date: 2012-11-01T14:57:00+00:00
---

With the release of the new Windows Phone 8 SDK, the developers are now able to [create URI associations][1], where their application can be launched from the context of another application. For example, I can register a **den:** URI scheme to pass specific information to my application from any other installed application or resource, such as an email or a text message. That way, my application is no longer a standalone entity and it can interact easily with other applications in the Windows Phone ecosystem. 

There is one interesting aspect, however. Custom URI schemes are not recognized by [Bing Vision][2], which might be a problem if you generated a QR code that should launch your application. You will be able to launch http:// URLs, but custom applications will remain in their separate frame, out of reach of the stock app. 

Although this might seem like an issue, it can easily be mitigated by using standard HTML redirect. Since Bing Vision correctly handles URLs, and Internet Explorer on Windows Phone supports redirects, you have a couple of options, one of them suggested by Nikola Metulev. 

Have the user navigate to a URL that will redirect to the custom URI schema. Create a HTML page, that has the following source:

```html 
<HEAD>
  <META HTTP-EQUIV="refresh" CONTENT="1;URL=den:test" />
</HEAD>
```

What will happen here is when the user will navigate to this page from a Windows Phone, he will get redirected to the custom URI that was specified as the redirect target. It is not possible to enter custom URLs that do not follow the HTTP format in the Internet Explorer address bar, but you can still rely on content links and redirects. Of course, you could also use a third-party URL shortening web service that supports custom URI schemas, such as [is.gd][3]. You can shorten an URL and have a QR code automatically generated. That URL can be something like **den:awesome**, and from it you will obtain a valid HTTP URL that will then trigger the application launch.

 [1]: http://msdn.microsoft.com/en-us/library/windowsphone/develop/jj206987(v=vs.105).aspx
 [2]: http://www.engadget.com/2011/05/24/windows-phone-mango-and-bing-vision-hands-on/
 [3]: http://is.gd/