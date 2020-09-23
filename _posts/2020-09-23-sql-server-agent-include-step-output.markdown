---
layout: post
title:  "SQL Server Agent 'Include step output in history' and msdb system database size"
date:   2020-09-23 17:00:00 +1000
categories: sqlserver
---
I recently ran into a problem where the `msdb` system database on a SQL Server instance grew by 2GB over a couple of days.

**TL;DR** I was eventually able to fix my large `msdb` system database, which had grown due to logging of a job step of a SQL Agent job that ran every couple of minutes, by running a query (below) and then deleting job step logs from the `sysjobstepslogs` table using system stored procedure [`sp_delete_jobsteplog`][3].

But first, a bit of background...

The `msdb` system database stores a bunch of stuff, especially related to SQL Agent jobs. Looking for reasons that the 'msdb' system database had grown, I ran the in-built "Disk Usage by Top Tables" report in SSMS and noticed one table - `sysjobstepslogs` - was taking up nearly 2.5GB, with less than 20 records.

[Offical documentation][1] says the `sysjobstepslogs` table *"...contains the job step log for all SQL Server Agent job steps that are configured to write job step output to a table..."*, that is, have all of "Log to table", "Append output to existing entry in table" and "Include step output in history" (Job Step properties, Advanced tab) checked in an SQL Agent job step:

<img alt="SQL Agent job step properties" height="437" src="/images/sql-agent-job-step-properties.png" width="500">

A short internet search turned up others who'd had (and solved) the same problem: most usefully, a forum post at <https://www.sqlservercentral.com/forums/topic/msdb-sysjobstepslogs-table-is-huge/#post-1672746> which pointed to using system stored procedures [`sp_help_jobsteplog`][2] and [`sp_delete_jobsteplog`][3] to diagnose and fix.

The only hurdle prior to using the system stored procedures referenced in the forum post, was to find *which* SQL Agent job step log was taking up space.

(At this point I'd strongly advise __not__ to run `SELECT *` on table `sysjobstepslogs` as there's an `NVARCHAR(MAX)` column called `log`, which will take a long time to return if you have the same problem I did; the `log` column contains concatenated text output for the job step over multiple runs.)

I ended up assembling the query below from various internet sources to return SQL Agent jobs and job step log size from the `sysjobstepslogs` table. The query also generates a SQL statement to run to fix the problem using system stored procedure `sp_delete_jobsteplog` with the correct job and job step name.

<div markdown="1" class="note">
**Thomas's "but it worked for me" disclaimer:** before using any code you find on the internet, especially on this blog, take time to understand what the code does and test, test, test. I'm not responsible for damage caused by code from this blog, and don't offer any support or warranty.
</div>
<br/>

```sql
/* query to find SQL Agent jobs that are using a large amount of space in job step log table "sysjobstepslogs"
   tested on SQL Server 2016 (but will most likely work on 2012+) */
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

SELECT  /* SQL Agent job name */
		[job_name] = J.[name],
		/* SQL Agent job step identifier and name */
		S.[step_id], S.[step_name],
		/* "Size of the job step log in bytes" - rough conversion to MB */
		[log_size (MB)] = L.[log_size]/1024/1024,
		/* generate script which can be run to remove job step log */
		[clean up script] = 'EXEC msdb..sp_delete_jobsteplog @job_name = N''' + J.[name] + ''', @step_name = N''' + S.[step_name] + ''';'
FROM    msdb..sysjobs J INNER JOIN
		    msdb..sysjobsteps S ON
			    J.[job_id] = S.[job_id] INNER JOIN
			msdb..sysjobstepslogs L ON
				S.[step_uid] = L.[step_uid]
WHERE   /* job step log greater than 50MB - remove to see all */
		L.[log_size]/1024/1024 > 50
ORDER BY L.[log_size] DESC
```

In my case, running the query above identified that I'd recently checked "Include step output in history" for a SQL Agent job step that ran every couple of minutes. This logging had directly caused the `msdb` system database to grow.

I decided I didn't need 2GB worth of logs for that one SQL Agent job.

First I disabled the SQL Agent job, then removed the job step log using the generated script to call system stored procedure `sp_delete_jobsteplog` (which took a couple of minutes to run, your mileage may vary), then I un-checked "Include step output in history" in the offending SQL Agent job step, and finally shrank the 'msdb' system database and re-enabled the SQL Agent job.

[1]: <https://docs.microsoft.com/en-us/sql/relational-databases/system-tables/dbo-sysjobstepslogs-transact-sql>
[2]: <https://docs.microsoft.com/en-us/sql/relational-databases/system-stored-procedures/sp-help-jobsteplog-transact-sql>
[3]: <https://docs.microsoft.com/en-us/sql/relational-databases/system-stored-procedures/sp-delete-jobsteplog-transact-sql>
