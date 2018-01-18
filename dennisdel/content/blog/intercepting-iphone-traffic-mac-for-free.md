---
title: Intercepting iPhone Traffic on a Mac - A How-To Guide
type: blog
date: 2017-09-27T19:16:06+00:00
---

Curiosity got the best of me about a year ago when Pokemon Go came out, so I had to dig up ways to inspect traffic from iOS on a Mac. Since then, time has passed and today I decided to do it again, but couldn't find a decent guide on how to do that (clearly I was missing some steps), so once I figured out what goes where, I thought I would do a write-up for posterity, and so that I can re-use it later. Hopefully this will be helpful to the broader audience as well!

# Getting started

First things first, I am just assuming that you have unfettered access to your iOS device. This is where I am talking about the fact that your device is not locked down by your company, or has any other constraints. The running assumption is that you can pretty much modify any settings that needs to be, given a stock configuration (you don't need to have the device jailbroken). 

## Setting up the toolchain

We will need to use a tool called `mitmproxy`. The easiest (IMHO) way to install it is via a publicly-maintained Docker image. Which means that I recommend you [install Docker](https://docs.docker.com/engine/installation/). Once Docker is on your system, just run this in the terminal:

```bash
docker pull mitmproxy/mitmproxy
```

![pull docker image](/images/postmedia/intercepting-ios-traffic/mitmproxy-install.gif)

Verify that the Docker image is there once the pull completes:

```bash
docker images
```

![verify docker image](/images/postmedia/intercepting-ios-traffic/docker-images.gif)

## Running mitmproxy

Given that everything went smoothly in the steps outlined above, now you can run the image and bind it to port 8080:

```bash
docker run --rm -it -v ~/.mitmproxy:/home/mitmproxy/.mitmproxy -p 8080:8080 mitmproxy/mitmproxy
```

![run docker image](/images/postmedia/intercepting-ios-traffic/mitm-run.gif)

# Capturing HTTP/S traffic

Now that `mitmproxy` is running, it's time to configure our iPhone to send traffic through it. In this scenario, the machine in which `mitmproxy` is running is the actual pipe that channels data through it, so we need to find it's IP address. You need to get the local IP, and for that, run the following command in your Terminal:

> **NOTE:** You can open another Terminal window, since you have `mitmproxy` running in the original one.

```bash
ipconfig getifaddr en0
```

`en0` typically stands for your wireless adapter (let's face it, you're probably running this on a MacBook, so this _should_ work).

![get ip](/images/postmedia/intercepting-ios-traffic/ip.gif)

Sweet! Now you can set this up as a proxy on your phone. Go to **Settings** > **Wi-Fi** > **Currently Connected Network** > **Configure Proxy** > **Manual** and enter the server IP and port (remember - it's 8080).

![iphone settings](/images/postmedia/intercepting-ios-traffic/settings.png)

Once you tap on **Save**, you should be able to go to your browser and start sending requests, that will be reflected in the proxy Terminal:

![mitm success](/images/postmedia/intercepting-ios-traffic/mitm-success.png)

Here is a problem, though:

![mitm success](/images/postmedia/intercepting-ios-traffic/problem.png)

Generally, sites and apps do SSL validation - in this case, because we are man-in-the-middle attacking our own device, the privacy check fails and no information is returned. That is, because we don't yet have a certificate installed that the device trusts. Luckily, it comes out-of-the-box with `mitmproxy` - all you need to do is go to **http://mitm.it** in your browser, while connected to the proxy:

>**NOTE:** For this page to properly work, make sure you open it in Safari.

![mitm page](/images/postmedia/intercepting-ios-traffic/mitm-page.png)

Since we are on iOS, the choice is obvious - tap on **Apple**. You should see a prompt that will ask your permission to view a custom profile:

![mitm page permissions](/images/postmedia/intercepting-ios-traffic/mitm-page-permission.png)

Click **Allow**, and now you should be taken to the **Install Profile** page:

![install profile](/images/postmedia/intercepting-ios-traffic/install-profile.png)

If prompted, make sure to enter your PIN - installing a profile is an administrative action (remember when I mentioned from the very beginning you'll need full control of the device?). As with all very serious steps, it's important to remind the reader - **only install profiles and certificates that you trust**. This enables your device traffic to be decrypted in its entirety.

![profile warning](/images/postmedia/intercepting-ios-traffic/profile-warning.png)

We're almost there. Now, we need to make sure that the iPhone device fully trusts the certificate to be able to read the piped traffic. To do that, go to **Settings** > **General** > **About** > **Certificate Trust Settings** and find **mitmproxy**:

![certificate trust](/images/postmedia/intercepting-ios-traffic/cert-trust.png)

Make sure to enable full trust for the newly installed certificate:

![certificate trust](/images/postmedia/intercepting-ios-traffic/trust-warning.png)

I will repeat myself - **only install profiles and certificates that you trust**. This enables your device traffic to be decrypted in its entirety by anyone.

Once you complete these steps, you will be able to analyze HTTPS traffic:

![inspection](/images/postmedia/intercepting-ios-traffic/inspection.gif)

# Conculsion

This might seem harder than it actually looks, but from start to finish this took around 10 minutes. For once, I am glad I don't have to deal with `pip` and other `brew`-based installation shenanigans, given that now I can just pull a Docker image. Oh yeah, and make sure you install [Kitematic](https://kitematic.com/) for better container management on a Mac - that way, you can control the runtime of each and every one of them without the Terminal.