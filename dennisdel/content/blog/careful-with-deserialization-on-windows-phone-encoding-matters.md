---
title: Careful With Deserialization on Windows Phone – Encoding Matters
type: blog
date: 2012-12-30T15:17:00+00:00
---

Serialization is a process that is prone to errors, especially with a poorly structured data layer. However, that is not always the case and a seemingly normal serialization/deserialization scenario might turn out to produce unexepected results. As I was working on a Windows Phone application, I had this standard routine:

```csharp
public static void SerializeToFile(object serializationSource, Type serializationType, string fileName)
{
  XmlSerializer serializer = new XmlSerializer(serializationType);
  MemoryStream targetStream = new MemoryStream();
  serializer.Serialize(targetStream, serializationSource);
  LocalStorageHelper.WriteData(fileName, targetStream.ToArray());
}
```

The deserialization would occur like this:

```csharp
XmlSerializer serializer = new XmlSerializer(typeof(List));
string data = await LocalStorageHelper.ReadData("imagestack.xml");
TextReader reader = new StringReader(data);
var resultingObject = serializer.Deserialize(reader);
```

But this caused an exception to be thrown, and not just a regular one, but one that would crash the application and break the debugging process.

Looking at the snippet above, it is really hard to tell what the issue is, especially if the XML that is being retrieved from the file is valid. However, upon deserialization there is no place where the string encoding is actually specified, which results in the unexpected behavior that we are seeing. By default, the serialization engine sets the encoding to be UTF-8, which should also be respected when deserializing.

So instead of the deserialization snippet above, you need to use this:

```csharp
XmlSerializer serializer = new XmlSerializer(typeof(List));
string data = await LocalStorageHelper.ReadData("imagestack.xml");
MemoryStream memoryStream = new MemoryStream(Encoding.UTF8.GetBytes(data));
var resultingObject = serializer.Deserialize(memoryStream);
```