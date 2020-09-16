---
layout: post
title:  "Notes to self: e-mailing a DBA if there's SQL Server database backups run during business hours"
date:   2020-08-10 17:00:00 +1000
categories: [powershell, sqlserver]
---
Database backups normally run out-of-hours to lessen impact to operational processes and users.

I worked with a vendor who liked running ad-hoc database backups during the day. After some discussion we agreed that they'd cut back on the backups, and communicate to users if there was a legitimate need before they started the backup.

To help monitor those and other database backups during business hours, I cobbled together the PowerShell script below to read the Windows Application event log for the current day and send an e-mail with details, called in a SQL Agent job step (see [Microsoft docs for using PowerShell in SQL Agent job steps here](https://docs.microsoft.com/en-us/sql/powershell/run-windows-powershell-steps-in-sql-server-agent)).

There's lots of alternatives to the PowerShell/Windows event log script - even real-time options - but I found the PowerShell script suited my needs and was the simplest way to generate a HTML table from a collection of results (a one-liner `ConvertTo-Html -Fragment -As Table`).

I call the PowerShell script from a SQL Agent job step of type "PowerShell" on SQL Server 2016, around 7:00PM each night. If there's no database backups during business hours, the e-mail won't be sent. The script should work with versions of SQL Server later than 2016 too. You'll need to substitute your own values for server, domain, e-mail address, and SMTP server (in the last line of the script).

<div markdown="1" class="note">
**Thomas's "but it worked for me" disclaimer:** before using any code you find on the internet, especially on this blog, take time to understand what the code does and test, test, test. I'm not responsible for damage caused by code from this blog, and don't offer any support or warranty.
</div>
<br/>

```posh
# today's date in unambiguous d/MMM/yyyy format (because, Aussie here)
$date = Get-Date -Format "d/MMM/yyyy"

# get collection of events from Windows "Application" event log, with source "MSSQLSERVER",
# that occured today between 7:00AM and 6:00PM (business hours),
# with event ID 18264 SQL Server backup
# this will take some time (e.g. minutes) depending on size of event log
# important: pass "AsBaseObject" to get event log entry with necessary properties
# note: backup success messages will not be written to Windows event log if trace flag 3226 is enabled - see https://docs.microsoft.com/en-us/sql/t-sql/database-console-commands/dbcc-traceon-trace-flags-transact-sql?view=sql-server-ver15
$events = Get-EventLog -AsBaseObject -Log "Application" -Source "MSSQLSERVER" -After ([datetime](($date) + ' 7:00:00 AM')) -Before ([datetime](($date) + ' 6:00:00 PM')) | Where-Object { $_.EventID -eq 18264 }

# did we get any events? If not, leave
If ($null -eq $events -or $events.Count -eq 0) {
  Return
}

# set up e-mail body
$body = "<body><p>The following backups were run in SQL Server during business hours and should be followed up:</p>"

# add to body - output events as HTML table, will include pre- and post-HTML tags
$body += $events |
  Select-Object Message, TimeGenerated, UserName |
  ConvertTo-Html -Fragment -As Table

# append footer and close body
$body += "<p><em>This e-mail was sent by an automated process. Do not reply to this e-mail.</em></p></body>"

# create anonymous credentials for the SMTP server with blank password
# from http://community.idera.com/powershell/ask_the_experts/f/learn_powershell_from_don_jones-24/11843/send-mailmessage-without-authentication
$blank_password = New-Object System.Security.SecureString
$creds = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList "NT AUTHORITY\ANONYMOUS LOGON", $blank_password

# send e-mail from this server
# pass anonymous credentials
Send-MailMessage -Credential $creds -From "server@domain.com" -To "dba@domain.com" -Subject "** SQL Server Backups during business hours **" -BodyAsHTML -Body $body -SmtpServer "smtp_server.domain.com"
```
