---
layout: post
title:  "Commissioning a SQL Server (a checklist)"
date:   2021-04-24 17:00:00 +1000
categories: sqlserver
---
SQL Server's been installed. Now what?

Before a database server can be used it needs to be "commissioned". I use the word commissioned deliberately, as distinct from "configured".

Configuration happens for the entire life of a server.

Commissioning, to me, is readying the server for use, reviewing defaults and applying best practices, and setting it up for a particular purpose and environment. Once commissioned, a database server is ready for databases and operational use.

With this in mind, here's a sample checklist to commission a server:

- SQL Server and SQL Agent services set to start automatically, and are running
- SQL Server and SQL Agent services log on as domain service accounts <https://docs.microsoft.com/en-us/sql/database-engine/configure-windows/configure-windows-service-accounts-and-permissions>
- SQL Server Browser service is disabled unless required <https://www.stigviewer.com/stig/ms_sql_server_2016_instance/2020-12-16/finding/V-214042>
- Unneeded SQL Server services are removed
- SQL Server should be patched to latest update <https://www.stigviewer.com/stig/ms_sql_server_2016_instance/2020-12-16/finding/V-213994>, <https://social.technet.microsoft.com/wiki/contents/articles/43406.windows-server-patching-best-practices.aspx>
- TCP/IP protocol enabled
- SQL Server sysadmin permission for domain service account
- Windows power plan set to "High" <https://docs.microsoft.com/en-us/windows-server/administration/performance-tuning/role/hyper-v-server/configuration>, <https://blog.sqlauthority.com/2015/04/27/sql-server-using-high-performance-power-plan-for-sql-server>, <https://github.com/stephaneserero/Sql-recommendations-for-MECM/blob/master/SQL%20recommendations%20for%20MECM%20-%20White%20Paper%20v2.6.pdf>, <https://cloud.google.com/compute/docs/tutorials/creating-high-performance-sql-server-instance#setting_the_power_profile>
- Instant file initialisation permission for domain service account <https://docs.microsoft.com/en-us/sql/relational-databases/databases/database-instant-file-initialization>, <https://www.mssqltips.com/sqlservertip/4304/enable-sql-server-instant-file-initialization-for-time-savings>, <https://github.com/stephaneserero/Sql-recommendations-for-MECM/blob/master/SQL%20recommendations%20for%20MECM%20-%20White%20Paper%20v2.6.pdf>, <https://docs.microsoft.com/en-us/azure/azure-sql/virtual-machines/windows/performance-guidelines-best-practices-checklist#azure--sql-feature-specific>
- Lock pages in memory permission for domain service account <http://download.microsoft.com/download/D/2/0/D20E1C5F-72EA-4505-9F26-FEF9550EFD44/Best%20Practices%20for%20Running%20SQL%20Server%20with%20HVDM.docx>, <https://cloud.google.com/compute/docs/tutorials/creating-high-performance-sql-server-instance#setting_system_permissions>, <https://docs.microsoft.com/en-us/azure/azure-sql/virtual-machines/windows/performance-guidelines-best-practices-checklist#azure--sql-feature-specific>
- If using Windows Firewall, allow Windows Management Instrumentation (WMI) in Windows Firewall for SSMS
- Server authentication is set appropriately _(most commonly for me is "SQL Server and Windows")_
- Latest compatibility level for all databases _(ongoing)_ <https://www.sqlskills.com/blogs/glenn/database-compatibility-level-in-sql-server>, <https://docs.aws.amazon.com/prescriptive-guidance/latest/sql-server-ec2-best-practices/db-compatibility-level.html>
- Maximum and minimum server memory set <https://portal.nutanix.com/page/documents/solutions/details?targetId=BP-2015-Microsoft-SQL-Server:BP-2015-Microsoft-SQL-Server>
- Data, log and backup default locations <https://docs.microsoft.com/en-us/azure/azure-sql/virtual-machines/windows/performance-guidelines-best-practices-checklist#azure--sql-feature-specific>
- Backup compression enabled <https://www.brentozar.com/blitz/backup-compression/>
- tempdb database data files configured
- Database Mail (or alternative) set up
- SQL Agent alerts notifications set up
- Standard backups set up using Ola Hallengren solution
- Linked servers (MySQL, Oracle, Active Directory etc.) drivers installed and created as necessary
- File autogrowth increment is not percent _(ongoing)_ <https://www.brentozar.com/blitz/blitz-result-percent-growth-use>, <https://cloud.google.com/compute/docs/instances/sql-server/best-practices#handling_transaction_logs>, <https://docs.microsoft.com/en-us/azure/azure-sql/virtual-machines/windows/performance-guidelines-best-practices-checklist#azure--sql-feature-specific>
- Maximum log file size is set _(ongoing)_
- Database owner is "sa" _(ongoing)_
- SQL Agent job owner is "sa" _(ongoing)_
- Enable Remote Dedicated Admin Console (DAC) <https://www.brentozar.com/archive/2011/08/dedicated-admin-connection-why-want-when-need-how-tell-whos-using/>
- Query Store enabled on all non-system databases _(ongoing)_ <https://docs.microsoft.com/en-us/sql/relational-databases/performance/query-store-usage-scenarios>
- SQL Agent job history maximum increased if necessary _(depending on how often collected)_
- Old SQL Agent history (job, backup, maintenance plan) cleared using regularly scheduled SQL Agent job
- "sa" login is disabled <https://www.stigviewer.com/stig/ms_sql_server_2016_instance/2020-12-16/finding/V-214028>, <https://docs.microsoft.com/en-us/azure/azure-sql/virtual-machines/windows/security-considerations-best-practices>
- Server-level SQL logins created, if needed for applications
- Users and support staff Active Directory users/groups have server-level logins
- If needed, particular users or Active Directory groups have permission to view/manage SQL Agent jobs
- If needed, particular users or Active Directory groups have permission to start/stop SQL Server services
- Non-production logins should not be present on production servers
- Regular scheduled index maintenance set up using Ola Hallengren solution <https://cloud.google.com/compute/docs/instances/sql-server/best-practices#avoiding_index_fragmentation>
- Databases should be documented in a central DBA inventory
- Analyse whether "Optimise for ad-hoc workloads" and "Forced parametisation" are needed _(ongoing)_ <https://straightpathsql.com/archives/2017/01/optimize-for-ad-hoc-workloads>, <https://dba.stackexchange.com/questions/35500/why-would-i-not-use-the-sql-server-option-optimize-for-ad-hoc-workloads>, <https://github.com/stephaneserero/Sql-recommendations-for-MECM/blob/master/SQL%20recommendations%20for%20MECM%20-%20White%20Paper%20v2.6.pdf>
- Database collation should be consistent where possible _(ongoing)_
- Anti-virus ignores SQL Server database files, directories and processes <https://support.microsoft.com/en-us/topic/how-to-choose-antivirus-software-to-run-on-computers-that-are-running-sql-server-feda079b-3e24-186b-945a-3051f6f3a95b>
- Disconnected remote desktop sessions are automatically logged off after a set amount of inactivity <https://sqlsunday.com/installing-sql-server-2019>
- model system database configured
- <code>sp_WhoIsActive</code> logging <https://thomasswilliams.github.io/sqlserver/2020/12/02/spwhoisactive.html>
- Trace flags are analysed and enabled if necessary e.g. <https://docs.microsoft.com/en-us/sql/relational-databases/performance/best-practice-with-the-query-store>
- Analyse if network DTC (Distributed Transaction Coordinator) access needs to be enabled
