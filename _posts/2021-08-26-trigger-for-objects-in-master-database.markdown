---
layout: post
title:  "Notes to self: E-mail DBA on objects created in the master system database"
date:   2021-08-26 12:00:00 +1000
categories: sqlserver
---
Next on the list to [commission a SQL Server]({% post_url 2021-04-26-commissioning-a-sql-server %}), is to create a trigger in the _master_ system database to send an e-mail to the DBA when objects are created in the database.

In general I'd expect this never to happen - but if it did, I'd want to follow up. It's possible to go even further and [prevent creating objects in the _master_ system database completely](https://www.sqlservercentral.com/articles/block-user-objects-from-being-created-in-a-master-database).

<div markdown="1" class="note">
**Thomas's "but it worked for me" disclaimer:** before using any code you find on the internet, especially on this blog, take time to understand what the code does and test, test, test. I'm not responsible for damage caused by code from this blog, and don't offer any support or warranty.
</div>
<br/>

````sql
--create a trigger in the master system database to e-mail DBA (using Database Mail)
--on schema changes e.g. object creation, update or deletion in the master database
--depending on security settings, most likely need high-level ("sa") permission to create this trigger
--note if there's an issue in this trigger, may impact object creation in master database
--so suggest not adding too much logic to the trigger
--requires Database Mail to be set up, and a default profile to send
--tested with SQL Server 2016, SQL Server 2019
--adapted from https://www.julian-kuiters.id.au/ddl-trigger-prevent-and-notify-ddl-changes/
USE [master]
GO
--drop trigger if it exists
IF EXISTS (SELECT * FROM sys.triggers WHERE [name] = N'trgEmailDbaOnMasterDatabaseObjectCreation') BEGIN
    DROP TRIGGER [trgEmailDbaOnMasterDatabaseObjectCreation] ON DATABASE
END
GO
/* trgEmailDbaOnMasterDatabaseObjectCreation
   By Thomas Williams https://github.com/thomasswilliams
   DDL trigger to send e-mail on schema changes e.g. objects created, altered or
   deleted in the master database. Will potentially send multiple e-mails for a
   single object created, depending on the number of different statements executed.
   Adapted from https://www.julian-kuiters.id.au/ddl-trigger-prevent-and-notify-ddl-changes/
*/
CREATE TRIGGER [trgEmailDbaOnMasterDatabaseObjectCreation]
    ON DATABASE
    FOR DDL_DATABASE_LEVEL_EVENTS
AS
    SET NOCOUNT ON
    SET XACT_ABORT ON
    SET ARITHABORT ON

    --command text (DDL statement), database name from EVENTDATA()
    DECLARE @CommandText NVARCHAR(MAX), @DatabaseName NVARCHAR(MAX)
    --e-mail subject, body
    DECLARE @EmailSubject NVARCHAR(255), @EmailBody NVARCHAR(MAX)
    --get EVENTDATA, available inside DDL trigger
    DECLARE @xmlEventData XML = EVENTDATA()

    BEGIN TRY
        --get command text and database name from EVENTDATA XML
        SET @CommandText = @xmlEventData.value('(/EVENT_INSTANCE/TSQLCommand/CommandText)[1]', 'NVARCHAR(MAX)')
        SET @DatabaseName = @xmlEventData.value('(/EVENT_INSTANCE/DatabaseName)[1]', 'NVARCHAR(MAX)')

        --ignore changes to this trigger and statistics updates to "CommandLog"
        --(Ola Hallengren backup) - otherwise, send e-mail to DBA
        IF (
         UPPER(@CommandText) NOT LIKE N'%DROP TRIGGER %TRGEMAILDBAONMASTERDATABASEOBJECTCREATION%' AND
         UPPER(@CommandText) NOT LIKE N'%ALTER TRIGGER %TRGEMAILDBAONMASTERDATABASEOBJECTCREATION%' AND
         UPPER(@CommandText) NOT LIKE N'%UPDATE STATISTICS %COMMANDLOG%'
        ) BEGIN
            --put together subject
            SET @EmailSubject = N'Changes to ' + @DatabaseName + N' database on ' + @@SERVERNAME + N' by ' + SUSER_SNAME()
            --put command text into e-mail body
            SET @EmailBody = N'<p><pre><code>' + @CommandText + N'</code></pre></p>'
            --append info to e-mail body
            SET @EmailBody = @EmailBody + N'<p><i>This e-mail was sent from trigger &quot;trgEmailDbaOnMasterDatabaseObjectCreation&quot; by an automated process to &quot;dba@domain.com&quot;. Replies to this e-mail are not monitored.</i></p>'
            --send e-mail using Database Mail default profile
            EXEC msdb.dbo.sp_send_dbmail
                @recipients = 'dba@domain.com',
                @body_format = 'HTML',
                @body = @EmailBody,
                @subject = @EmailSubject,
                @exclude_query_output = 1
        END
    END TRY
    BEGIN CATCH
    END CATCH
GO
````