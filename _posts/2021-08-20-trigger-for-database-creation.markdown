---
layout: post
title:  "Notes to self: E-mail DBA on new database creation (and restore)"
date:   2021-08-20 12:00:00 +1000
categories: sqlserver
---
As part of [commissioning a SQL Server]({% post_url 2021-04-26-commissioning-a-sql-server %}), I create a server trigger to send an e-mail when a new database is created (adapted from <https://www.mssqltips.com/sqlservertip/2864/email-alerts-when-new-databases-are-created-in-sql-server/>), and a SQL Agent alert which e-mails when a database is restored (inspired by Jeremy Dearduff's comment at <https://www.brentozar.com/archive/2017/06/tracking-restores-hard/#comment-2446362>).

After receiving the e-mail I can follow up and include the database in an inventory. See below for the trigger and alert scripts - feel free to use these as a basis for your own monitoring and inventory.

<div markdown="1" class="note">
**Thomas's "but it worked for me" disclaimer:** before using any code you find on the internet, especially on this blog, take time to understand what the code does and test, test, test. I'm not responsible for damage caused by code from this blog, and don't offer any support or warranty.
</div>
<br/>

````sql
--create a server trigger to e-mail the DBA when a new database is created
--note if there's an error in this server trigger, new databases cannot be created
--so suggest not adding too much logic to the trigger
--depending on security settings, most likely need high-level ("sa") permission to create this trigger
--uses Database Mail to send e-mail, so requires Database Mail to be set up
--tested with SQL Server 2016, SQL Server 2019

USE [master]
GO
--drop trigger if it exists
IF EXISTS (SELECT * FROM sys.server_triggers WHERE [name] = N'trgEmailDbaOnNewDatabaseCreation') BEGIN
   DROP TRIGGER [trgEmailDbaOnNewDatabaseCreation] ON ALL SERVER
END
GO
/* trgEmailDbaOnNewDatabaseCreation
   By Thomas Williams <https://github.com/thomasswilliams>
   Server-level DDL trigger to send e-mail on new database creation.
   Adapted from https://www.mssqltips.com/sqlservertip/2864/email-alerts-when-new-databases-are-created-in-sql-server/
*/
CREATE TRIGGER [trgEmailDbaOnNewDatabaseCreation]
    ON ALL SERVER
    FOR CREATE_DATABASE
AS
    SET NOCOUNT ON
    SET XACT_ABORT ON
    SET ARITHABORT ON

    --e-mail subject, body
    DECLARE @EmailSubject NVARCHAR(255), @EmailBody NVARCHAR(MAX)

    BEGIN TRY
        --put together subject
        SET @EmailSubject = N'Database created on ' + @@SERVERNAME + N' by ' + SUSER_SNAME()
        --body from SQL statement executed in EVENTDATA(), available inside DDL trigger
        --e.g. CREATE DATABASE x (NAME = y, FILENAME = z...
        SET @EmailBody = N'<p><pre><code>' + (
         SELECT EVENTDATA().value('(/EVENT_INSTANCE/TSQLCommand/CommandText)[1]','NVARCHAR(MAX)')
        ) + N'</code></pre></p>'
        --add info to foot of e-mail
        SET @EmailBody = @EmailBody + N'<p><i>This e-mail was sent from server trigger &quot;trgEmailDbaOnNewDatabaseCreation&quot; by an automated process to &quot;dba@domain.com&quot;. Replies to this e-mail are not monitored.</i></p>'
        --send e-mail using Database Mail default profile
        EXEC msdb.dbo.sp_send_dbmail
            @recipients = 'dba@domain.com',
            @body_format = 'HTML',
            @body = @EmailBody,
            @subject = @EmailSubject,
            @exclude_query_output = 1
    END TRY
    BEGIN CATCH
    END CATCH
GO
````

````sql
--create a SQL Agent alert to send an e-mail to an operator on event ID 4356 ("Restore is complete on database '%ls'. The database is now available.")
--fairly basic, doesn't have access to EVENTDATA() like the trigger above
--alternatively could use Extended Events as per https://www.red-gate.com/hub/product-learning/sql-monitor/checking-for-database-events-using-extended-events-and-sql-monitor
--will not fire if RESTORE DATABASE fails

USE [msdb]
--delete alert if it exists
IF EXISTS (SELECT * FROM dbo.sysalerts WHERE [name] = N'E-mail DBA on RESTORE DATABASE') BEGIN
    EXEC dbo.sp_delete_alert @name = N'E-mail DBA on RESTORE DATABASE'
END
--create alert
EXEC dbo.sp_add_alert @name=N'E-mail DBA on RESTORE DATABASE',
    @message_id=4356,
    @severity=0,
    @enabled=1,
    @delay_between_responses=900,
    @include_event_description_in=1,
    @category_name=N'[Uncategorized]',
    @job_id=N'00000000-0000-0000-0000-000000000000'
--create e-mail notification for alert
--needs an operator set up (in this case called "DBA")
EXEC dbo.sp_add_notification @alert_name=N'E-mail DBA on RESTORE DATABASE', @operator_name=N'DBA', @notification_method=1
GO
````