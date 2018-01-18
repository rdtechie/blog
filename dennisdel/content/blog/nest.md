---
title: Unlimited storage for your Nest cam, with no subscription
type: blog
date: 2018-01-07T01:00:00+00:00
slug: nest
news_keywords: [ "nest", "camera", "how-to", "aware" ]
images: ["https://dennisdel.com/images/postmedia/nest/foggycam-logo.png"]
---

![Foggycam logo](/images/postmedia/nest/foggycam-logo.png)

**TL;DR:** Go to GitHub and clone [`foggycam`](https://github.com/dend/foggycam) to capture unlimited-length Nest video streams to any storage of your choosing without paying for Nest Aware.

>**VERY IMPORTANT NOTE:** What I describe below was put together by analyzing how the Nest apps communicate with the infrastructure. None of these items use [official REST APIs](https://developers.nest.com/) (unfortunately, those don't expose the video stream), therefore can break at any time.

We recently got a [Nest cam](https://nest.com/ca/cameras/nest-cam-indoor/overview/), and we absolutely love the capabilities it brings to our home. One of the staples of the camera was the capability to record footage and then replay it later. The problem with that is we needed to pay for a subscription, and in my humble opinion, it's a bit pricey.

There are many workarounds mentioned publically, that all suggest using third-party software, that require making the camera stream public under the assumption that _nobody can guess the URL_. For the love of everything, **[do not do this](https://dennisdel.com/blog/psa-nest/) unless you are OK with all your video being public and open to anyone who wants to see you or your house**.

So I thought I'd spend a weekend (notice a pattern with weekend projects?) to figure out the inner workings of the video capture mechanism, and how I can capture video locally without having to bind myself to a paid subscription or making the stream public - the camera is already in my house, it captures the video through my own network, so getting captured static and dynamic images should be relatively painless. This was the day [`foggycam`](https://github.com/dend/foggycam) was born.

## Getting Fundamental Data

My toolbelt of choice here was [Python](https://www.python.org/) and related libraries - I could just write a script that captures everything I need stored, and it will work seamlessly across platforms. My starting point was analyzing the traffic from the [Nest Home website](https://home.nest.com/).

What I quickly noticed was the fact that the request authentication was mostly done via cookies after the original authorization. However, there were some _intitialization steps_ that needed to be taken beforehand.

First and foremost, there is a `POST` request done against `https://home.nest.com/session`, that initilizes the current user session. I formalized that [in a simple function](https://github.com/dend/foggycam/blob/master/foggycam.py#L51):

```python
def initializeSession(self):
    print 'INFO: Initializing session...'
    payload = {'email':self.nest_username, 'password':self.nest_password}
    request = urllib2.Request(self.nest_session_url)
    request.add_header('Content-Type','application/json')
    response = self.merlin.open(request,json.dumps(payload))
    session_data = response.read()
    session_json = json.loads(session_data)
    self.nest_access_token = session_json['access_token']
    self.nest_access_token_expiration = session_json['expires_in']
    self.nest_user_id = session_json['userid']
    print 'INFO: [PARSED] Captured authentication token:'
    print self.nest_access_token
    print 'INFO: [PARSED] Captured expiration date for token:'
    print self.nest_access_token_expiration
    cookie_data = dict((cookie.name, cookie.value) for cookie in self.cookie_jar)
    for cookie in cookie_data:
        print cookie
    print 'INFO: [COOKIE] Captured authentication token:'
    print cookie_data["cztoken"]
    print 'INFO: Session initialization complete!'
```

The payload here is the JSON-ified representation of the Nest username and password. This request mimcs that performed through the Nest web app. You might also notice an interesting global variable - `merlin`. This is essentially a [web request maker](https://github.com/dend/foggycam/blob/master/foggycam.py#L43), that is preserving cookies as requests are performed. 

Remember - after the original auth is performed, calls are not receiving any explict auth tokens, but rather are reading in domain-specific cookies. When the request is performed, if it is successful, you will get a JSON with detailed user information.

In addition, I am reading in and storing the access token for another future call, that is going to required it `POST`-ed.

>**NOTE:** The `userid` I am reading in `initializeSession` is not the same as the user email, but is rather a numeric identifier used internally.

That's all fine and dandy, however one token that is required to be stored inside the cookie, that is not yet in our posession is `website_2`. Particularly, I could not figure out where it's being generated through the web app because a lot of the requests seem to be already coming with it built-in, so likely some piece of JS code was generating it on the fly.

I noticed that there was a response from `https://home.nest.com/dropcam/api/login` that did a `Set-Cookie` with `website_2`, but I was still hitting authentication issue with the call, even though I passed the required credentials.

After hitting my head against the wall a couple of times, I thought I would double check how the mobile Nest app handles authentication. With a [little bit of `mitmproxy` help](https://dennisdel.com/blog/intercepting-iphone-traffic-on-a-mac---a-how-to-guide/), I've noticed that the iOS app was making a different request, to the following URL:

```txt
https://webapi.camera.home.nest.com/api/v1/login.login_nest
``` 

I wonder if I can use that - so I [send the exact same payload to it](https://github.com/dend/foggycam/blob/master/foggycam.py#L82), but to a different URL:

```python
def login(self):
    print 'INFO: Performing user login...'
    post_data = {'access_token':self.nest_access_token}
    #post_data = json.dumps(post_data)
    post_data = urllib.urlencode(post_data)
    print "INFO: Auth post data"
    print post_data
    request = urllib2.Request(self.nest_api_login_url,data=post_data)
    request.add_header('Content-Type','application/x-www-form-urlencoded')
    response = self.merlin.open(request)
    session_data = response.read()
    
    print session_data
```

Voila! Just like that, the call succeeded and I managed to get the coveted `website_2` stored in my cookie jar.

Next, I wanted to get some information about the cameras I have registered. That can be obtained with the help of `https://home.nest.com/api/0.1/user/#USERID#/app_launch`. Given that I already was in posession of the `userid`, I can just substitute that here, and [perform user initialization](https://github.com/dend/foggycam/blob/master/foggycam.py#L100):

```python
def initializeUser(self):
    print 'INFO: Initializing current user...'
    user_url = self.nest_user_url.replace('#USERID#',self.nest_user_id)
    print 'INFO: Requesting user data from:'
    print user_url
    request = urllib2.Request(user_url)
    request.add_header('Content-Type','application/json')
    request.add_header('Authorization','Basic %s' % self.nest_access_token)
    response = self.merlin.open(request, self.nest_user_request_payload)
    response_data = response.read()
    print response_data
    user_object = json.loads(response_data)
    for bucket in user_object['updated_buckets']:
        bucket_id = bucket['object_key']
        if bucket_id.startswith('quartz.'):
            camera_id = bucket_id.replace('quartz.','')
            print 'INFO: Detected camera configuration.'
            print bucket
            print 'INFO: Camera UUID:'
            print camera_id
            self.nest_camera_array.append(camera_id)
```

One piece of information that I am looking for is the camera ID - when I get the user information, I get a list of objects, such as the geofence, thermostats, etc. I just need the camera, and it appears that the most straightforward way is to find objects that [start with `quartz.` in their name](https://github.com/dend/foggycam/blob/master/foggycam.py#L121). The object ID, stripped of the prefix (in this case, `quartz.`), is the camera UUID.

>**NOTE:** I tried to write the code in a way that supports multiple cameras, but only have one myself - if you have more than one Nest camera, let me know how it works for you!

We now have everything we need to make sure we can capture images and produce the associated video contnent.

## Capturing Images & Producing Video

Nest does not expose the video stream directly - it's piped through WebSockets, and is DRM-d, therefore without having the key, it's pointless to even attempt to capture it. That said, Nest does expose an endpoint that gives the image of the current camera state:

```txt
https://nexusapi-us1.camera.home.nest.com/get_image?uuid=#CAMERAID#&width=#WIDTH#&cachebuster=#CBUSTER#
```

Remember, that we already have the camera UUID, and the cookies allow us to `GET` anything through this endpoint, as long as we are authorized to do so. [`captureImages`](https://github.com/dend/foggycam/blob/master/foggycam.py#L129) does just that.

This function conveniently provides a way to store images either in the script folder, or in any custom folder of your choosing, via the `custom_path` parameter. So if you want to just dump all content in your Dropbox, OneDrive or Box folder, you can do so by pointing this to a path that syncs to any of the listed (or unlisted) backup services.

>**NOTE:** The tool doesn't yet support uploading content directly to cloud storage providers. This is on my TODO list, so that you can run the script in the cloud (e.g. inside a container or VM).

In addition to storing images, I want to also combine those in a video - given that we are not dealing with the DRM-d stream, we can just perform multiple requests to get image snapshots and then combine them in a video with the [help](https://github.com/dend/foggycam/blob/master/foggycam.py#L200) of [ffmpeg](https://www.ffmpeg.org/):

```python
ffmpegpath=os.path.join(self.local_path,'tools','ffmpeg')
if os.path.isfile(ffmpegpath):
    print 'INFO: Found ffmpeg. Processing video!'
    target_video_path = os.path.join(video_path, timestamp + '.mp4')
    process = Popen([ffmpegpath, '-r', '24', '-f', 'concat', '-safe', '0', '-i', concat_file_name, '-vcodec', 'libx264', '-crf', '25', '-pix_fmt', 'yuv420p', target_video_path], stdout=PIPE, stderr=PIPE)
    stdout, stderr = process.communicate()
    os.remove(concat_file_name)
    print 'INFO: Video processing is complete!'
    # If the user specified the need to remove images post-processing
    # then clear the image folder from images in the buffer.
    if clear_images:
        for buffer_entry in camera_buffer[camera]:
            os.remove(camera_image_folder + '/' + buffer_entry + '.jpg')
else:
    print 'WARNING: No ffmpeg detected. Make sure the binary is in /tools.' 
```

Once the requests are processed, you will get a `.mp4` file in the folder, generated after fixed intervals - and by that, I mean having a fixed number of buffered images that can be combined in a video. For testing purposes, I set that threshold to be 200, which roughly translates into 8 second video clips - that way it's uploaded fast and in consumable chunks (~1MB each given current `ffmpeg` settings).

And just like that, you have local captures of the Nest video without paying for Nest Aware. You can download the tool from GitHub, rename the `_config.json` file to `config.json`, specify your Nest credentials, and run the script via `python start.py`.

## Room for Improvement

There are a lot of pieces still missing in this tool, like the ability to upload directly to different cloud providers, checking for token expiration, optimizing the video and image storage and more. I will be working on that in my free time, so stay tuned for updates!