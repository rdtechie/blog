---
title: Installing Windows 10 with a large USB drive
type: blog
date: 2017-11-25T07:06:59+00:00
slug: installing-windows-large-usb-flash
---

Got an interesting problem today - had to re-image a Surface Pro 3, but only had a 64GB flash drive handy. Following the typical dance, I installed the [Windows 7 USB/DVD Download Tool](http://wudt.codeplex.com/), downloaded a Windows 10 ISO from my Visual Studio subscription download site, used WUDT to put the ISO on the flash drive and... nothing.

My Surface Pro 3 would just refuse to even look at the USB for boot information. So what's the deal here?

As it turns out, the expectation is that the flash drive will be formatted in FAT32, with the ISO contents on it. WUDT would format the drive into NTFS, and still put the right content on it, but the machine would never treat the USB as something to read an OS installer from. How do you solve that without buying a new small flash drive, and formatting is as NTFS? By temporarily making your large flash drive be smaller.

That's right, you paid for a 64GB USB flash, and now you're going to make it appear as if it is 6GB, with the help of our old friend `DISKPART`.

1. Plug in your flash drive.
2. Run the Command Prompt as Administrator.
3. Type in `DISKPART` and press `ENTER`.
4. Type in `LIST DISK` and press `ENTER`. You will see a list of connected disks. Note the USB flash (look at the size to see which one it is).
5. Type in `SELECT DISK X`, where `X` is the number identifying the flash drive.
6. Type in `CLEAN` - this will literally obliterate the partition table, so use caution and backup the drive if you needed any info on it (I hope not - you're using it as an installer surface).
7. Type in `CREATE PARTITION PRIMARY SIZE=6000`.
8. Type in `ASSIGN` - this will give your partition a letter.
9. In Windows Explorer, right-click on the USB partition you just create it, and format it in FAT32. Using Quick Format is a-OK.
10. Copy contents on the ISO to the partition.
11. Boot from partition and install Windows.

I wish I had this guide handy 4 hours ago.