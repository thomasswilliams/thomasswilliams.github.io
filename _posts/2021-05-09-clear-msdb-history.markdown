---
layout: post
title:  "Clear msdb system database history"
date:   2021-05-09 12:00:00 +1000
categories: sqlserver
---
I've inherited SQL Servers that have never had history in the `msdb` system database cleared. This means a) operations using the `msdb` system database - [logging of SQL Agent jobs]({% post_url 2020-09-23-sql-server-agent-include-step-output %}), for instance - may take more time and b) the `msdb` system database is bigger than it needs to be.

Below is a script I cobbled together from other excellent sources, that deletes history from the `msdb` system database one day at a time from the earliest date, to a pre-defined `@end_date` (I've set to 100 days ago). Deletion is done using system stored procedures:

- [sp_delete_backuphistory](https://docs.microsoft.com/en-us/sql/relational-databases/system-stored-procedures/sp-delete-backuphistory-transact-sql): _"Reduces the size of the backup and restore history tables by deleting the entries for backup sets older than the specified date."_
- sp_maintplan_delete_log: Undocumented
- [sp_purge_jobhistory](https://docs.microsoft.com/en-us/sql/relational-databases/system-stored-procedures/sp-purge-jobhistory-transact-sql): _"Removes the history records for a job."_
- [sysmail_delete_mailitems_sp](https://docs.microsoft.com/en-us/sql/relational-databases/system-stored-procedures/sysmail-delete-mailitems-sp-transact-sql): _"Permanently deletes e-mail messages from the Database Mail internal tables."_
- [sysmail_delete_log_sp](https://docs.microsoft.com/en-us/sql/relational-databases/system-stored-procedures/sysmail-delete-log-sp-transact-sql): _"Deletes events from the Database Mail log."_

Deleting one day at a time is slower than deleting all history at once. It's likely the `msdb` system database log file will grow after running the script (but the log file can be shrunk following). I'd advise testing the script in non-production first, and then running it at a time of low server usage if possible.

Another way to reduce the impact is change the `@end_date`, for example set it to 200 days ago and gradually up it by 10 days at a time.

<div markdown="1" class="note">
**Thomas's "but it worked for me" disclaimer:** before using any code you find on the internet, especially on this blog, take time to understand what the code does and test, test, test. I'm not responsible for damage caused by code from this blog, and don't offer any support or warranty.
</div>
<br/>

````sql
USE [master]

--clear backup history, maintenance plan history, SQL Agent job history and Database Mail history one day at a time
--from the msdb system database by calling system stored procedures in the msdb system database
--this script can be used when clearing has not yet been done (as at SQL Server 2016, by default, no automated clearing is set up on new servers)
--why do this one day at a time? Clearing years' worth of history at once will possibly impact performance including running SQL Agent jobs
--after running this script, a SQL Agent job should be created & scheduled to clear regularly (suggest weekly), only keeping the last 30 days
--you may also want to check msdb system database data and log file sizes and free space following running this script
--adapted from https://sqlnotesfromtheunderground.wordpress.com/2014/08/26/purge-msdb-backup-history-in-chunks/
--will need high level permission to run this script (sysadmin) as per https://docs.microsoft.com/en-us/sql/relational-databases/system-stored-procedures/sp-purge-jobhistory-transact-sql
--tested on SQL Server 2016

--earliest date in backup or maintenance plan history tables
--start with backup history table
DECLARE @start_date DATE = (SELECT CONVERT(DATE, MIN([backup_start_date])) FROM msdb..[backupset] (READPAST))
--check maintenence plan history table - if older than backup history, set start date to new earliest date
--possibly maintenance plans are not in use on the server, in which case will keep original earliest date from backup history table
IF @start_date IS NULL OR (SELECT CONVERT(DATE, MIN([start_time])) FROM msdb..[sysmaintplan_logdetail] (READPAST)) < @start_date BEGIN
    SELECT @start_date = CONVERT(DATE, MIN([start_time])) FROM msdb..[sysmaintplan_logdetail] (READPAST)
END
--check database mail history - if older, set start date to this date
IF @start_date IS NULL OR (SELECT CONVERT(DATE, MIN([log_date])) FROM msdb..[sysmail_event_log] (READPAST)) < @start_date BEGIN
    SELECT @start_date = CONVERT(DATE, MIN([log_date])) FROM msdb..[sysmail_event_log] (READPAST)
END
--could also check SQL Agent job history - not done here, as by default limited to 1,000 records (so probably not as much history as default backup history)

--date to delete to
--should start by setting close to start date (to delete less records)
--for this sample script, setting to 100 days ago USE WITH CAUTION
--this should eventually be set to 30 and run regularly
DECLARE @end_date DATE = (SELECT CONVERT(DATE, DATEADD(DAY, -100, GETDATE())))

--sanity check: do we have a start date? And is the start date earlier than the end date? If not, nothing to delete
IF @start_date IS NULL BEGIN
    PRINT 'No data to delete'
END ELSE IF @start_date > @end_date BEGIN
    PRINT 'No data to delete - oldest data is newer than the date to delete to'
END ELSE BEGIN
    PRINT 'Looping until ' + CONVERT(VARCHAR(25), @end_date, 113) + ' (' + CONVERT(VARCHAR(25), DATEDIFF(DAY, @start_date, @end_date)) + ' days)'

    --delete in single days, starting from the start date, until the end date
    WHILE (@start_date <= @end_date) BEGIN
        PRINT 'About to delete to ' + CONVERT(VARCHAR(25), @start_date, 113) + '...'
        --delete backup history
        EXEC msdb..sp_delete_backuphistory @start_date
        --delete maintenance plan history as per http://www.sqldbadiaries.com/2011/03/16/clean-up-maintenance-plan-history/
        EXEC msdb..sp_maintplan_delete_log NULL, NULL, @start_date
        --delete SQL Agent history as per https://docs.microsoft.com/en-us/sql/ssms/agent/clear-the-job-history-log
        EXEC msdb..sp_purge_jobhistory NULL, NULL, @start_date
        --delete database mail history as per https://www.madeiradata.com/post/keep-your-msdb-clean
        EXEC msdb..sysmail_delete_mailitems_sp @sent_before = @start_date
        EXEC msdb..sysmail_delete_log_sp @logged_before = @start_date
        --increment the start date by 1 day
        SET @start_date = DATEADD(DAY, 1, @start_date)
    END
END
````