---
layout: post
title:  "SSIS database error logging query"
date:   2022-07-25 12:00:00 +1000
categories: sqlserver
---
Logging and error reporting from SQL Server Integration Services packages can be tricky, especially when trying to keep consistency between different production and non-production environments.

I've seen - and, sadly, perpetrated - a lot of dodgy solutions using SSIS since SQL Server 2000 when it was known as DTS, from lots of error handling tasks and conditions, to duplicating error logging tables in another database, to using e-mail as a ticketing system, and even testing for success of SQL Agent job steps with a PowerShell script called from a separate Windows scheduled task (ouch).

Due to its simplicity, I'm a fan of the default, in-built "SSIS log provider for SQL Server" logging, which writes to the SSIS database `SSISDB` when the package is deployed to a SQL Server. This logging comes out of the box with very little setup required, and can be supplemented by custom messages - for instance, using `Dts.Log` in a script task as per <https://docs.microsoft.com/en-us/sql/integration-services/extending-packages-scripting/task/logging-in-the-script-task>.

Best of all, because log messages are written to tables in the `SSISDB` database, end-users can run a query or report to troubleshoot errors.

The query below returns just error messages for the last 7 days from the `SSISDB` database. I've kept the original column names where possible, and made a couple of small changes to suit me: including a calling package name (if there is one), and removing the leading package/container/task name from the message itself:

<div markdown="1" class="note">
**Thomas's "but it worked for me" disclaimer:** before using any code you find on the internet, especially on this blog, take time to understand what the code does and test, test, test. I'm not responsible for damage caused by code from this blog, and don't offer any support or warranty.
</div>
<br/>

```sql
USE [SSISDB]

--get error messages in the last 7 days, and the package and task that errored
--adapted from https://dba.stackexchange.com/questions/118737/how-to-query-ssisdb-to-find-out-the-errors-in-the-packages
--and http://msdn.microsoft.com/en-us/library/ff877994.aspx
--tested with SQL Server 2019
--use "catalog" views, not "internal" tables
--need permission to read from "catalog" views i.e. "ssis_admin" role
--or, permissions can be explicitly set on views:
-- * [catalog].[operation_messages]
-- * [catalog].[executions]
-- * [catalog].[event_messages]
SELECT  --the name of the server
        e.[server_name],
        --Integration Services Catalogs > SSISDB folder
        e.[folder_name],
        --SSISDB project name
        e.[project_name],
        --package and extension e.g. "package.dtsx"
        em.[package_name],
        --optional top level/parent/calling package and extension
        --make NULL if the same as the package
        --from docs: "The name of the first package that was started during execution."
        [called_by_package_name] = CASE WHEN em.[package_name] != e.[package_name] THEN e.[package_name] END,
        --run as login
        e.[executed_as_name],
        --message date and time and offset/timezone
        om.[message_time],
        --description for message source
        --from https://docs.microsoft.com/en-us/sql/integration-services/system-views/catalog-operation-messages-ssisdb-database?view=sql-server-ver15
        [message_source_type_description] = CASE
            WHEN om.[message_source_type] = 10 THEN 'Entry APIs, such as T-SQL and CLR Stored procedures'
            WHEN om.[message_source_type] = 20 THEN 'External process used to run package (ISServerExec.exe)'
            WHEN om.[message_source_type] = 30 THEN 'Package-level objects'
            WHEN om.[message_source_type] = 40 THEN 'Control Flow tasks'
            WHEN om.[message_source_type] = 50 THEN 'Control Flow containers'
            WHEN om.[message_source_type] = 60 THEN 'Data Flow task'
        END,
        --message source e.g. package, container, task
        em.[message_source_name],
        --error message, remove prepended message source and then a colon
        [message] = REPLACE(om.[message], em.[message_source_name] + N':', N''),
        --unique, auto-incrementing identifier for the package execution
        --could be useful for linking back to other messages from the same execution
        om.[operation_id]
FROM    --messages view
        [catalog].[operation_messages] om LEFT OUTER JOIN
            --executions view
            [catalog].[executions] e ON
                om.[operation_id] = e.[execution_id] LEFT OUTER JOIN
            --further detail about all messages
            [catalog].[event_messages] em ON
                om.[operation_id] = em.[operation_id] AND
                om.[operation_message_id] = em.[event_message_id]
WHERE   --errors only
        om.[message_type] = 120 AND
        --last 7 days
        om.[message_time] >= DATEADD(DAY, -7, GETDATE())
```

Your mileage using this query may vary, depending on how the operations log is configured (for instance, how many days of logs are retained). See <https://docs.microsoft.com/en-us/sql/integration-services/performance/integration-services-ssis-logging#server_logging> for a full overview.