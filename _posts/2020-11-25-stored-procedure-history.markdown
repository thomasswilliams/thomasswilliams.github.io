---
layout: post
title:  "Notes to self: Attempting to reliably find SQL Server stored procedure usage history"
date:   2020-11-25 12:00:00 +1000
categories: sqlserver
---
From time to time I've needed a way to identify which stored procedures in a database are in use, and which ones aren't.

Here's some of the reasons I've come across that make it difficult to reliably find out using the in-built dynamic management views, as at SQL Server 2016:

- numbers between `dm_exec_procedure_stats` ([official docs][1]) and `dm_exec_cached_plans` ([official docs][2]) sometimes don't match
- memory pressure may affect the plan cache, see excellent StackExchange answer at <https://dba.stackexchange.com/a/182243>
- the plan cache doesn't survive SQL Server restarts
- the plan cache may be cleared using `DBBC FREEPROCCACHE` or other operations, see <https://docs.microsoft.com/en-us/sql/t-sql/database-console-commands/dbcc-freeproccache-transact-sql>
- using in-built Query Store feature (which is great, BTW) can impact the plan cache, depending on your SQL Server version and patch level
- the "optimize for ad-hoc workloads" setting can also apparently impact the plan cache

A better outcome, if you don't want to deal with the issues above and you have control over the stored procedures, might be to log stored procedure executions yourself in a table, perhaps using the name of the current stored procedure (`OBJECT_NAME(@@PROCID)`) and user (`SUSER_SNAME()`). Another option is logging a regular snapshot of activity, for instance using the excellent "sp_whoisactive" <http://whoisactive.com/> (although be aware you may miss stored procedures if they're not running at the time of your snapshot).

Below is a script I've put together from various sources that's not perfect, but may be useful as a starting point. You'll need to replace `DATABASENAME` with the actual database name. The script uses both `dm_exec_procedure_stats` and `dm_exec_cached_plans`, so you'll need appropriate permission to run these DMVs.

<div markdown="1" class="note">
**Thomas's "but it worked for me" disclaimer:** before using any code you find on the internet, especially on this blog, take time to understand what the code does and test, test, test. I'm not responsible for damage caused by code from this blog, and don't offer any support or warranty.
</div>
<br/>

```sql
USE [master]
GO

;WITH FROM_EXEC_PROCEDURE_STATS AS (
 --get execution count and date & time stored in cache
 --adapted from https://dba.stackexchange.com/a/30113
 --and https://www.sqlservergeeks.com/sys-dm_exec_procedure_stats/
 SELECT  [Stored procedure] = OBJECT_NAME([object_id], [database_id]),
         [Number of times executed] = [execution_count],
         [Cached time] = [cached_time]
 FROM    [DATABASENAME].sys.dm_exec_procedure_stats
 WHERE   --stored procedures only
         [type] = 'P' AND
         --limit to database
         DB_NAME([database_id]) = N'DATABASENAME'
), FROM_EXEC_CACHED_PLANS AS (
 --from plan cache
 SELECT  --stored procedure full name (schema & object name)
         [Stored procedure] = OBJECT_NAME(st.[objectid], [dbid]),
         [Number of times executed] = MAX(cp.[usecounts])
 FROM    sys.dm_exec_cached_plans cp CROSS APPLY
             sys.dm_exec_sql_text(cp.[plan_handle]) st
 WHERE   --stored procedures only
         cp.[objtype] = 'proc' AND
         --limit to database
         DB_NAME(st.[dbid]) = N'DATABASENAME'
 GROUP BY
         cp.[plan_handle], OBJECT_NAME(st.[objectid], st.[dbid])
)
SELECT  PROC_CACHE.[Stored procedure],
        [Procedure cache number of times executed] = MAX(PROC_CACHE.[Number of times executed]),
        [Procedure cache last cached time] = MAX(PROC_CACHE.[Cached time]),
        [Plan cache number of times executed] = MAX(PLAN_CACHE.[Number of times executed])
FROM    FROM_EXEC_PROCEDURE_STATS PROC_CACHE LEFT JOIN
            FROM_EXEC_CACHED_PLANS PLAN_CACHE ON
                PROC_CACHE.[Stored procedure] = PLAN_CACHE.[Stored procedure]
GROUP BY PROC_CACHE.[Stored procedure], PLAN_CACHE.[Stored procedure]
ORDER BY MAX(PROC_CACHE.[Number of times executed]) DESC
OPTION (RECOMPILE)
```

[1]: <https://docs.microsoft.com/en-us/sql/relational-databases/system-dynamic-management-views/sys-dm-exec-procedure-stats-transact-sql>
[2]: <https://docs.microsoft.com/en-us/sql/relational-databases/system-dynamic-management-views/sys-dm-exec-cached-plans-transact-sql>
