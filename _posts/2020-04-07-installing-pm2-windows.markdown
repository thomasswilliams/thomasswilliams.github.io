
---
layout: post
title:  "Notes to self: installing PM2 on Windows, as a service"
date:   2020-04-07 17:20:00 +1000
categories:
---
[PM2](https://pm2.keymetrics.io/) is "...a production process manager for Node.js applications with a built-in load balancer. It allows you to keep applications alive forever, to reload them without downtime and to facilitate common system admin tasks...".

I use PM2 to run and monitor Express apps. Below is a quick list of steps I follow to install PM2 (version 4.2.3 at time of writing) on Windows and run as a Windows service, tested on Windows Server 2016.

Implied is my "works for me" disclaimer at the bottom of this post - these steps are not the only or best way to install PM2 on Windows, but work for me and might hopefully be useful to someone else :-)

1. create a local administrator on the Windows server e.g. *PM2Admin*

2. log in as the local administrator (all the steps below are performed as as the local administrator created in step 1 unless specified)

    - why? as at early 2020, installing globally using npm saves to a user's profile. I've found it best to log in as that specific user to perform all PM2 actions.

3. if not already done, install [Node.js](https://nodejs.org/en/)

4. from a command prompt (may need to be an administrative command prompt depending on how the Windows server is set up), install PM2 globally as per <https://pm2.io/doc/en/runtime/guide/installation>: `npm install -g pm2`

5. create a PM2 directory, for example *C:\pm2*

6. create an environment variable "PM2_HOME" pointing at directory created in step 5 (e.g. *C:\pm2*) as per <https://blog.cloudboost.io/nodejs-pm2-startup-on-windows-db0906328d75>

7. restart the server, log in again as the local administrator created in step 1

8. test PM2 by running `pm2 save` from a command prompt before installing the Windows service below

9. as per <https://blog.cloudboost.io/nodejs-pm2-startup-on-windows-db0906328d75>, from a command prompt, install *pm2-windows-service* globally: `npm install -g pm2-windows-service`

10. if there's issues installing or running *pm2-windows-service*, may need to update old dependency as per <https://github.com/jon-hall/pm2-windows-service/issues/51#issuecomment-532066926>

11. from a command prompt, run `pm2-service-install -n PM2`, and answer questions as below:

```bash
? Perform environment setup (recommended)? Yes
? Set PM2_HOME? Yes
? PM2_HOME value (this path should be accessible to the service user and should not contain any “user-context” variables [e.g. %APPDATA%]): C:\pm2
? Set PM2_SERVICE_SCRIPTS (the list of start-up scripts for pm2)? No
? Set PM2_SERVICE_PM2_DIR (the location of the global pm2 to use with the service)? [recommended] Yes
? Specify the directory containing the pm2 version to be used by the service C:\USERS\<USER>\APPDATA\ROAMING\NPM\node_modules\pm2\index.js
```

12. a Windows service called "PM2" should now be configured and can be managed & started using Services Manager

13. reminder: files in the *C:\pm2* directory should not be edited

14. (optional) can install PM2 log rotate module from a command prompt (see <https://github.com/keymetrics/pm2-logrotate> for more info): `pm2 install pm2-logrotate`

15. may need a process to clean up PM2 log rotate logs themselves, such as the following PowerShell snippet:

```powershell
Get-ChildItem -Path 'C:\pm2\logs\*' -Include 'pm2-logrotate-out__*.log' | Where-Object { $_.LastWriteTime -lt (Get-Date).AddMonths(-1) } | Remove-Item
```

<div markdown="1" class="note">
**Thomas's "but it worked for me" disclaimer:** before using any code you find on the internet, especially on this blog, take time to understand what the code does and test, test, test. I'm not responsible for damage caused by code from this blog, and don't offer any support or warranty.
</div>
