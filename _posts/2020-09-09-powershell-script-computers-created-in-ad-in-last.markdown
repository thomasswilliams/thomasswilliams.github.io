---
layout: post
title:  "PowerShell script for computers created in Active Directory in last x days"
date:   2020-09-09 17:00:00 +1000
categories:
---
I wrote the PowerShell script below to return computers created in Active Directory in the last *x* days, and identify which - if any - of those computers are running SQL Server. I've updated and adapted the script since 2017; before that, I wrote an old VBScript to do the same thing. 

As a DBA I use the script semi-regulalrly (perhaps monthly), to check that new SQL Servers have been correctly added to monitoring and inventory systems.

Some of the improvements I made over the years including checking if Windows Remote Management is running on a computer, and allowing for a timeout when querying Windows services using `Get-Service`.

I run the script with the latest PowerShell 7 preview (as at August 2020) on Windows 10 - to do teh same, save the script below as `servers-created-in-last-x-days.ps1` and call it from a command line using one of the examples.

Hopefully this script can help others with similar requirements - or be the basis for an even better script!

<div markdown="1" class="note">
**Thomas's "but it worked for me" disclaimer:** before using any code you find on the internet, especially on this blog, take time to understand what the code does and test, test, test. I'm not responsible for damage caused by code from this blog, and don't offer any support or warranty.
</div>
<br/>

