---
layout: post
title:  "My home network (2016)"
date:   2017-02-12 17:40:00 +1000
categories:
---
As the resident family IT "geek", I'm responsible for balancing cost, security, speed, and availability, and coming up with a great home network.

This post is a quick overview of a) my gear and b) my problems, as at 2016. I plan on making changes to my home network (soon) and will try to document those here too.

Back to my network. Like most modern families, we have a ton of wireless devices in the house - tablets, phones, video game consoles, laptops, IoT-connected devices - and on top of having the network "just work", my needs are fairly modest: secure, some sort of filtering, control over internet hours for the kids, simple to set up and maintain (sometimes my wife and kids, less tech-savvy, need to troubleshoot too).

As a bonus, I'd also like to have enough visibility to answer the recurrent question “Dad, why is the internet so slow!”, but over the years I haven’t exactly been blown away by the UI for networking gear; generally they’re pretty basic and reporting is limited or non-existent.

My gear:

- **cable modem:** whatever came from my ISP Optus, I believe it's <http://www.netgear.com/support/product/CG3000-2STAUS.aspx>. I've switched off the wi-fi, and only use the modem for DHCP - pretty reliable.
- **router 1:** a refurbished Apple Airport Extreme <http://www.apple.com/au/shop/product/FE918X/A/refurbished-airport-extreme> circa 2013. Simple interface, has speedy 802.11ac and a connected 3GB hard drive for centralised Time Machine backups
- **router 2:** KoalaSafe <https://koalasafe.com/>, a brilliant device which allows me to filter internet for the kids, separate to internet for the parents. We're training the kids to use the internet as a tool, responsibly, and this is one way to get rid of distractions during homework time (I'd also recommend a good "internet contract", such as <https://lifehacker.com/have-your-kids-sign-an-internet-contract-1523167118> or <http://www.safekids.com/teen-pledge-for-being-smart-online/>)
- **other:** ethernet over power (AKA "powerline") Netgear XAV1004 <https://www.netgear.com/support/product/XAV1004.aspx>, I don't have many wired devices, the only powerline adapter I use is an older 200Mbps which (some of the time) trumps wi-fi speed

<img alt="My home network (2016)" height="421" src="/images/my-home-network-2016.png" width="466">

The main problems with my gear are:

1. **coverage:** the signal from the wireless routers don't reach all ends of the house
2. **troubleshooting slowness:** it's not possible to tell if a problem is my gear above, or with the ISP, or just a particular web site - so the gear gets blamed :-)
3. **prioritising devices and a "kill switch":** I'd like to be able to prioritise a device or devices, particularly while waiting for buffering during a movie (grrr)
4. **reporting:** KoalaSafe has great reports, I'd love to see more for all my devices, including IoT devices
5. **difficulty managing IoT devices:** I have no idea of the incoming & outgoing traffic for most of my IoT devices. Some of these haven't been patched since the discovery of fire. I'd like to be able to categorise whether these devices even need to connect to the internet
6. **old devices:** not so much a problem with the network, but I need to keep a 2.4GHz network around for devices that don't support 5GHz
