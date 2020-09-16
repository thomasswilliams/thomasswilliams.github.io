---
layout: post
title:  "Notes to self: e-mailing a DBA on long-running SQL Agent jobs"
date:   2020-09-03 17:00:00 +1000
categories: sqlserver
---
SQL Agent is like Windows Task Scheduler inside SQL Server. From time to time, SQL Agent jobs run longer than expected and may need intervention to cancel or complete.

I adapted the SQL script below from the excellent Thomas LaRock original at <http://thomaslarock.com/2014/08/find-currently-running-long-sql-agent-jobs/>. I'm posting it here in the hope it might be useful for others who have similar issues monitoring SQL Server.

The script sends an e-mail if one or more SQL Agent jobs have been running longer than 30 minutes. It could be altered to suit different environments - for example, to ignore backup SQL Agent jobs, or to not send an e-mail outside of business hours, or to use a different threshold than 30 minutes.

Database Mail needs to be set up before sending the e-mail. Database Mail is a different way to send e-mails from SQL Server - a previous post of mine used PowerShell: see [E-mailing a DBA if there's SQL Server database backups run during business hours]({% post_url 2020-08-07-dba-email-business-hours-backup %}).

I prefer HTML format e-mail over plain text for tables - to display SQL Agent jobs and how long they've been running, as well as average duration.

The script should work with versions of SQL Server 2016 and later. You’ll need to substitute your own value for e-mail address (in the last line of the script). I schedule the script every 30 minutes during business hours.

The script can be tricky to test. I tested using a SQL Agent job containing a single step that does nothing for 40 minutes using `WAITFOR`.

<div markdown="1" class="note">
**Thomas's "but it worked for me" disclaimer:** before using any code you find on the internet, especially on this blog, take time to understand what the code does and test, test, test. I'm not responsible for damage caused by code from this blog, and don't offer any support or warranty.
</div>
<br/>

```sql
--get currently running SQL Agent jobs that have been running for longer than 30 minutes
--adapted from Thomas LaRock original at http://thomaslarock.com/2014/08/find-currently-running-long-sql-agent-jobs/
-- 1. get currently running jobs
-- 2. leave if no running jobs
-- 3. use msdb history to calculate average duration for running jobs for comparison
-- 4. get only running jobs, that started more than 30 minutes ago
-- 5. send e-mail if any results from step #4

SET NOCOUNT ON
SET CONCAT_NULL_YIELDS_NULL OFF

--e-mail subject, empty body
DECLARE @EmailSubject NVARCHAR(255) = N'** SQL Server long running jobs on ' + @@SERVERNAME + N' **',
        @EmailBody NVARCHAR(MAX)

--temp table for all jobs from msdb stored proc "xp_sqlagent_enum_jobs"
--user running this script needs permission to run stored proc
DECLARE @temp_xp_sqlagent_enum_jobs TABLE (
    [job_id] UNIQUEIDENTIFIER NOT NULL PRIMARY KEY, --job identifier, can be matched back to sysjobs
    [last_run_date] INT NOT NULL, --last run date in YYYYMMDD format
    [last_run_time] INT NOT NULL, --last run time in HMMSS format (24-hour time)
    [next_run_date] INT NOT NULL, --next run date or zero if not scheduled
    [next_run_time] INT NOT NULL, --next run time or zero if not scheduled
    [next_run_schedule_id] INT NOT NULL, --schedule identifier for next run or zero if not scheduled
    [requested_to_run] INT NOT NULL,
    [request_source] INT NOT NULL,
    [request_source_id] SYSNAME NULL,
    [running] INT NOT NULL, --1 if the job is executing
    [current_step] INT NOT NULL, --step number that is currently executing or zero
    [current_retry_attempt] INT NOT NULL, --retry attempt number
    [job_state] INT NOT NULL --from http://www.sqlnotes.info/2012/01/13/are-jobs-currently-running/#more-1194:
                             --0 = Not idle or suspended, 1 = Executing, 2 = Waiting For Thread, 3 = Between Retries, 4 = Idle, 5 = Suspended, [6 = WaitingForStepToFinish], 7 = PerformingCompletionActions
)

--get all jobs into temp table
INSERT INTO @temp_xp_sqlagent_enum_jobs
EXEC master..xp_sqlagent_enum_jobs 1, N''

--leave only running jobs in temp table
DELETE
FROM    @temp_xp_sqlagent_enum_jobs
WHERE   --not executing
        [job_state] != 1

--sanity check: do we have any running jobs? If not, exit
IF 0 = (SELECT COUNT(*) FROM @temp_xp_sqlagent_enum_jobs)
    RETURN

--format results as HTML table row, each column called "td"
--adapted from https://www.sqlservercentral.com/Forums/Topic1465444-279-1.aspx
--limit to where job has been running for more than 30 minutes
DECLARE @TableHtml NVARCHAR(MAX) = (
 --get currently running jobs, last started date and historical average
 SELECT  --job name
         [td] = j.[name],
         --last started from sysjobactivity for executing jobs (ignore non-executing jobs)
         [td] = CONVERT(VARCHAR(25), CONVERT(DATETIME, CASE
             WHEN MAX(CURRENTLY_RUNNING.[job_state]) = 1 THEN MAX(sja.[start_execution_date])
         END), 100),
         --current duration in minutes for executing jobs
         [td] = CONVERT(INT, CASE
             WHEN MAX(CURRENTLY_RUNNING.[job_state]) = 1 AND MAX(sja.[start_execution_date]) IS NOT NULL THEN DATEDIFF(MINUTE, MAX(sja.[start_execution_date]), GETDATE())
         END),
         --average for all executions from recent history
         [td] = MAX(AVERAGES.[avg_duration_in_mins])
 FROM    --from docs: "Stores the information for each scheduled job to be executed by SQL Server Agent."
         msdb..[sysjobs] j INNER JOIN
             @temp_xp_sqlagent_enum_jobs CURRENTLY_RUNNING ON
                 j.[job_id] = CURRENTLY_RUNNING.[job_id] INNER JOIN
             --get only latest start from activity table
             --have had cases of phantom, non-current record from job perhaps not terminated properly?
             --from docs: "Records current SQL Server Agent job activity and status."
             msdb..[sysjobactivity] sja ON
                 j.[job_id] = sja.[job_id] AND
                 --started
                 sja.[start_execution_date] IS NOT NULL AND
                 --latest started
                 sja.[start_execution_date] = (SELECT MAX([start_execution_date]) FROM msdb..[sysjobactivity] sja2 WHERE sja.[job_id] = sja2.[job_id]) AND
                 --not finished
                 sja.[stop_execution_date] IS NULL LEFT OUTER JOIN
             (
              --calculate average duration in minutes for jobs from history data
              SELECT  I.[job_id],
                      --average for all executions in minutes from recent history
                      [avg_duration_in_mins] = CONVERT(INT, AVG(I.[run_duration_in_secs])/60)
              FROM    (
                       --job history from msdb "sysjobhistory"
                       --this table only has recent history, determined by "Limit size of job history log" SQL Agent setting
                       SELECT  JH.[job_id],
                               --date executed as DATETIME
                               [date_executed] = msdb.dbo.agent_datetime(JH.[run_date], JH.[run_time]),
                               --convert elapsed time in HHMMSS format to seconds
                               --from https://thomaslarock.com/2014/08/find-currently-running-long-sql-agent-jobs/
                               [run_duration_in_secs] = (JH.[run_duration]/10000 * 3600) + (JH.[run_duration] % 10000/100 * 60) + (JH.[run_duration] % 100)
                       FROM    msdb..[sysjobhistory] JH INNER JOIN
                                   --currently running jobs
                                   @temp_xp_sqlagent_enum_jobs CURRENTLY_RUNNING ON
                                         JH.[job_id] = CURRENTLY_RUNNING.[job_id]
                       WHERE   --job outcome step
                               JH.[step_id] = 0 AND
                               --successful execution
                               JH.[run_status] = 1
                      ) I
              GROUP BY I.[job_id]
             ) AVERAGES ON
                 j.[job_id] = AVERAGES.[job_id]
 GROUP BY j.[job_id], j.[name]
 HAVING  --is running
         MAX(CURRENTLY_RUNNING.[job_state]) = 1 AND
         MAX(sja.[start_execution_date]) IS NOT NULL AND
         --has been running for longer than 30 minutes
         DATEDIFF(MINUTE, MAX(sja.[start_execution_date]), GETDATE()) > 30
 FOR     --wrap in HTML table row element
         XML RAW('tr'), ELEMENTS
)

--sanity check: did we get any jobs that have been running for longer than 30 minutes? If not, leave
IF @TableHtml IS NULL
    RETURN

--prepend table HTML element, table header row to table HTML
SET @TableHtml = N'<table><tr><th>Job</th><th>Started</th><th>Running for (minutes)</th><th>Average duration (minutes)</th></tr>' + @TableHtml + N'</table>'

--set e-mail body, inserting table HTML
SET @EmailBody =
    N'<body><p>The following jobs have been running for more than 30 minutes on SQL Server ' + @@SERVERNAME + N' and should be investigated:</p>' +
    @TableHtml +
    N'<p><em>This e-mail was sent by an automated process. Do not reply to this e-mail.</em></p>' +
    N'</body>'

SET NOCOUNT OFF

--send the e-mail
--requires Database Mail to be set up
EXEC msdb.dbo.sp_send_dbmail @recipients = 'dba@domain.com', @subject = @EmailSubject, @body = @EmailBody, @body_format = 'HTML'
```
