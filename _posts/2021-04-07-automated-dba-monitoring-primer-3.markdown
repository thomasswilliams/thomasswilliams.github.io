---
layout: post
title:  "Automated DBA monitoring for SQL Server: a primer, part 3"
date:   2021-04-07 17:00:00 +1000
categories: sqlserver
---
This is the third in a series of posts on the "big picture" of automated DBA monitoring. [Part 1]({% post_url 2021-03-21-automated-dba-monitoring-primer-1 %}) started by describing general considerations for monitoring. [Part 2]({% post_url 2021-03-29-automated-dba-monitoring-primer-2 %}) added alerting. 

With some of the broader ideas out of the way, if there's no monitoring in place and I was the "accidental"/"default" DBA, there are some metrics I'd definitely want to monitor. However, there's a ton of real-time metrics I **haven't** included below like CPU & memory use, number of current connections, disk I/O as at _right now_. They're probably not good candidates for "roll-your-own"-type monitoring.

I consider "alerts" in the table below to include an e-mail, SMS or dashboard item that aims to trigger a response to fix. The collection frequency especially is just a guide - closer to real-time might be desirable, but the trade-off is impact on servers and connected apps. 

| Metric | Description | Alert? | Collection frequency | Review daily, weekly, monthly |
| --- | --- | --- | --- | --- |
| **Data & log file sizes** | Size of database data & log files | | Daily | When needed e.g. capacity planning
| **Server disk free space** | Free space on drives - although could be covered by other monitoring tools, may be beneficial to monitor for visibility to DBA | Less than 5GB free | Daily |
| **Backups** | Size of backups, duration of backups (useful if standardising backus across fleet e.g. Ola Hallengren) | Failed backups, backups created in business hours | Daily
| **New databases created** | New databases created, need to be added to inventory (non-production new databases can be helpful indicator of what's coming in production) | | Daily | Weekly
| **Number of databases per server** | From inventory, helpful for capacity planning | | Daily | Monthly or less often
| **Server properties** | For example: CPU, memory, authentication mode setting, login auditing setting, SP or CU level, Windows Firewall etc. | | Weekly, maybe just monitor for changes compared to last week
| **SQL Agent job history** | Number of runs, duration for each run, runs that exceed average duration | | Weekly | Review exceptions weekly
| **Errors in SQL Server error log** | SQL Server error log is fairly verbose, with everything from status messages to critical errors. Over time I'll develop filters to screen out unimportant messages - I suggest de-duplicating same messages in the same minute, and limiting to 10,000 (or some other sensible number) of messages per collection | | Weekly | Review errors weekly
| **Windows error log** | Critical and error messages, helpful to know what's happening on the server _outside_ SQL Server | | Weekly | Review errors weekly
| **SQL Server Windows services** | Status (running, stopped), autostart setting, whether enabled; useful for checking service restart successfully after overnight patching | Service stopped | Daily 
| **SQL Server service restarts** | This one's pretty self-explanatory :-) | Notification when SQL Server service restarts
| **Index fragmentation** | Might be best just to schedule [Ola Hallengren's IndexOptimize weekly](https://ola.hallengren.com/sql-server-index-and-statistics-maintenance.html) 
| **Unused indexes**, **missing indexes** | We're getting down past the server and database level, to table and view level - I'll need to know a bit more about the database and how it works to best work with indexes, as far as I know there's no "one size fits all" approach
| **Blocking processes** | Processes running for longer than _x_ minutes, that are blocking more than a threshold of _y_ other processes | Maybe, depending on the server and database | Could collect and report using sp_WhoIsActive <http://whoisactive.com>

Ideally, monitoring is linked to an inventory of servers and databases; that's a topic for another blog post, though.