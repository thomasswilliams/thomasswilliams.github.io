---
layout: post
title:  "A mini-rack and UNAS (Unifi 2025 update)"
date:   2025-11-16 12:00:00 +1100
categories: networking
---

In 2017 I [first upgraded my home network to Unifi]({% post_url 2017-03-03-home-network-unifi %}). By 2020, I'd [added a 2nd switch and tuned the network]({% post_url 2020-03-19-unifi-update-2020 %}) and was heavily using Apple's Time Machine for backups to a 2017-era Airport Extreme Time Capsule. Later, in 2022, I [replaced my UniFi Security Gateway and original Cloud Key with a UniFi Dream Machine SE]({% post_url 2022-09-01-unifi-upgrade-2022-2 %}).

Last year I added cameras - was surprisingly straightforward, the Unifi Dream Machine I got in 2022 allowed for a hard drive for NVR recording, and delivers power over ethernet (PoE)

Now in 2025, I've just added a Unifi NAS (a beast with space for 7 drives, and 10GB networking)[^1].

As at right now the NAS has two 16TB drives, mirrored, and is using 2.7TB. I've allowed 1TB personal space for each family member, hosted myself as opposed to cloud backup.

Is it overkill? Probably! I've been fortunate to gradually build up my home network, and I learned long ago many things can't be done with a consumer home router alone. Plus I now have great management capabilities, integrated security cameras, storage to grow into, firewall, VLANs to separate IoT devices and cameras, multiple APs giving great wifi coverage, and other "small business"-level features.

One of the ways my network could grow over the next few years is faster networking. Unifi have a range of devices that are 2.5GB, potentially replacing my tank-like 1GB 8 port switches (which also run a little hot).

Here's the mini-rack with the UDM (top) and NAS (bottom) as neat as I can manage, in a small cupboard:

![UDM, UNAS on mini-rack](/images/4u-rack-udm-se-unas-aug-2025.png)

The mini-rack is shallower than a full rack, see full specs at <https://tecmojo.com/products/tecmojo-4u-wall-mount-rack-4u-rack-14-inch-depth-19-network-rack-for-shallow-server-and-it-equipment-network-switches-patch-panel-bracket-110lbs50kg-weight-capacity-black>.

Next is the setup as it was in 2021/2022 - pre-UDM - when an 8-port switch was enough:

![Cloud Key, USG and 8-port switch](/images/unifi-cloud-key-usg-and-switch-aug-2022.jpg)

[^1]: While I don't see myself as a total Unifi fanboy, I admit I'm biased. I didn't get paid for this post (I wish!)