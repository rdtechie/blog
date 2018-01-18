---
title: Adding SkyDrive Upload Support to Your Windows Phone App
type: blog
date: 2012-11-18T15:03:00+00:00
---

Multiple applications that are already in the Windows Phone Marketplace operate with a variety of content, such as pictures, text files and music. More often than not, that content is stored locally, in the application isolated storage, and although it is a good way to preserve that content, this method is bound to create some inconveniences in case the user decides to switch phones or do a complete device reset. To avoid this, developers can leverage the [Microsoft Live SDK][1], specifically the [SkyDrive API][2] that is exposed through it. 

To make my case more realistic, I am going to bring up my Windows Phone project – Beem (you can find the free version [here][3] and the donation build [here][4]). As I am expanding the functionality base for the Beem Plus client, I decided that I need to do something to allow users to back up the stream recordings that they have. Those are MP3 files stored internally, captured directly from the incoming radio stream. 

The interesting part about these recordings is the fact that their length varies. One user might record a 10 second track, another one might have hours of online podcasts. Therefore, it would be logical to let them backup that data, in case something goes wrong. The Microsoft Live SDK comes with out-of-the box support for Windows Phone, so once you download and install the SDK, all you need to do is add a **Microsoft.Live** and **Microsoft.Live.Controls** assemblies to the project. Those should be already present in Visual Studio, in the **Extensions** section in the **References** dialog. 

It is important to mention that before, it was not possible to upload MP3 files to SkyDrive from third-party applications. [My workaround][5] to that was simply adding a .wav at the end of the uploaded file name. An extension mismatch would not cause any problems during playback on a Windows machine, and if necessary, it can easily be swapped manually. Since then, the restriction has been lifted and SkyDrive supports MP3 uploads. 

You will integrate the Microsoft Account authentication in your application by adding a [SignInButton][6] control, also specifying the [scope of your integration][7] with the user account. This is a built in measure that prevents applications from abusing the system by notifying the user about the actions the application will be able to perform on the account. 

##### Basic Setup

**SignInButton** is added in the XAML layer, and a sample snippet would look like this: 

```xml
<live:signinbutton 
    x:name="btnSignIn" 
    clientid="CLIENT_ID_HERE" 
    scopes="wl.signin wl.basic wl.offline_access wl.skydrive wl.skydrive_update" 
    branding="Skydrive" 
    texttype="Connect" 
    visibility="Collapsed">
</live:signinbutton>
```

First things first, take a look at the declared scopes. The application will be able to sign the user in (**wl.signin**), access the basic profile information (**wl.basic**), access the user account when the user is not necessarily online, allowing me to preserve the login information so that there is no repetitive login once the app successfully performed the authentication (**wl.offline_access**), access the basic SkyDrive metadata (**wl.skydrive**) and update the file layout in the SkyDrive storage (**wl.skydrive_update**). 

The **ClientID** identifies your application and can be obtained [here][8]. **Branding** and **TextType** determine the appearance of your button, allowing you to customize the displayed logo and caption. 

When the user clicks on the button for the first time, he will be prompted with a web authentication page, where he will be asked to enter his Microsoft Account credentials. Once the account passes the verification, the user will be prompted with another web page, that shows the permissions the application requests. It is important that you declare only the necessary permissions when declaring the scopes. 

Once Yes is clicked in the dialog, the session information will be automatically stored in the application if necessary, so you don’t have to worry about manually preserving those. Every time the authentication engine is invoked, the SessionChanged event handler is invoked, so make sure you hook it to the button:

```csharp
btnSignIn.SessionChanged += App.MicrosoftAccount_SessionChanged;
```

As a result, you can potentially obtain a LiveConnectSession, that will be consequently used to perform any request on the Microsoft service endpoints. However, you also need to make sure that that account was actually successfully connected, since the user can block the application. 

```csharp
public static void MicrosoftAccount_SessionChanged(object sender, Microsoft.Live.Controls.LiveConnectSessionChangedEventArgs e)
{
    if (e.Status == Microsoft.Live.LiveConnectSessionStatus.Connected)
    {
        MicrosoftAccountClient = new LiveConnectClient(e.Session);
        MicrosoftAccountSession = e.Session;
        MicrosoftAccountClient.GetCompleted += client_GetCompleted;
        MicrosoftAccountClient.GetAsync("me", null);
    }
    else
    {
        Binder.Instance.MicrosoftAccountImage = "/Images/stock_user.png";
        Binder.Instance.MicrosoftAccountName = "no Microsoft Account connected";
        MicrosoftAccountClient = null;
    }
}
```

