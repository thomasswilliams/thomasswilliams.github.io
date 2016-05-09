---
layout: post
title:  "Logging with NLog in PowerShell"
date:   2016-04-29 13:28:00 +1000
categories: net code
---
PowerShell has simple logging built in:

```posh
Write-Debug "This will be output to the console if `$DebugPreference = `"Continue`""

Echo "This will be output to the console and can be piped to Out-File (remember to use -append)"
```
 
Sometimes more complex logging is needed - for instance, [NLog][1], a proven and well-documented .NET library that can log to file or the Windows event log/e-mail/database as needed, controlled by a flexible XML config file.
 
I got NLog working in a PowerShell script. Here's how:

* download NLog e.g. from NuGet <https://www.nuget.org/packages/NLog>
* copy an appropriate `NLog.dll` to the same directory as your PowerShell script (I used version 4.3.3 .NET 4 DLL on Windows Server 2012)
* create an `NLog.config` file in the same directory as your PowerShell script
* copy the following text into the newly-created `NLog.config` file, changing `<YOUR DIRECTORY NAME HERE>` to a valid directory. This is the directory NLog will write the log file called "logfile.txt" to - it can be the same as the the directory your PowerShell script, `NLog.dll` and `NLog.config` files are:  

```
<?xml version="1.0" encoding="utf-8" ?>
<nlog xmlns="http://www.nlog-project.org/schemas/NLog.xsd"
      xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" 
      autoReload="true">
  <targets async="true">
    <!-- text file - absolute directory e.g. not using "basedir" variable -->
    <target name="logfile" 
            xsi:type="File" 
            fileName="<YOUR DIRECTORY NAME HERE>\logfile.txt"
            layout="${longdate}|${message} ${exception:format=tostring}"/>
  </targets>
  <rules>
    <!-- log only info and above -->
    <logger name="*" minLevel="Info" writeTo="logfile"/>
  </rules>
</nlog>
```  
* in your PowerShell script, copy the following text to somewhere near the top:

```posh
# get current running script path
$scriptPath = $MyInvocation.MyCommand.Path
$scriptPath = Split-Path $scriptPath
# set up logging with NLog
# requires NLog.dll and NLog.config to be in the same directory as this script
# adapted from https://github.com/NLog/NLog/issues/233
# needs absolute path to NLog.dll and NLog.config (use variable "scriptPath")
# ignore version and location output from LoadFile
[Reflection.Assembly]::LoadFile("$scriptPath\NLog.dll") | Out-Null

# load NLog config file 
# note all logging targets in NLog config file need to be absolute (not relative) paths
$ne = New-Object NLog.Config.XmlLoggingConfiguration("$scriptPath\NLog.config")
# assign config file
([NLog.LogManager]::Configuration) = $ne
# get the default logger
$logger = [NLog.LogManager]::GetCurrentClassLogger()
```
* you can now use NLog in your PowerShell script by calling methods on the `$logger` object, like:

```posh
$logger.Debug("Debug...") # note this won't be written using my sample NLog config file
$logger.Info("Info...")
$logger.Error("Error...")
```

If all goes well, after running the PowerShell script with output to the `$logger` object, the PowerShell script directory will have 4 files:

```
...
├── <YOUR AWESOME POWERSHELL SCRIPT>.ps1
├── logfile.txt
├── NLog.config
└── NLog.dll
```

Logging to a text file is only scratching the surface of what NLog is capable of. For more examples of NLog targets and layouts, see the NLog wiki at <https://github.com/nlog/nlog/wiki>.

One gotcha mentioned above is relative paths - NLog did not seem to write the log file without an absolute path. To troubleshoot, I added attributes `throwExceptions` and `internalLogToConsole` to the `NLog.config` file - more help can be found at at <https://github.com/nlog/nlog/wiki/Logging-troubleshooting>.

[1]: http://nlog-project.org/