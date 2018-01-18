---
title: Serve your WordPress blog via HTTPS on NameCheap (for free)
type: blog
date: 2016-05-30T06:41:52+00:00
---
Gone are the days when you no longer have to worry whether you want to fetch a website through HTTPS. No matter whether you are handling private information or not, there is no excuse to have a site residing in plain HTTP land. That said, this tutorial assumes that you, the reader, already have some knowledge as to why HTTPS is necessary. If not, a cursory search will yield <a href="http://mashable.com/2011/05/31/https-web-security/#03Sr_oEYmsqh" target="_blank">thousands</a> of <a href="https://developers.google.com/web/fundamentals/security/encrypt-in-transit/why-https?hl=en" target="_blank">articles</a> you can read through.

## Obtaining the certificate

This is the first step, and probably the most important one. You might be thinking that this would be that time when you need to shell out $90 to $100 a year for a certificate that will give you that coveted green lock in the browser address bar. But that is no longer the case with services such as <a href="https://letsencrypt.org/" target="_blank">Let’s Encrypt</a>.

Let’s Encrypt offers a straightforward way to generate a certificate through a trusted authority that you can use on your site at no cost to the requestor. The service itself (and most of the documentation for it) is geared at users who run their own web server, so I will explain how you can use it with a shared hosting subscription, specifically <a href="https://www.namecheap.com" target="_blank">NameCheap</a>.

> **NOTE:** I am writing this and testing this on a Mac. Your steps might slightly vary depending on the platform, but overall should be the same on both Linux and even Windows (now that it <a href="http://www.howtogeek.com/249966/how-to-install-and-use-the-linux-bash-shell-on-windows-10/" target="_blank">supports bash</a>).

First and foremost, lets clone the letsencrypt toolchain:

```bash
sudo git clone https://github.com/letsencrypt/letsencrypt
```

![macOS terminal](/images/postmedia/serve-wordpress-https-namecheap/image.png)

This should take anywhere between 5 to 30 seconds, depending on your connection. Next, you need to install **letsencrypt**. To do this, make sure that you go one folder down in the tree, in whatever location you downloaded the packages:

```bash
cd letsencrypt
./letsencrypt-auto -help
```

![macOS terminal](/images/postmedia/serve-wordpress-https-namecheap/image-1.png)

Now, let’s actually generate the certificate:

```bash
letsencrypt-auto certonly -manual –email [YOUR EMAIL HERE] –d [DOMAIN].com -d www.[DOMAIN].com
```

You will be prompted with a number of questions, including whether you agree to the fact that the requesting IP address will be logged.

![macOS terminal](/images/postmedia/serve-wordpress-https-namecheap/image-2.png)

You will then be prompted to create a folder on your server, and within that folder – a simple **index.html** file with just a blob of text in it:

![macOS terminal](/images/postmedia/serve-wordpress-https-namecheap/image_thumb-3.png)

You can easily do this with the help of a FTP client (I recommend <a href="https://filezilla-project.org/" target="_blank">FileZilla</a>). Make sure you have the correct FTP credentials before proceeding.

## Installing the certificate

Once everything is ready to go and the verification succeeds, you will get three files on your hands:

* **cert.pem** – this is the certificate itself.
* **privkey.pem** – this is the private key.
* **chain.pem** – this is the CABUNDLE, or the <a href="https://www.namecheap.com/support/knowledgebase/article.aspx/986/69/what-is-ca-bundle" target="_blank">Certificate Authority Bundle</a>.

By default, once the files are generated, you might not be able to access them. Use the terminal to <a href="https://en.wikipedia.org/wiki/Chmod" target="_blank">chmod your way in</a>. You can open the files in your favorite text editor to see their content.

In cPanel, you will now be able to add the contents of the certificate files (unfortunately, at the time of writing this article, there is still no support to actually upload certificate files).

Now your blog will run on HTTPS with a green lock in the browser:

![Chrome](/images/postmedia/serve-wordpress-https-namecheap/image-4.png)

## Force SSL

Now you need to make sure that the blog always fetches content through HTTPS. For that, you can install a free plug-in, such as <a href="https://wordpress.org/plugins/https-redirection/" target="_blank">Easy HTTPS (SSL) Redirection</a>. The plugin exposes a range of settings, that make it live up to its name:

![Force HTTPS WordPress](/images/postmedia/serve-wordpress-https-namecheap/image-5.png)

Congratulations, you are now all set!