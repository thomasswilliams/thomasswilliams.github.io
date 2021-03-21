---
layout: post
title:  "Automated DBA monitoring for SQL Server: a primer, part 1"
date:   2021-03-21 13:00:00 +1100
categories: sqlserver
---
Automated monitoring is a "secret weapon” which calls for help when something's wrong, stores data to help make decisions, and gives confidence that past known issues are being handled to help me as a DBA sleep better at night.

It would be nice if every problem, now and in the future, was automatically monitored by an intuitive, cheap, flexible tool that only raised the alarm when there was a real problem, at the right time, to the right people.

However, in reality, monitoring is a game of whack-a-mole, built on an ad-hoc collection of tools and technologies, requiring know-how to interpret the often puzzling situations which may be high priority - or just background noise.

As a DBA who's accountable for the success (or otherwise) of database servers, I'm a fan of creating my own automated monitoring when needed. I've never found an off-the-shelf monitoring product that did everything (at least in my experience with SolarWinds, WhatsUp Gold, SCOM and others). Plus, some problems are probably unique to my environment - maybe even of my own making.

Starting with the "big picture" level, some questions to ask of any automated DBA monitoring, or when thinking of my own, are:

- **What to monitor**
<br/>Disk free space, errors in logs, index usage, tempdb contention, new database creation, objects created in the master system database, lack of corruption checks, unexpected DBCC SHRINKFILEs taking place; the list goes on, these are just a selection of metrics that come to mind. Servers, networks, database, operating system and applications - what data can I reliably collect, that scales to the number of servers I need to monitor? And like a doctor often records height and weight, I may need to collect "context" metrics like number of processors, number of tempdb files, number of databases etc. to monitor if anything changes over time, as well as allowing comparison between servers.

- **How often to collect data**
<br/>Every minute, day, week, month etc. There may be more than one use for the data - for instance, if not to identify an immediate issue, then to use the data as a "normal operation" baseline.

- **How long to store collected data for**
<br/>Summarising data may mean detailed records can be deleted, saving space. When first implementing monitoring, I try and pay attention to how long I might retain the data. One week is about right for [sp_WhoIsActive data]({% post_url 2020-12-01-spwhoisactive %}), and 2 years is probably more than enough for things like database file sizes to provide an idea of growth trends.

- **When to start collecting**
<br/>I find it's good to collect data if possible when I first encounter an issue, before I've analysed and attempted to solve it. An example is query cache issues on a busy server (which did not occur on other servers). That way, after a fix is applied, comparing newly-collected data with the older data will confirm that the problem is being addressed.

- **Where to collect from**
<br/>I try to collect from both production and non-production servers. A question I've faced is how much time should be invested in monitoring to allow for differences in functionality of versions of SQL Server. Also worth considering - what data to collect from third-party servers where I may have limited access or reduced support expectations, or cloud servers where the operating system level may be of less relevance than locally-hosted servers.

- **Where to store**
<br/>I'm a DBA, so I'm gonna store collected data in a database.

- **How to run**
<br/>I've previously used scripts ([PowerShell]({{site.baseurl}}/categories/#powershell), VBScript), SSIS packages, SQL Agent jobs, Windows scheduled tasks, existing monitoring tools, and a combination of all the above.

In part 2 I'll continue the list, moving on to alerts and analysis possibilities that automated monitoring opens up.
