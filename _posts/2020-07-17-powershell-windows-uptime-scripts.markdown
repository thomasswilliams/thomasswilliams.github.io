---
layout: post
title:  "PowerShell scripts for Windows uptime"
date:   2020-07-17 12:00:00 +1000
categories: powershell
---
There's lots of ways to find computer uptime or last restart time.

I wrote a couple of PowerShell scripts that I use at least monthly to do this, for example when an overnight process fails - the uptime script will quickly show whether a computer involved restarted. Another use is to monitor restarts as part of Windows patching.

Links to the PowerShell scripts are below. I run them on Windows so can't vouch for other OSs. Both scripts have optional debug statements to provide extra info and accept user input from a prompt; both have been tested on Windows 10 and PowerShell 5 & 7 (including latest PowerShell 7 preview as at July 2020).

<div markdown="1" class="note">
**Thomas's "but it worked for me" disclaimer:** before using any code you find on the internet, especially on this blog, take time to understand what the code does and test, test, test. I'm not responsible for damage caused by code from this blog, and don't offer any support or warranty.
</div>
<br/>

- `server-uptime.ps1` <https://gist.github.com/thomasswilliams/3fe524054718f346138e4c0598e89077> - For a passed computer, collection of computers, or computer name(s) from prompt, return the boot time and calculated uptime in days, hours and minutes.
- `startup-shutdown-history.ps1` <https://gist.github.com/thomasswilliams/fd09d1698d00a077a983851382a6c42d> - Get history from Windows event log for events relating to startup & shutdown for a specified computer or computers. Adapted from <https://social.technet.microsoft.com/wiki/contents/articles/17889.powershell-script-for-shutdownreboot-events-tracker.aspx>

Feel free to adapt and build on the scripts, I hope they help when quickly answering questions during troubleshooting.
