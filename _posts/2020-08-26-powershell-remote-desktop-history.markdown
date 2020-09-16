---
layout: post
title:  "PowerShell remote desktop history script"
date:   2020-08-26 17:00:00 +1000
categories: powershell
---
One of the scripts I reach for a couple of times a month is `remote-desktop-history.ps1`, which returns remote desktop history from a Windows event log on a remote computer.

I've built and improved the script over the years to:

- accept one or more computers from the command line, or prompt if none were passed
- look up Active Directory for display names to match Windows logins in the event log
- display a progress bar when reading from the event log
- include a description of the event e.g. logon, logoff, disconnect

The script is useful to troubleshoot who may have been accessing the computer, for instance to perform maintenance. Where possible in my day-to-day role as DBA I try and avoid remote desktop (instead using management tools from another computer, like SQL Server Management Studio, Computer manager, Service manager etc.). I originally adapted the script from a Stack Overflow answer at <https://serverfault.com/a/687079/78216>.

The full `remote-desktop-history.ps1` PowerShell script can be found as a GitHub Gist at <https://gist.github.com/thomasswilliams/473f02c52e7036e84486dd8515dff7d0>.

<div markdown="1" class="note">
**Thomas's "but it worked for me" disclaimer:** before using any code you find on the internet, especially on this blog, take time to understand what the code does and test, test, test. I'm not responsible for damage caused by code from this blog, and don't offer any support or warranty.
</div>
<br/>