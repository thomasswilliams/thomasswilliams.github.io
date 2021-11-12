---
layout: post
title:  "Server archaeology"
date:   2021-11-12 12:00:00 +1100
categories: general
---
I recently wrote about [setting up a new server the way you want]({% post_url 2021-04-26-commissioning-a-sql-server %}). At the other end of the scale, sometimes the issue is understanding existing servers (or PCs), figuring out what's installed and how it relates to databases and other software.

Part of learning about [my new job]({% post_url 2021-02-07-hello-ccamlr %}) involved "digging around" servers and documenting what I found. My background is more in databases and development than system administration, so I more than likely missed some obvious tools and shortcuts, but I ended up building passable documentation using the steps below.

It's important during this process to use a login with appropriate permissions and not to make any changes, just observe:

- installed software - name, version and last updated (e.g. using Control Panel or something like [NirSoft UninstallView freeware](https://www.nirsoft.net/utils/uninstall_view.html)
- if IIS/Apache is installed: web sites, directories, logs
  - which site gets the heaviest traffic? Which is used most recently?
- Windows services (apart from standard), startup type, whether they're running
  - path to executable and command line options
- Windows scheduled tasks
  - any disabled tasks, or recently failed tasks?
- local users and groups (apart from standard)
  - who is an admin, power users/remote desktop users groups
- "interesting" directories (this is somewhat subjective!) such as directories in _Program Files_
  - log files - how many, how far do they date back, how big, how they (if they) are regularly cleaned up
  - configuration files - interesting connections or settings
- open ports using `netstat -ano`, match process ID to Task Manager
- if a firewall is in use, firewall settings out of the ordinary
- ODBC system DSNs, 32- and 64-bit
- SQL aliases (rarely used in my experience), see <https://www.mssqltips.com/sqlservertip/1620/how-to-setup-and-use-a-sql-server-alias/>
- HOSTS file entries
- if a database server: location of data files, is DTC enabled (Component Services)
- user profiles directory - profiles recently used, old profiles, total size
  - desktop icons can also indicate what software is used and different command line options
- shares (Computer Management), directory permissions
- open files (Computer Management), connected users
- programs run at startup e.g. can use [Autoruns](https://docs.microsoft.com/en-us/sysinternals/downloads/autoruns)
- Remote Desktop history - I've got [a PowerShell script for that :-)]({% post_url 2020-08-26-powershell-remote-desktop-history %})
- reboot/shutdown history (could be scripted from Event Log)
  - is the computer restarted often? Was it restarted recently?
- Windows Updates pending
- antivirus exceptions
  - processes, directories
- Windows Registry (don't expect too much in there though)
- recent Event Log errors
- Disk Management, anything out of the ordinary
- may be useful to run something like [TreeSize Free](https://www.jam-software.com/treesize_free) to see where disk space is used

Thankfully there's some things I can now skip in my checks, like disk cluster sizes (useful back in Windows Server 2003 days, before virtualisation) and the good old `VB and VBA Program Settings` registry key (see: pre-2000's VB5/VB6).

Using the steps above and a text editor - you never know what may be hidden in files with non-standard extensions - I built enough documentation to start asking the interesting questions, like: who uses the server and software? What plans are there for the future of the server and software? And, what are we doing about out-of-date Windows or software versions?

Good luck with your server archaeology!