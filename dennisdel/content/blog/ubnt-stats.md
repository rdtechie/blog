---
title: Pulling Ubnt Stats Locally
type: blog
date: 2017-12-28T07:06:59+00:00
slug: ubnt-stats
images: ["https://dennisdel.com/images/postmedia/ubnt-stats/heading.png"]
news_keywords: [ "ubnt", "mongodb", "data" ]
---

![Ubnt Stats](/images/postmedia/ubnt-stats/heading.png)

I love looking at my Ubnt graphs - how much traffic goes where, to what clients, and many other interesting indicators. But I am also the kind of person that loves having raw access to the data, so I started digging - how can I pull those statistics locally?

The setup I run is [described here](https://dennisdel.com/blog/ubiquiti-edgerouter-as-level-2-switch/) - I have a [cloud key](https://www.ubnt.com/unifi/unifi-cloud-key/) that manages the network, composed of a [router](https://www.ubnt.com/edgemax/edgerouter-poe/) acting as a switch, [access point](https://www.ubnt.com/unifi/unifi-ap-ac-pro/) and the [security gateway](https://www.ubnt.com/unifi-routing/usg/). So, when I am thinking about the data aggregated, I think of the cloud key, that stores it. Some more digging [points](https://help.ubnt.com/hc/en-us/articles/204911424-UniFi-How-to-Remove-Prune-Older-Data-and-Adjust-Mongo-Database-Size) that the data is likely managed by a [MongoDB instance](https://www.mongodb.com/) - that should be easy.

To see what I can dig up, I SSH into the cloud key:

```
ssh ubnt@192.168.1.9
```

Going through `/usr/bin` reveals what we would expect:

![SSH into the Ubnt cloud key](/images/postmedia/ubnt-stats/ubnt-ssh.png)

This means that we can also easily dump data out. The MongoDB instance is running on **port 27117** and the database we are looking for is called **ace_stat**:

```
/usr/bin/mongodump -d ace_stat -o /home/datadump -port 27117
```

![Dump data](/images/postmedia/ubnt-stats/dump-data.gif)

If all goes well, now you should have the data dump ready on the key. You now can export it to the local machine (the one you SSH-d out of):

```
scp -r ubnt@192.168.1.9:/home/datadump /Users/targaryen/Downloads/ubnt-data
```

You should now have the complete data dump locally:

![Content of the data dump](/images/postmedia/ubnt-stats/data-content.png)

Time to view the data locally! For that, make sure that you [install MongoDB first](https://www.mongodb.com/download-center?jmp=nav) on your local computer. Instructions may vary depending on the platform, so I will leave it up to you to follow the right set of steps from official documentation.

I like to have a GUI for my data, so given that I am working on a Mac, I downloaded and installed [Robo3T](https://robomongo.org/).

To import the data, make sure that the MongoDB server is running (typically can be done by running `mongod --dbath {PATH_TO_SOME_DATA_DIRECTORY}`). Once it's up, just run the import command:

```
mongorestore -d ace_stat ubnt-data/ace_stat
```

You are specifying the new database, and the source of the backup. Now, when you go to a tool, like Robo3T, you can see all the stat data, in the `ace_stat` database:

![Screenshot of data](/images/postmedia/ubnt-stats/pull-data.png)

Now you are in posession of the data snapshot! Next on my TODO list is to create a scheduled job that will pull the data, re-format it in a more consumable format (e.g. CSV) and plug it into an analytics platform. 

Cheers!
