---
layout: post
title:  "Notes to self: SignalR on IIS, behind a load balancer"
date:   2017-10-11 15:00:00 +1000
categories:
---
My quick notes on the tasks necessary to get a SignalR app working on multiple Windows Server 2012 IIS servers, behind a load balancer (in my case, Citrix NetScaler).

Detailed instructions are outside the scope of this blog post. I'm merely collecting all the steps and resources in one spot for my own future reference:

1. **in the dev environment (Visual Studio):** in the app, install the <tt>SignalR</tt> NuGet package from <https://www.nuget.org/packages/Microsoft.AspNet.SignalR/> (at time of writing, the version on NuGet was 2.2.2)

    * <p>installing the <tt>SignalR</tt> NuGet package will also install <tt>Microsoft.AspNet.SignalR.Core</tt>, <tt>Microsoft.AspNet.SignalR.JS</tt>, <tt>Microsoft.AspNet.SignalR.SystemWeb</tt>, <tt>Microsoft.Owin.Host.SystemWeb</tt>, <tt>Owin</tt>, <tt>Microsoft.Owin</tt>, <tt>Microsoft.Owin.Security</tt>, <tt>Newtonsoft.Json</tt>, etc.</p>

2. **in the dev environment:** add SQL Server backplane to SignalR as per <https://docs.microsoft.com/en-us/aspnet/signalr/overview/performance/scaleout-with-sql-server> by installing NuGet package <tt>Microsoft.AspNet.SignalR.SqlServer</tt> (version 2.2.2 if using SignalR 2.2.2 as above), configure and test

    * **in SQL Server**: if enabling Service Broker on the database as recommended in the article above, add trace flag `T4133` to suppress SQL Server error log warnings - see <https://norskale.zendesk.com/hc/en-us/articles/209686566-VUEM-abnormally-large-SQL-error-log-file>, <https://support.microsoft.com/en-us/help/958006/>

    * **in SQL Server**: create _and back up_ a master key in the database to fix SQL Server error log warnings `Service Broker needs to access the master key in the database 'xxx'. Error code:32. The master key has to exist and the service master key encryption is required.` - see <http://dotnetrobert.com/node/39>, <https://docs.microsoft.com/en-us/sql/t-sql/statements/backup-master-key-transact-sql>

3. **in the dev environment:** install the CORS OWIN NuGet package <tt>Microsoft.Owin.Cors</tt> to the app, and add CORS settings to the SignalR startup class as per <https://docs.microsoft.com/en-us/aspnet/signalr/overview/guide-to-the-api/hubs-api-guide-javascript-client#how-to-establish-a-cross-domain-connection> and <https://cmatskas.com/signalr-cross-domain-with-cors/>

4. **on the IIS servers:** add "WebSocket Protocol" to all IIS servers if not already enabled, using Server Manager > "Add roles and features" > "Web Server (IIS)" > "Web Server" > "Application Development" as per <https://stackoverflow.com/a/41892056>

5. **on the IIS servers:** deploy the app to all IIS servers

6. **on <u>one</u> IIS server:** at this point there will be an issue with different SignalR connection tokens on different IIS servers; to fix this, generate a machine key for the app's `web.config`, for example using IIS Manager; copy the machine key section (in `configuration` > `system.web` in the `web.config` file) to other IIS servers and back to the dev environment as per <https://stackoverflow.com/a/43479633>

    * <p>this is needed so the same machine key is deployed on all IIS servers behind the load balancer, and the machine key is not missed when the app is re-deployed</p>

7. **on the IIS servers:** also related to SignalR connection tokens, run the app pool for the app on all IIS servers as the same **domain** (not local) user as advised in <https://stackoverflow.com/a/43479633/116288>

There's additional SignalR troubleshooting tips at <https://docs.microsoft.com/en-us/aspnet/signalr/overview/testing-and-debugging/troubleshooting>.

<div markdown="1" class="note">
**Thomas's "but it worked for me" disclaimer:** before using any code you find on the internet, especially on this blog, take time to understand what the code does and test, test, test. I'm not responsible for damage caused by code from this blog, and don't offer any support or warranty.
</div>
