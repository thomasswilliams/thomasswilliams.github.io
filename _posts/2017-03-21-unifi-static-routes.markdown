---
layout: post
title:  "Blocking domains using the 'Static Routes' feature of Unifi"
date:   2017-03-21 18:21:00 +1000
categories:
---
I recently upgraded my home network to [Ubiquiti Unifi]({% post_url 2017-03-03-home-network-unifi %}) and have been experimenting with the powerful built-in firewall.

While looking for info on using the firewall, I came across *smash102*’s reply to a forum post at <https://community.ubnt.com/t5/UniFi-Routing-Switching/UniFi-Controller-Routing-amp-Firewall-Beta-5-2-2/td-p/1647978> that shows how static routes could be used to block domains, by taking requests for an IP address and never forwarding that request. I investigated further, found references such as <https://en.wikipedia.org/wiki/Black_hole_(networking)>, and wanted to better document this method here in case someone else finds it useful.

*Why would I do this? Static routes are used to go direct to another network or host, for example, virtual private networks. They can be used for an IP range, or a single IP address; they can’t be used for individual pages on a web site; they apply to any client using the network. There would be some overhead in maintaining the list of IP addresses if and as they change. However, for a simple experiment, this is acceptable to me - but your mileage may vary.*

<div markdown="1" class="note">
**Thomas's "but it worked for me" disclaimer:** before using any code you find on the internet, especially on this blog, take time to understand what the code does and test, test, test. I'm not responsible for damage caused by code from this blog, and don't offer any support or warranty.
</div>
<br/>
Using Unifi controller’s static routes to block a domain, with controller build `atag_5.4.11_9184`:

1. find the IP addresses (most likely more than one) of the domain to block - must be IP addresses, not the domain name or URL
    - for instance, using tools from a site like Site24x7
    - for this example I'll block my blog (and probably other Github domains), so I launch <https://www.site24x7.com/find-ip-address-of-web-site.html> in my browser, and paste the domain name ```thomasswilliams.github.io``` (no protocol or trailing slashes)
    - take note of the IP addresses in the returned "IP Address" column
![Site24x7 Find IP address](/images/site24x7-find-ip-addresses.png)
2. launch the Unifi controller, then go to "Settings", "Routing & Firewall", and click "Create New Route"
3. enter a unique name for the route on the "Create New Route" screen, for instance, "Block Github 1"
4. for "Network", enter an IP address from step 1, then slash, then 32
    - this translates to "the route applies to this IP address only" using CIDR notation, kind of like a bit mask or flag for the IP address
5. for "Distance", enter 1; this sets the priority (lower number meaning higher priority)
6. select "Static Route Type" of "Black Hole"
7. click save
8. repeat for each IP address in step 1
![Unifi controller 'Create New Route'](/images/unifi-controller-create-new-route.png)

No restart is required after saving the new route, however browsers may cache pages so I didn't see the block immediately.

In fact, I had to locate some other IP addresses as it seems the IP address recorded by Site24x7 can be different than the one I actually use thanks to geo-location or CDNs. I found the additional IP addresses using Chrome’s dev tools, and repeated steps 2-7 above.

If all goes well, browsing to a blocked domain will result in a browser error (not a HTTP error; it's as if the site doesn't exist). As mentioned earlier, this is not the best or only way to block domains, but it's an option with associated pros and cons.

But before you go - remember to unblock my blog :-)
