---
layout: post
title:  "Create and test Oracle linked server on SQL Server 2012"
date:   2018-08-16 12:00:00 +1000
categories:
---
This post is more of a "note to self" to keep track of steps to create and test an Oracle linked server on SQL Server 2012.

I prefer a combination of the Oracle Provider for OLE DB, [EZCONNECT][1] (needs to be enabled in `SQLNET.ORA`) and DNS CNAMEs to keep the SQL Server config simple, tweaked from <https://blogs.msdn.microsoft.com/dbrowne/2013/10/02/creating-a-linked-server-for-oracle-in-64bit-sql-server/>.

<div markdown="1" class="note">
**Thomas's "but it worked for me" disclaimer:** before using any code you find on the internet, especially on this blog, take time to understand what the code does and test, test, test. I'm not responsible for damage caused by code from this blog, and don't offer any support or warranty.
</div>
<br/>

```sql
USE [master]

--drop linked server if it exists
IF EXISTS (SELECT * FROM sys.servers WHERE [name] = N'NEW_LINKED_SERVER' AND [is_linked] = 1) BEGIN
    EXEC master..sp_dropserver @server = N'NEW_LINKED_SERVER', @droplogins = 'droplogins'
END

--create linked server - replace host, port and service name with correct values
--using Oracle Provider for OLE DB
EXEC master..sp_addlinkedserver N'NEW_LINKED_SERVER', N'Oracle', N'ORAOLEDB.Oracle', N'//host:port/service_name', N'', N''
--script other necessary options here - I like to explicitly set query timeout
EXEC master..sp_serveroption @server = N'NEW_LINKED_SERVER', @optname = N'rpc out', @optvalue = N'true'
EXEC master..sp_serveroption @server = N'NEW_LINKED_SERVER', @optname = N'query timeout', @optvalue = N'900' 
--script linked server login too - replace username and password with correct values
EXEC master..sp_addlinkedsrvlogin @rmtsrvname = N'NEW_LINKED_SERVER', @useself = N'False', @locallogin = NULL, @rmtuser = N'username', @rmtpassword = 'password' 

--test connectivity, adapted from https://stackoverflow.com/a/10191248/116288
DECLARE @ret INT, @error_message NVARCHAR(4000), @error_number INT = 0

BEGIN TRY
    EXEC @ret = sys.sp_testlinkedserver N'NEW_LINKED_SERVER'
END TRY
BEGIN CATCH
    SELECT @error_number = SIGN(@@ERROR), @error_message = ERROR_MESSAGE()
END CATCH

IF (@error_number != 0) BEGIN
    PRINT @error_message
    PRINT 'There may be other error messages printed by "sp_testlinkedserver" above'
END ELSE BEGIN
    --test by running a query on the new linked server
    BEGIN TRY
        EXEC ('select sysdate from dual') AT [NEW_LINKED_SERVER]
    END TRY
    BEGIN CATCH
        SELECT @error_number = SIGN(@@ERROR), @error_message = ERROR_MESSAGE()
    END CATCH
    IF (@error_number != 0) BEGIN
        PRINT @error_message
        PRINT 'There may be other error messages printed above'
    END ELSE BEGIN 
        --success
        PRINT 'Linked server created and tested successfully'
    END
END

--clean up, drop linked server
IF EXISTS (SELECT * FROM sys.servers WHERE [name] = N'NEW_LINKED_SERVER' AND [is_linked] = 1) BEGIN
    EXEC master..sp_dropserver @server = N'NEW_LINKED_SERVER', @droplogins = 'droplogins'
END
```

[1]: http://www.orafaq.com/wiki/EZCONNECT
