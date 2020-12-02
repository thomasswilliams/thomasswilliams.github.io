---
layout: post
title:  "Using sp_WhoIsActive to record & query activity on SQL Server"
date:   2020-12-02 17:00:00 +1000
categories: sqlserver
---
There's lots of blog posts on how to use Adam Machanic's excellent (and free) "sp_WhoIsActive" script to view active connections to a SQL Server from <http://whoisactive.com>. I like Tara Kizer & Brent Ozar's no-nonsense approach to logging the results in a table at <https://www.brentozar.com/archive/2016/07/logging-activity-using-sp_whoisactive-take-2/> so much I use it almost as-is.

There's other ways to view active connections, what database they're connected to, the current SQL statement and more (for instance, Activity Monitor). But there's a definite advantage to being able to query and summarise these from a table using plain SQL.

I schedule the script below every 40 or so seconds to log the output from "sp_WhoIsActive" to a table, keeping data for the last 7 days. The script will create the table if it doesn't exist (but needs an existing database, I've used a database called "Scratch"). The script assumes that "sp_WhoIsActive" has been created in the `master` database.

The script typically takes less than a second to run, even on reasonably busy servers.

<div markdown="1" class="note">
**Thomas's "but it worked for me" disclaimer:** before using any code you find on the internet, especially on this blog, take time to understand what the code does and test, test, test. I'm not responsible for damage caused by code from this blog, and don't offer any support or warranty.
</div>
<br/>

```sql
--get output from Adam Machanic's excellent "sp_WhoIsActive" script from http://whoisactive.com
--into logging table, should be scheduled every 30-60 seconds
--relies on sp_WhoIsActive stored proc being present in master database
--logging table hard-coded here to "WhoIsActive" table in Scratch database
--liberally borrowed from https://www.brentozar.com/archive/2016/07/logging-activity-using-sp_whoisactive-take-2/

USE [master]

SET NOCOUNT ON

DECLARE
    --number of days to retain output from sp_WhoIsActive in logging table
    @number_of_days_to_retain INT = 7,
    --logging table name (will be created if does not exist)
    @destination_table NVARCHAR(500) = N'WhoIsActive',
    --logging table database (will not be created if it doesn't exist)
    @destination_database SYSNAME = N'Scratch',
    --dynamic SQL, re-used
    @sql NVARCHAR(4000),
    --does the index on the logging table exist?
    @does_index_exist BIT

--prepend logging table with database and schema
SET @destination_table = @destination_database + N'.dbo.' + @destination_table

--create the logging table if it doesn't exist
IF OBJECT_ID(@destination_table) IS NULL BEGIN
    --get the CREATE TABLE statement to suit output from sp_WhoIsActive
    EXEC master..sp_WhoIsActive @get_transaction_info = 1, @get_outer_command = 1, @get_plans = 1, @return_schema = 1, @format_output = 0, @get_additional_info = 1, @schema = @sql OUTPUT
    --replace with logging table name in returned CREATE TABLE statement
    SET @sql = REPLACE(@sql, N'<table_name>', @destination_table)
    --create the logging table by executing the CREATE TABLE statement
    EXEC(@sql)
END

--logging table exists; now check for index on collection_time column
--index on collection_time makes it easier to delete older data
SET @sql = N'USE ' + QUOTENAME(@destination_database) + N'; IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(@destination_table) AND name = N''cx_collection_time'') SET @does_index_exist = 0'
--check if the index exists, output will be in boolean "@does_index_exist"
EXEC sp_executesql @sql, N'@destination_table NVARCHAR(500), @does_index_exist bit OUTPUT', @destination_table = @destination_table, @does_index_exist = @does_index_exist OUTPUT
--does index exist? If not, create it on the logging table
IF @does_index_exist = 0 BEGIN
  SET @sql = N'CREATE CLUSTERED INDEX cx_collection_time ON ' + @destination_table + ' (collection_time ASC)'
  EXEC(@sql)
END

SET NOCOUNT OFF

--get output from sp_WhoIsActive into logging table
--  @get_transaction_info: "Enables pulling transaction log write info and transaction duration"
--  @get_outer_command: "Get the associated outer ad hoc query or stored procedure call, if available"
--  @get_plans: "Get associated query plans for running tasks, if available"
--  @format_output: "...outputs all of the numbers as actual numbers rather than text"
--  @get_additional_info: "...he [additional_info] column is an XML column that returns a document with a root node called <additional_info>. What’s inside of the node depends on a number of things..."
EXEC master..sp_WhoIsActive @get_transaction_info = 1, @get_outer_command = 1, @get_plans = 1, @format_output = 0, @get_additional_info = 1, @destination_table = @destination_table

SET NOCOUNT ON

--delete data older than "number of days to retain" variable
SET @sql = N'DELETE FROM ' + @destination_table + N' WHERE [collection_time] < DATEADD(day, -' + CAST(@number_of_days_to_retain AS NVARCHAR(10)) + N', GETDATE())'
EXEC(@sql)
```

