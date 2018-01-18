---
title: Last.fm API for a Windows Phone App – Scrobbling a Track
type: blog
date: 2013-01-19T15:24:00+00:00
---

As I discussed the basic of authentication in <a href="http://www.dennisdel.com/?p=24" target="_blank">my previous post</a>, the most important Last.fm feature that is added to [Beem][1] in itself is track scrobbling, which will allow you to keep records of what you listened to from your favorite music aggregation service. The implementation of the method used to send the track from the app to Last.fm is extremely similar to **GetMobileSession**.

```csharp
public void ScrobbleTrack(string artist, string track, string sessionKey, Action<string> onCompletion)
{
  string currentTimestamp = DateHelper.GetUnixTimestamp();
  
  var parameters = new Dictionary<string, string>();
  parameters.Add("artist[0]", artist);
  parameters.Add("track[0]", track);
  parameters.Add("timestamp[0]", currentTimestamp);
  parameters.Add("method", "track.scrobble");
  parameters.Add("api_key", API_KEY);
  parameters.Add("sk", sessionKey);
  
  string signature = GetSignature(parameters);
  
  string comboUrl = string.Concat(CORE_URL, "?method=track.scrobble", "&api_key=", API_KEY,
  "&artist[0]=", artist, "&track[0]=", track, "&sk=", sessionKey,
  "&timestamp[0]=", currentTimestamp,
  "&api_sig=", signature);
  
  var client = new WebClient();
  client.UploadStringAsync(new Uri(comboUrl), string.Empty);
  client.UploadStringCompleted += (s, e) =>
  {
    try
    {
      onCompletion(e.Result);
    }
    catch (WebException ex)
    {
      HttpWebResponse response = (HttpWebResponse)ex.Response;
      using (StreamReader reader = new StreamReader(response.GetResponseStream()))
      {
        Debug.WriteLine(reader.ReadToEnd());
      }
    }
  };
}
```

The new required parameters here are the artist name, the track name, a UNIX-style timestamp and the session key that you obtained from the core authentication method. Although there is no method in C# to give you the UNIX timestamp right away, you can easily do it like this:

```csharp
using System;
 
namespace Beem.Utility
{
  public static class DateHelper
  {
    public static string GetUnixTimestamp()
    {
      TimeSpan t = (DateTime.UtcNow - new DateTime(1970, 1, 1));
      return ((int)t.TotalSeconds).ToString();
    }
  }
}
```

Also notice that the parameters for the track are sent in array format. Since I am only scrobbling one track at a time, I can use the index zero [0]. Your situation might be different. **ScrobbleTrack** can be invoked like this:

```csharp
LastFmClient client = new LastFmClient();
client.ScrobbleTrack("Armin van Buuren", "In and Out Of Love", "SESSION_KEY", (s) =>
{
  Debug.WriteLine("Success!");
});
```

You should now see the track registered on Last.fm.

 [1]: http://www.windowsphone.com/en-us/store/app/beem-plus/8433ad41-9a4e-46ff-ba33-340d265f53d5