The call to **me/picture** will return the URL for the profile picture for the currently authenticated user. Notice that I am getting the results by referencing the key names. When the raw JSON data is returned on a call, a dictionary is automatically created that contains the key-value pairs, that makes it easier to get the data without having to re-parse the data. The **RawResult** property still exposes the raw JSON. 

##### Uploading the File

Once a file is already present in the isolated storage and the Microsoft Account is connected to the application, it is extremely easy to initiate the uploading process. Before doing that, however, you need to consider that every user has limited SkyDrive quota. The default amount of allocated storage for current users is 7GB, so make sure that you check whether there is any available space for the file that you are about to send. To do this, you need to perform a call to **me/skydrive/quota**.

```csharp
client = new Microsoft.Live.LiveConnectClient(App.MicrosoftAccountSession);
client.GetCompleted += client_GetCompleted;
client.GetAsync("me/skydrive/quota", null);
```

This call will return two values – total quota and available space. Before the upload, compare the byte size of the file and the available space.

```csharp
if (e.Result.ContainsKey("available"))
{
    Int64 available = Convert.ToInt64(e.Result["available"]);
    byte[] data = RecordManager.GetRecordByteArray(Binder.Instance.CurrentlyUploading);
    if (available >= data.Length)
    {
        MemoryStream stream = new MemoryStream(data);
        client = new LiveConnectClient(App.MicrosoftAccountSession);
        client.UploadCompleted += MicrosoftAccountClient_UploadCompleted;
        client.UploadProgressChanged += MicrosoftAccountClient_UploadProgressChanged;
        client.UploadAsync("me/skydrive", Binder.Instance.CurrentlyUploading, stream, OverwriteOption.Overwrite);
        grdUpload.Visibility = System.Windows.Visibility.Visible;
        ApplicationBar.IsVisible = false;
    }
    else
    {
        MessageBox.Show(@"Looks like you don't have enough space on your SkyDrive. Go to http://skydrive.com/ and either purchase more space or clean up the existing storage.", "Upload",MessageBoxButton.OK);
    }
}
```

If there is available space, simply create a new instance of **LiveConnectClient**, with the current **LiveConnectSession** (you can keep it in the **App** class for global access) and use **UploadAsync** to pass the internal path to the file, the file name, the file stream and the overwrite method. By default, all files are being overwritten. Remember, however, that when you are specifying the path to the folder you want to upload the file to, you cannot use the normal path format, but rather refer to [folders by their ID][9]. You can find more details about it in [one of my previous articles][5]. For some folders, however, you can directly specify the path. Example: **me/skydrive/my_documents**. 

**UploadCompleted** and **UploadProgressChanged** can be used to define application behavior during and after the upload, such as displaying a popup that shows the current upload percentage. 

##### Making The Account Accessible App-Wide

One interesting fact worth mentioning in case you declared **wl.offline_access** as a pre-determined scope. The default behavior for the application is to authenticate the Microsoft Account when the page with a valid **SignInButton** is hit. My intent for Beem was to keep the **SignInButton** in the application settings, where it is expected by the end-user. However, in this case the user will only be automatically authenticated when the Settings page would be opened, which is something that does not happen too often, in contrast with the multitude of other pages that are being used internally. 

The workaround to this small issue is really simple – make sure that you add a **SignInButton** with exactly the same scopes and **ClientID** in the main application page, and set its **Visibility** property to **Collapsed**. You will need to wire it up to the SessionChanged event handler, that can be the same for both sign-in buttons used in the application.

 [1]: http://msdn.microsoft.com/en-us/live/ff519582.aspx
 [2]: http://msdn.microsoft.com/en-us/library/live/hh826521.aspx
 [3]: http://www.windowsphone.com/en-us/store/app/beem/1bc66496-6941-41e6-876a-2ba818ab0ceb
 [4]: http://www.windowsphone.com/en-us/store/app/beem/8433ad41-9a4e-46ff-ba33-340d265f53d5
 [5]: http://dotnet.dzone.com/articles/things-know-about-uploading
 [6]: http://msdn.microsoft.com/en-us/library/live/hh243641.aspx#signin
 [7]: http://msdn.microsoft.com/en-us/library/live/hh243646.aspx
 [8]: https://manage.dev.live.com/AddApplication.aspx
 [9]: http://msdn.microsoft.com/en-us/library/live/hh826531.aspx