As mentioned above, the benefit to having activity recorded for the last 7 days is being able to answer historical questions. While Query Store has replaced and surpassed queries I previously could have used "sp_WhoIsActive" for (for example, most frequently run queries, high CPU queries, high I/O queries), there's a couple of questions that are hard to answer any other way. I created/adapted the queries below over the years - more of these sorts of queries can be found at <http://whoisactive.com> documentation.

```sql
--which logins were most used in the last 7 days (counting unique login times)
SELECT TOP 10 [login_name], [count of distinct login time] = COUNT(DISTINCT [login_time])
FROM    [Scratch].dbo.[WhoIsActive] (READPAST)
GROUP BY [login_name]
ORDER BY 2 DESC

--were there any SHRINKFILEs (should not be, DBA-type task)
--will not catch all occurences of SHRINKFILE, only those running while data was collected
SELECT  *
FROM    [Scratch].dbo.[WhoIsActive] (READPAST)
WHERE   [sql_text] LIKE N'%SHRINKFILE%'

--tempdb allocations by query
--top queries are typically those that use temporary table variables
--sp_Blitz might show up here (as it is frequently run, and tempdb-heavy)
SELECT TOP 10 [sql_text], [database_name], [Sum of tempdb_allocations] = SUM([tempdb_allocations])
FROM    [Scratch].dbo.[WhoIsActive] (READPAST)
WHERE   [database_name] != N'tempdb'
GROUP BY [sql_text], [database_name]
ORDER BY 3 DESC

--blocked sessions, with blocking session details
;WITH BLOCKING AS (
 --blocking sessions
 SELECT DISTINCT [blocking_session_id], [collection_time]
 FROM    [Scratch].dbo.[WhoIsActive] (READPAST)
 WHERE   [blocking_session_id] IS NOT NULL
), BLOCKING_DETAILS AS (
 --get SQL text from blocking sessions at the same collection time
 SELECT DISTINCT BLOCKING.[blocking_session_id], W.[sql_text]
 FROM    [Scratch].dbo.[WhoIsActive] W (READPAST) INNER JOIN
             BLOCKING ON
                 W.[session_id] = BLOCKING.[blocking_session_id] AND
                 W.[collection_time] = BLOCKING.[collection_time]
 WHERE   W.[sql_text] IS NOT NULL
), BLOCKED AS (
 --blocked sessions
 --note may not have transaction start time, so use either transaction start time or collection time
 SELECT DISTINCT [session_id], [timing] = COALESCE([tran_start_time], [collection_time])
 FROM    [Scratch].dbo.[WhoIsActive] (READPAST)
 WHERE   [blocking_session_id] IS NOT NULL
 GROUP BY [session_id], COALESCE([tran_start_time], [collection_time])
)
SELECT  --blocked session
        W.[session_id], W.[sql_text], W.[login_name],
        --blocking session
        W.[blocking_session_id], [blocking_sql_text] = BLOCKING_DETAILS.[sql_text],
        W.[tran_start_time], W.[database_name], W.[collection_time]
FROM    [Scratch].dbo.[WhoIsActive] W (READPAST) INNER JOIN
            BLOCKED ON
                W.[session_id] = BLOCKED.[session_id] AND
                COALESCE(W.[tran_start_time], W.[collection_time]) = BLOCKED.[timing] LEFT OUTER JOIN
            BLOCKING_DETAILS ON
                W.[blocking_session_id] = BLOCKING_DETAILS.[blocking_session_id]
ORDER BY W.[session_id], COALESCE(W.[tran_start_time], W.[collection_time])
```
