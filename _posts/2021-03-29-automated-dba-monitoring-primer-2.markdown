---
layout: post
title:  "Automated DBA monitoring for SQL Server: a primer, part 2"
date:   2021-03-29 17:00:00 +1100
categories: sqlserver
---
Monitoring is here to stay. There's never enough disk space, memory, CPU, network throughput. If they ever _existed_, perfect conditions don't _persist_, whether because of a downstream system failing, newly-discovered security issue, change in process, extraordinary amount of load etc. And, systems grow and change to meet new requirements, so yesterday's monitoring may not meet tomorrow's uptime goals.

Following on from [part 1]({% post_url 2021-03-21-automated-dba-monitoring-primer-1 %}), here are some further "big picture" considerations for automated monitoring for the DBA:

- **Impact of monitoring**
<br/>Like on Schrödinger's cat, monitoring has an impact. I can recall over-enthusiastic monitoring which _caused_ issues. Need to "monitor the monitor" - perhaps allowing for it to be disabled or dialled back if needed.

- **Analysis and reporting**
<br/>Collected monitoring data is a rich source of information for the DBA. The analysis could be as simple as running a query, or an Excel pivot table, or Reporting Services, or other reporting tools. There may be more than one audience for collected data too - I'm thinking of Windows admins, or management.

- **Alerts**
<br/>Fast-forwarding to when the automated monitoring data is being collected regularly...now, I can use it to send timely alerts, depending on the issue. An alert is a timely notification - it might be an e-mail, SMS, or dashboard item. For instance, if I have a problem with a system creating [local backups during business hours]({% post_url 2020-08-07-dba-email-business-hours-backup %}), impacting users? A SQL Agent alert could detect and e-mail the DBA. What about multi-day, sustained abnormal growth of a database? Maybe a once-a-week report is the best way to review. Or for a third-party vendor who logs in out of hours to carry out unplanned changes - or a vendor who doesn't log in when they said they would? Both can be addressed by monitoring, perhaps an e-mailed report at the end of the week that's CC'd to the vendor and relevant contacts.

- **Who alerts should go to**, which goes hand-in-hand with **what information to include in an alert**
<br/>A goal of alerts from automated monitoring should be triggering action to fix (while avoiding e-mail or dashboard overload). Alerts benefit from specific instructions to support staff to fix the issue or escalate. Over time, automated monitoring may evolve into an automated fix - for instance a Windows service restart or killing a [long-running SQL Agent job]({% post_url 2020-09-03-long-running-sql-agent-jobs %}) or blocking process.

- **What is most impactful to monitor**
<br/>Monitoring is like Maslow's hierarchy - once you're monitoring and addressing basic things to keep systems up and running, you can focus on problems specific to your environment and situation. I suggest starting with the basics, though. It's worth looking at what other monitoring Windows or network admins are doing so you don't double up.

- **Continuous improvement**
<br/>It's possible to be monitoring a _symptom_, rather than _cause_, of an issue, which should lead to a change in monitoring. I've also found that particular metrics may no longer be required or valid. Maybe the issue was fixed in a later version of SQL Server or Windows (for instance, the legacy need to allocate disk block sizes for SQL Server 2000).

In part 3, I'll suggest a couple of metrics to monitor, how often to collect, and how long to keep the data.