```posh
<#
.SYNOPSIS
  Query Active Directory for computers that have a "whenCreated" property in the last "x"
  number of days, where "x" is configurable by the user via a passed value or prompt. Loop
  through the computers and if they are contactable, return any Window services containing
  the text "SQL". Adapted from https://gallery.technet.microsoft.com/scriptcenter/Get-ADNelwyCreatedAccount-c553389d
  Requires appropriate permission on computers to call Get-Service remotely, PowerShell Active Directory module.
  By Thomas Williams <https://github.com/thomasswilliams>

.DESCRIPTION
  Pass a number of days for cut-off date to get computers created after, or run without parameters to be prompted.

.PARAMETER NumberOfDays
  Cut-off date (number of days prior to today) to get computers created after.

.EXAMPLE
  $DebugPreference = "Continue"; & '.\servers-created-in-last-x-days.ps1'; $DebugPreference = "SilentlyContinue"
  Runs with debug statements, prompt for number of days, and turns debug statements off at the end.

.EXAMPLE
  .\servers-created-in-last-x-days.ps1 "31"
  Gets computers created in the last 31 days, and any services containing the text "SQL".
#>
[CmdletBinding()]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidUsingWriteHost", "")]
Param(
  [Parameter(Mandatory = $false,
             Position = 0,
             ValueFromPipeline = $true,
             ValueFromPipelineByPropertyName = $true,
             HelpMessage = "Cut-off date (number of days prior to today) to get computers created after.")]
  [int]$NumberOfDays
)
Begin {
  # Active Directory module needed for Get-ADObject
  Import-Module ActiveDirectory -Verbose:$false
}
Process {
  # error on coding violations
  Set-StrictMode -Version Latest

  Function getWhenCreatedForComputer($computer) {
    <#
      .SYNOPSIS
        Get date and time that the passed computer was created in Active Directory.
        Expects computer name.
    #>
    Try {
      # note getting computer object may error, if so return empty string
      # expand the date property otherwise will get object e.g. "@{ name=xxx }"
      # adapted from http://woshub.com/get-adcomputer-getting-active-directory-computers-info-via-powershell/
      # remove seconds & format event time to unambiguous month format d/MMM/YYYY (because, Aussie here)
      # can change date & time format - set to "G" for instance for general date long time using local regional settings
      Return (Get-ADComputer -Identity $computer -Properties * -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Created).toString("d/MMM/yyyy h:mmtt")
    } Catch {
      Return [string]::Empty
    }
  }

  # if not passed a number of days parameter, prompt user for number of days
  # adapted from https://blogs.technet.microsoft.com/heyscriptingguy/2009/07/03/hey-scripting-guy-how-can-i-prompt-users-for-information-when-a-script-is-run/
  If ([string]::IsNullOrEmpty($NumberOfDays) -Or $NumberOfDays -eq 0) {
    $title = "Servers created recently"
    $message = "Servers created in the last:"
    # array of choices
    # index (0-based) will be returned
    # ampersand before a letter or number makes it a "hot key"
    $choices = [System.Management.Automation.Host.ChoiceDescription[]] @("&1 month", "&2 months", "&4 months", "&Quit")
    # set default to 1 month (index = 0)
    [int]$choice_default = 0
    # prompt user and get choice (index)
    $choice_selected = $host.ui.PromptForChoice($title, $message, $choices, $choice_default)
    # if choice is "quit" (index = 3), quit
    If ($choice_selected -eq 3) {
      Write-Debug "User selected 'quit', quitting..."
      Exit
    }

    # calculate number of days based on choice
    Switch ($choice_selected) {
      0 { $NumberOfDays = 31 }
      1 { $NumberOfDays = 62 }
      2 { $NumberOfDays = 124 }
    }
  }
  # check for cancel here
  If ([string]::IsNullOrEmpty($NumberOfDays) -Or $NumberOfDays -eq 0) {
    Write-Output "No number of days entered, quitting..."
    Exit
  }
  # collection of computers and create dates (initially empty)
  $output = @()
  # set up cut-off date using the number of days
  $CutOffDate_Raw = (Get-Date).AddDays(-$NumberOfDays)
  # format cutoff date in UTC
  $CutOffDate = "$($CutOffDate_Raw.Year)$("{0:D2}" -f $CutOffDate_Raw.Month)$("{0:D2}" -f $CutOffDate_Raw.Day)000000.0Z"

  # set up LDAP filter to limit to just computer objects, created after UTC cutoff date
  # this is slower than limiting to particular OU, but will not miss any computers
  $LDAPFilter = "(&(objectClass=Computer)(whenCreated>=$CutOffDate))"

  # set up fully-qualified domain name for the current domain
  $DomainFqdn = (Get-ADDomain).DNSRoot

  # search entire domain
  $SearchBase = (Get-ADRootDSE).defaultNamingContext

  # reset timer
  $TimerStart = Get-Date

  # get collection of computers created after the cutoff date
  # return only the name, expanded (so not in JSON format like "@{name=xxx}")
  $computers = Get-ADObject -SearchBase $SearchBase -LDAPFilter $LDAPFilter -Properties WhenCreated -Server $DomainFqdn | Select-Object -ExpandProperty name

  "Got $($computers.Count) computer(s) created in last $NumberOfDays days in " + [math]::Round((New-Timespan -Start $TimerStart -End $(Get-Date)).TotalSeconds, 2) + " seconds" | ForEach-Object { Write-Debug $_ }

  # loop through computers collection
  ForEach ($computer in $computers) {

    # optionally ignore computers with names in a pattern, for example if workstations start with "WS"
    If ($computer -notlike "WS*") {
      # if the computer is online
      If (Test-Connection $computer -Count 1 -Quiet -ErrorAction SilentlyContinue) {
        Write-Debug "$computer is online, about to check WS-Management service..."

        Try {
          # is the WS-Management service running on the target computer?
          # don't error when testing, store in variable that will have array of errors returned
          # ignore return from Test-WSMan
          $ws_man_error = @()
          Test-WSMan -ComputerName $computer -ErrorAction SilentlyContinue -ErrorVariable ws_man_error | Out-Null
          If ($ws_man_error.Count -eq 0) {
            Write-Debug "WS-Management service is running on $computer, about to get services with 'SQL' in the name..."

            # reset timer
            $TimerStart = Get-Date

            # return just the name of Windows services containing the text "sql"
            # this may fail if the user running this script does not have permission
            # wrap call to remote computer in job as occasionally would hang
            # adapted from https://serverfault.com/a/509975/78216
            # need to use Invoke-Command inside script block, as ComputerName
            # parameter for Get-Service was removed from PowerShell 6
            # adapted from https://powershell.org/forums/topic/using-invoke-command-with-a-timeout/#post-74666
            $job = Start-Job -ScriptBlock {
              Invoke-Command -ComputerName $Using:computer -ScriptBlock { Get-Service -Name "*SQL*" -ErrorAction Continue | Select-Object -ExpandProperty Name }
            } | Wait-Job -Timeout 30

            # either job timed out, or has return
            If ($null -eq $job) {
              Write-Warning "The computer $computer timed out getting services, skipping..."
              # add to output collection
              $output += New-Object PSObject -Property @{ Computer = $Computer; SqlServerService = [string]::Empty; WhenCreated = getWhenCreatedForComputer($Computer); }
            } Else {
              # ensure services is a collection by wrapping with @() as per https://stackoverflow.com/questions/62558427/increment-a-variable-based-on-number-of-items-in-powershell#comment110632078_62558427
              # otherwise if single service returned, would not be collection and error when trying to access "Count" property
              $services = @(Receive-Job $job -ErrorAction Stop)

              # if we got services collection, output
              If ($services) {
                "Got $($services.Count) service(s) with 'SQL' in the name from $computer in " + [math]::Round((New-Timespan -Start $TimerStart -End $(Get-Date)).TotalSeconds, 2) + " seconds" | ForEach-Object { Write-Debug $_ }

                # add to output collection
                $output += $services |
                  # create a new object to return with the computer, and service name(s)
                  ForEach-Object { New-Object PSObject -Property @{ Computer = $Computer; SqlServerService = $_; WhenCreated = getWhenCreatedForComputer($Computer); } }
              } Else {
                # no services with SQL in the name
                "Got 0 services with 'SQL' in the name from $computer in " + [math]::Round((New-Timespan -Start $TimerStart -End $(Get-Date)).TotalSeconds, 2) + " seconds" | ForEach-Object { Write-Debug $_ }
                # create a new object with the computer name and when created, and blank for service name
                # add to output collection
                $output += New-Object PSObject -Property @{ Computer = $Computer; SqlServerService = [string]::Empty; WhenCreated = getWhenCreatedForComputer($Computer); }
              }
            }
          } Else {
            Write-Warning "The WS-Management service is not running on $computer, skipping..."
            # add to output collection
            $output += New-Object PSObject -Property @{ Computer = $Computer; SqlServerService = [string]::Empty; WhenCreated = getWhenCreatedForComputer($Computer); }
          }
        } Catch {
          $msg = "Error getting services on $computer" + ": " + $error[0].ToString()
          Write-Error -Message $msg -ErrorAction SilentlyContinue
          $host.ui.WriteErrorLine("ERROR: " + $msg)
          # add to output collection even though error
          $output += New-Object PSObject -Property @{ Computer = $Computer; SqlServerService = [string]::Empty; WhenCreated = getWhenCreatedForComputer($Computer); }
        }
      } Else {
        Write-Warning "The computer $computer is not contactable, skipping..."
        # add to output collection
        $output += New-Object PSObject -Property @{ Computer = $Computer; SqlServerService = [string]::Empty; WhenCreated = getWhenCreatedForComputer($Computer); }
      }
    } Else {
      Write-Debug "Ignoring computer $computer..."
    }
  }
  # output computers collection, ignore empty lines (?), "SQLTELEMETRY" & "SQLWriter" services
  # adapted from https://stackoverflow.com/a/36585818/116288
  $output | Where-Object {
    -not ($_.Computer -eq [string]::Empty) -and
    -not ($_.SqlServerService -eq "SQLTELEMETRY") -and
    -not ($_.SqlServerService -eq "SQLWriter") } | Format-Table | Out-String | ForEach-Object { Write-Host $_ }
  Write-Debug "Done!"
  # wait for input before closing if running in console
  # adapted from https://blog.danskingdom.com/keep-powershell-console-window-open-after-script-finishes-running/
  If ($Host.Name -eq "ConsoleHost") {
    Write-Host "Press any key to continue..."
    $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyUp") > $null
  } Else {
    # return successfully
    # environment error code will equal zero by default
    Exit
  }
}
```
