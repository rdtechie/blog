---
title: Building a Notification Hub for Windows Phone with Azure
type: blog
date: 2013-11-03T07:44:51+00:00
---

For most applications, notifications are not exactly critical. Granted, a scientific calculator will not benefit from having an in-app notification hub. On the other hand, there are cases when you want to let the user know about what’s new and what changes before an update or including information in the changelog. That’s where a custom notification hub control can come in really handy.

## What goes into a notification?

Before jumping to actual coding, let’s think about what actually should go in a notification. We obviously want to display the information in the form of the simplest message possible. A title and a description should do it. But a notification also usually implies that there is some action tied to it, be it opening another application or a third-party location. So maybe including a URI would be another valid addition. All in all, we end up with this layout:

![Notification Class](/images/postmedia/building-a-notification-hub-for-windows-phone-on-top-of-windows-azure-mobile-services/image_thumb.png)

Fantastic. You can see that there are two extra properties that I haven’t mentioned – **Id** and **TimeStamp**. Since Azure Mobile Services are used, one of the core ways to determine the identity of an entity is by its unique integer identifier in the data table – **Id** takes care of holding the proper value. The **TimeStamp** property might not carry a unique value, but will tell the user when the notification was created. Ultimately, in the application itself it is possible to set filters to only show notifications from a given date range, but that’s a different topic.

In C# code, the class above will look like this:

```csharp
using Microsoft.WindowsAzure.MobileServices;
using System;

namespace Hilltop.CoreTools.Models
{
  [DataTable("notifications")]
  public class Notification
  {
    public int? Id { get; set; }
    public DateTime TimeStamp { get; set; }
    public string Title { get; set; }
    public string Content { get; set; }
    public string Url { get; set; }
  }
}
```

Notice the reference to **Microsoft.WindowsAzure.MobileServices** – make sure you install the <a href="http://www.windowsazure.com/en-us/develop/mobile/developer-tools/" target="_blank">Azure Mobile Services Windows Phone SDK</a> in order to be able to use it. I personally prefer using NuGet for this, so feel free to use this command to <a href="http://www.nuget.org/packages/WindowsAzure.MobileServices/" target="_blank">get the package</a>:

```
PM> Install-Package WindowsAzure.MobileServices
```

## The Core Control

Now that there is a defined notification model, I can start working on the core control itself. I’ll start by defining the skeleton via a **INotificationCenter** interface:

```csharp
using System.Threading.Tasks;

namespace Hilltop.CoreTools.Interfaces
{
  interface INotificationCenter
  {
    void Initialize();
    void GetCurrent();
    void Clear();

    Task CreateNotification(string title, string content, string url);
  }
}
```

**GetCurrent** will handle the acquisition of the current notification stack, **Clear** will erase all existing notifications and **CreateNotifications** will help the developer create notifications directly from the app.

> **SECURITY NOTE:** It is important to remember, however, that notification creation should probably be secured – the way the notification hub control works, it provides a unified “connector” to the service and it is up to the developer to have the proper separation of roles and capabilities available to different app user categories.

Without going into the boring details of <a href="http://www.codeproject.com/Articles/42203/How-to-Implement-a-DependencyProperty" target="_blank">dependency property registration</a>, here is what the ultimate class for the **NotificationCenter** control will look like:

![Notification Class](/images/postmedia/building-a-notification-hub-for-windows-phone-on-top-of-windows-azure-mobile-services/image_thumb1.png)

Notice that I have **MobileService** declared in the _Fields_ section. This is nothing else but the core managed Azure Mobile Services client. By default, it is null:

```csharp
public static MobileServiceClient MobileService = null;
```

We have an entire set of properties that determine the appearance of the notification entity in the global notification list. It is possible to set the icon associated with a given notification (usually taken from the context of the application itself but can be remote as well) as well as the colors for the content displayed.

Most important, however, is to have these two properties: **ZumoKey** and **ZumoUrl**. These will be used by the managed client to connect to the specific Azure Mobile Service instance and retrieve the data.

When the control is loaded in the visual tree, a call to **Initialize** (this is not the same as InitializeComponent) is made, that will try to connect to the service and retrieve any pending notifications:

