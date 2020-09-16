---
layout: post
title:  "My home network upgrade to Ubiquiti UniFi"
date:   2017-03-02 15:40:00 +1000
categories: networking
---
[My last blog post]({% post_url 2017-02-13-my-home-network-2016 %}) described how, as at late 2016, my home network supported 5 users and 20 or so devices using a 3-year-old Apple Airport Extreme router, KoalaSafe router and older Netgear power line adapters.

Over the last couple of months I’ve researched what it would take to upgrade and (hopefully) address my network issues/wishlist.

There’s lots of products in the home networking space, including cool new mesh networks, and further options as you move into small business or school-grade hardware. I was impressed enough by [Troy Hunt][1], [Scott Helme][2] and countless forum posts to investigate Ubiquiti’s UniFi range (special shout-out to my wife for bearing with me as I deliberated over purchases, justified spending $$$, and finally clicked “buy”).

<blockquote class="twitter-tweet" data-partner="tweetdeck"><p lang="en" dir="ltr">Inspired by <a href="https://twitter.com/troyhunt">@TroyHunt</a> &amp; <a href="https://twitter.com/Scott_Helme">@Scott_Helme</a>, I upgraded to Ubiquiti network gear at home - great step-by-step at <a href="https://t.co/Inf7aVD5pj">https://t.co/Inf7aVD5pj</a> too!</p>&mdash; Thomas Williams (@tswilliams4) <a href="https://twitter.com/tswilliams4/status/831810688049827840">February 15, 2017</a></blockquote>
<script async src="//platform.twitter.com/widgets.js" charset="utf-8"></script>

For my situation I decided on an 8-port switch, a single wireless access point, a security gateway and the cloud key for remote management:

![Ubiquiti UniFi network](/images/unifi-network-2017.png)

I purchasing all the above from [City Technology][3] who were one of the cheapest, had all the products in stock, and shipped in 2 days. Once I unpacked the new arrivals, the set-up was uneventful; I followed a great guide at <https://help.ubnt.com/hc/en-us/articles/219051528-UniFi-How-to-Setup-your-Cloud-Key-and-UniFi-Access-Point-for-beginners-> which, allowing for time spent waiting on updates, took only a couple of hours (that’s pretty generous given my limited experience with network tech - I’m a “set and forget”-type guy).

Post-setup - UniFi provides more management and reporting than I know what to do with. The new network should last me a couple of years and I’ll probably sell the old Apple router which will help offset some of the cost. The network speed is an improvement too.

The web interface has lots of “wow” features. Below are a couple of screenshots of the type of data I can get out:

*Wired and wireless clients with lots of info, including signal strength and current activity*
![Wired and wireless clients with lots of info, including signal strength and current activity](/images/unifi-clients.png)

*Wireless networks in the area, with channels*
![Wireless networks in the area, with channels](/images/unifi-nearby-aps.png)

*Traffic stats (requires deep packet inspection on the security gateway), can drill down for more data, yes we watch a lot of Netflix*
![Traffic stats (requires deep packet inspection on the security gateway), can drill down for more data, yes we watch a lot of Netflix](/images/unifi-traffic-stats.png)

I had two interesting issues that have more to do with my situation than Ubiquiti:

**WeMo devices on UniFi**

To get my Belkin WeMo devices working on the new wireless network I had to take a couple of extra steps, as they seem to use an older wi-fi format:

 - enable “Legacy device support” under advanced options for the WLAN group as per <https://community.ubnt.com/t5/UniFi-Wireless/Unifi-Wireless-not-working-with-Belkin-Wemo-switches/td-p/1719323> (I later disabled this after the WeMo app was working OK)
 - in the new wireless network, select “legacy” option under 2G Data Rate Control
 - factory reset all WeMo devices and join to new network
 - wait for the devices to appear in the WeMo app, then re-create schedules using WeMo app

**Powerline**

My old setup had the Powerline adapter plugged in to my router which is now serving only as my modem - and is located in a different room than the Ubiquiti equipment. For the Powerline to be seen by the new network (192.168.1.x), I had to plug it in to the switch.

[1]: https://www.troyhunt.com/ubiquiti-all-the-things-how-i-finally-fixed-my-dodgy-wifi/
[2]: https://scotthelme.co.uk/my-ubiquiti-home-network/
[3]: http://www.citytechnology.com.au/store/index.php?route=product/search&filter_name=unifi
