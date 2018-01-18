---
title: Moving Beem from Static XML to Azure Mobile Services
type: blog
date: 2013-01-18T15:20:00+00:00
---

While working on [Beem][1], I always relied on a static XML file to fetch me the list of available online radio streams. It’s a good way to keep the content dynamic, and when new stations are added, I do not have to re-submit the application for certification but rather just update the XML file. This worked fine for a while, but I thought about having a more optimal way to get the necessary data. Specifically, I wanted to have a backend that can be easily extended and modified when necessary. Relying on an XML file means that I am restricted to the static data set, that has to be re-downloaded all the time whenever something from it is needed. 

The switch was done in favor of [Azure Mobile Services][2]. That way, I can go as far as run LINQ queries on my data and get a JSON-formatted output exactly for what I need, if I am building a companion app for Windows Phone 8 or Windows 8. More than that, the data can be easily updated directly from the mobile device, without having the XML file downloaded in its entirety. And while it is not that large, on devices with limited data this is a consideration I have to throw into the play. 

Let’s start with the fact that there is no Azure Mobile Services SDK for Windows Phone 7.5 applications. If the application would be designed for Windows Phone 8, you can download the official [toolset][3]. [Beem][1] supports multiple devices that are running Windows Phone OS 7.5, therefore I cannot do the full switch to Windows Phone OS 8. Does this mean that I cannot use AMS? No. There are some trade-offs, such as the fact that I no longer have SDK-based access to LINQ queries out-of-the-box, but I can still access the information in the way I want due to the fact that AMS sports a [REST API][4]. So all I needed is implement my own client class. 

My recommendation would also be to use [JSON.NET][5] in your application, since the data returned by HTTP requests will be JSON-formatted, but you can also parse JSON manually (who would reinvent the wheel anyway?) if you want to. Getting back to the application, I am operating on a **Station** model:

```csharp
using System;
using System.Windows;
using System.Xml.Serialization;
using System.Collections.ObjectModel;
using System.ComponentModel;
 
namespace Beem.Models
{
  public class Station : INotifyPropertyChanged
  {
    // Required by Azure Mobile Services
    // As we transition from XML to ZUMO, this will be persistent.
    [XmlIgnore()]
    public int? Id { get; set; }
    
    [XmlElement("name")]
    public string Name { get; set; }
    [XmlElement("location")]
    public string Location { get; set; }
    [XmlElement("image")]
    public string Image { get; set; }
    [XmlElement("description")]
    public string Description { get; set; }
    [XmlElement("jsonid")]
    public string JSONID { get; set; }
    
    private ObservableCollection<Track> _trackList;
    [XmlIgnore()]
    public ObservableCollection<Track> TrackList
    {
      get
      {
        return _trackList;
      }
      set
      {
        if (_trackList != value)
        {
          _trackList = value;
          NotifyPropertyChanged("TrackList");
        }
      }
    }
    
    private Track _nowPlaying;
    public Track NowPlaying
    {
      get
      {
        return _nowPlaying;
      }
      set
      {
        if (_nowPlaying != value)
        {
          _nowPlaying = value;
          NotifyPropertyChanged("NowPlaying");
        }
      }
    }
    
    public event PropertyChangedEventHandler PropertyChanged;
    private void NotifyPropertyChanged(String info)
    {
      if (PropertyChanged != null)
      {
        Deployment.Current.Dispatcher.BeginInvoke(() => { PropertyChanged(this, new PropertyChangedEventArgs(info)); });
      }
    }
  }
}
```

What we need to have in the AMS storage is a reference to the station ID, name, description, stream URL (location), image URL and the JSON ID that will be subsequently used to query the currently playing track, as well as the previously played content. One way to do this is enable [dynamic schema][6], where I can push items into the store, but I can also access the server through SQL Server Management Studio.

You can get the connection information in the [Azure Management Portal][7].

Back to the fact that I needed to implement my own connection client. Here is what I did:

```csharp
public class MobileServicesClient
{
  private const string CORE_URL = "https://beem.azure-mobile.net/tables/";
  private const string KEY = "";
  
  private WebClient client;
  
  public MobileServicesClient()
  {
    client = new WebClient();
    client.Headers["X-ZUMO-APPLICATION"] = KEY;
    client.Headers["Accept"] = "application/json";
  }
  
  public void GetAllStations(Action<IEnumerable<Station>> onCompletion)
  {
    client.DownloadStringCompleted += (s, e) =>
    {
      IEnumerable<Station> stations = JsonConvert.DeserializeObject<IEnumerable<Station>>(e.Result);
      onCompletion(stations);
    };
    client.DownloadStringAsync(new Uri(string.Concat(CORE_URL, "Station")));
  }
  
  public void AddStation(Station station, Action onCompletion)
  {
    var serializedObject = JsonConvert.SerializeObject(station,
    new JsonSerializerSettings() { NullValueHandling = NullValueHandling.Ignore });
    string content = serializedObject;
    
    client.Headers[HttpRequestHeader.ContentType] = "application/json";
    client.Headers[HttpRequestHeader.ContentLength] = content.Length.ToString();
    
    var uri = new Uri(string.Concat(CORE_URL, "Station"));
    
    client.UploadStringCompleted += (s, e) => {
      onCompletion();
    };

    client.UploadStringAsync(uri, content);
  }
}
```

In this class, I need to define the connection API key (once again, obtained in the Azure Management Portal). Remember that depending on the actions that you will take on the database, you need to make sure that the operation is permitted for the given key. 

The requests against the store are performed with the help of a [WebClient][8] class, where I am also setting the proper authentication (X-ZUME-APPLICATION) and content headers. When I am simply trying to get the data, the only part that I need to add to the core URL is the table name – in my case, **Station**. When the response is received, I can deserialize it as [IEnumerable<Station>][9] and then bind it anywhere in the application, which ultimately results in this:

<img border="0" alt="2 of 6" src="http://cdn.marketplaceimages.windowsphone.com/v8/images/954db389-12e9-4e42-83a2-4de2b84fbe50?imageType=ws_screenshot_large&rotation=0" width="185" height="308" />

Adding data is done with the help of **AddStation**. The process is pretty much the opposite of how the data retrieval happens. I am serializing a station to JSON and calling [UploadStringAsync][10] to perform a POST request. Easy and effective – the new release of Beem will be running on top of AMS.

 [1]: http://www.windowsphone.com/en-us/store/app/beem-plus/8433ad41-9a4e-46ff-ba33-340d265f53d5
 [2]: http://www.windowsazure.com/en-us/develop/mobile/
 [3]: https://go.microsoft.com/fwLink/p/?LinkID=268375
 [4]: http://msdn.microsoft.com/en-us/library/windowsazure/jj710108.aspx
 [5]: http://james.newtonking.com/projects/json-net.aspx
 [6]: http://www.windowsazure.com/en-us/develop/mobile/tutorials/get-started-with-data-dotnet/
 [7]: https://manage.windowsazure.com/
 [8]: http://msdn.microsoft.com/en-us/library/system.net.webclient(v=vs.95).aspx
 [9]: http://msdn.microsoft.com/en-us/library/system.collections.ienumerable(v=vs.95).aspx
 [10]: http://msdn.microsoft.com/en-us/library/system.net.webclient.uploadstringasync(v=vs.95).aspx