```csharp
public void Initialize()
{
    if (!string.IsNullOrWhiteSpace(ZumoKey))
    {
        if (!string.IsNullOrWhiteSpace(ZumoUrl))
        {
            MobileService = new MobileServiceClient(ZumoUrl, ZumoKey);

            GetCurrent();
        }
        else
        {
            throw new InvalidOperationException("Missing ZUMO URL.");
        }
    }
    else
    {
        throw new InvalidOperationException("Missing ZUMO key.");
    }
}
```

When it comes to **GetCurrent**, it will simply populate the Notifications collection with the data returned by AMS:

```csharp
public async void GetCurrent()
{
    if (MobileService != null)
    {
        try
        {
            var data = await MobileService.GetTable().ToListAsync();
            Notifications = new ObservableCollection(data);
        }
        catch
        {
            // Failed to obtain the list of current notifications. 
        }
    }
}
```

Post-initialization, we want to let the user know that the control is ready, so I’ve added the **Ready** event handler. Here is how it will be invoked once the control has finished the first iteration of the loading routine:

```csharp
void NotificationCenter_Loaded(object sender, RoutedEventArgs e)
{
    Initialize();

    if (Ready != null)
    {
        Ready(this, new EventArgs());
        this.Loaded -= NotificationCenter_Loaded;
    }
}
```

Great. However chances are that at this point you don’t have any notifications available. **CreateNotification** would be exactly what you need:

```csharp
public async Task CreateNotification(string title, string content, string url)
{
    Notification notification = new Notification();
    notification.Content = content;
    notification.Title = title;
    notification.TimeStamp = DateTime.Now;
    notification.Url = url;

    if (MobileService != null)
    {
        try
        {
             await MobileService.GetTable().InsertAsync(notification);
             return true;
        }
        catch
        {
             return false;
        }
     }

     return false;
}
```

Thanks to the amazing work done by the <a href="http://www.windowsazure.com/en-us/develop/mobile/" target="_blank">Windows Azure Mobile Services team</a>, all you really need to do is create a new instance of the Notification model and push it to the aforementioned **MobileService** client.

As I also mentioned earlier, we’d want the notification to be interactive and actually point to some sort of a resource, that is represented with the help of the **Url** property. To do this, we handle the notification item selection in the list:

```csharp
private void NotificationSelected(object sender, SelectionChangedEventArgs e)
{
    if (e.AddedItems.Count > 0)
    {
        Notification notification = (Notification)e.AddedItems[0];

        WebBrowserTask task = new WebBrowserTask();
        task.Uri = new Uri(notification.Url);
        task.Show();
    }
}
```

The <a href="http://msdn.microsoft.com/en-us/library/windowsphone/develop/microsoft.phone.tasks.webbrowsertask(v=vs.105).aspx" target="_blank">WebBrowserTask</a> will use the built in browser (Internet Explorer) to open the associated page. Simple as that.

## What do I need to set up in the AMS dashboard?

Not a whole lot. First of all, make sure that you create a new table that has the same identifier as the DataTable attribute in the **Notification** class. In the example above, I am using _notifications_ as the name, and it is used like that in production with <a href="http://www.windowsphone.com/en-us/store/app/beem-plus/8433ad41-9a4e-46ff-ba33-340d265f53d5" target="_blank">Beem</a> and <a href="http://www.windowsphone.com/en-us/store/app/entrance/2613fe69-6167-40f8-91a0-d4c9ae1342c9" target="_blank">EnTrance</a>:

![Notification Class](/images/postmedia/building-a-notification-hub-for-windows-phone-on-top-of-windows-azure-mobile-services/image_thumb2.png)

During development, you might also want to enable <a href="http://msdn.microsoft.com/en-us/library/windowsazure/jj193175.aspx" target="_blank">Dynamic Schema</a>:

![Notification Class](/images/postmedia/building-a-notification-hub-for-windows-phone-on-top-of-windows-azure-mobile-services/image_thumb3.png)

> **SECURITY NOTE:** It is important to disable dynamic schema before your app goes in production.

## How do I use the control?

Use the standard XAML syntax in one of your pages:

```xml
<ht:NotificationCenter 
      NotificationIcon="/Images/notification.png" 
      ZumoUrl="YOUR_URL" 
      Ready="NotificationCenter_Ready" 
      ZumoKey="YOUR_KEY" 
      AbsentNotificationsColor="White">
</ht:NotificationCenter>
```

And there you go:

![Notification Class](/images/postmedia/building-a-notification-hub-for-windows-phone-on-top-of-windows-azure-mobile-services/wp_ss_20131103_0001.jpg)