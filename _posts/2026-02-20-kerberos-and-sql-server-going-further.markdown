---
layout: post
title:  "Kerberos and SQL Server in 2026"
date:   2026-02-20 12:00:00 +1100
categories: sqlserver
---

I spent a bit of time recently tracking down NTLM Event log warnings relating to SQL Server.

NTLM is an older Windows authentication protocol, largely superseded by Kerberos.

Kerberos is used when certain conditions are met; otherwise, Windows authentication silently falls back to NTLM. This is important in 2026 because Microsoft has announced that new versions of Windows desktop and Windows Server will no longer support NTLM.

I'm not the only DBA following up on NTLM - last week I read a blog post covering NTLM, Kerberos, and Service Principal Names (SPNs) at <https://www.sqlfingers.com/2026/02/microsoft-is-killing-ntlm-heres-what.html> (via [Kevin at Curated SQL](https://curatedsql.com/2026/02/13/tips-on-a-post-ntlm-future/)).

To ensure clients connect to SQL Server using Kerberos:

- SQL Server must run under a domain account (the same account on all servers, if using Windows Clusters)
- connections must use host names, not IP addresses
- the client driver must support Kerberos
- if using Availability Groups, two SPNs must be created manually for the Availability Group _Listener_ like:

```bash
setspn -S HOST\<Availability Group Listener>:1433 <SQL Server domain account>
setspn -S HOST\<Availability Group Listener>.domain.name:1433 <SQL Server domain account> # FQDN
```

The second SPN creation command is for the Fully-Qualified Domain Name (FQDN) for the SQL Server Listener. You'll need both, and the commands should be tweaked for your environment (and port). Say the SQL Server domain account is `MYDOMAIN\SqlProd`, and your listener is `SQL-2022-LISTEN`, the commands would look like:

```bash
setspn -S HOST\SQL-2022-LISTEN:1433 MYDOMAIN\SqlProd
setspn -S HOST\SQL-2022-LISTEN.mydomain:1433 MYDOMAIN\SqlProd # FQDN
```

That covers clients connecting to SQL Server. But what about servers SQL Server connects to?

## Backup

If you back up databases over the network (and you should), SQL Server may authenticate using NTLM.

You can see this by enabling NTLM Event logging on your backup server in the registry by adding a DWORD `AuditReceivingNTLMTraffic` and setting the value to 1 under **HKLM\SYSTEM\CurrentControlSet\Control\Lsa\MSV1_0** as per <https://dirteam.com/sander/2022/06/15/howto-detect-ntlmv1-authentication/>. Then, use Event Viewer and look for warnings under **Microsoft > Windows > NTLM > Operational**.

In my case, NTLM was being used because the backup server was referenced via a DNS CNAME. The fix was for a domain admin to manually register two SPNs for the CNAME, under the host:

```bash
setspn -S HOST\<CNAME> <host/target>
setspn -S HOST\<CNAME>.domain.name <host/target> # FQDN
```

For example, if my CNAME is `backup`, and the server the CNAME is pointing to is `FILESERVER1`, the commands would be:

```bash
setspn -S HOST\backup fileserver1
setspn -S HOST\backup.mydomain fileserver1 # FQDN
```

It may take some time for SPN changes to propagate through the domain (in my case, around 25 minutes).

You can list the SPNs, including the manual ones for CNAMEs, belonging to a host with:

```bash
setspn -L <host/target> # e.g. fileserver1
```

Alternatively, you can query for the SPN for the DNS CNAME using:

```bash
setspn -Q HOST\<CNAME>.domain.name # e.g. HOST\backup.mydomain
```

If the backup server changes and the CNAME is repointed, the SPN will need to be removed and recreated to maintain Kerberos authentication.

## Availability Group File share witness

The other SQL Server–related NTLM warning came from a file share witness used by an Availability Group. Once again, a CNAME was in use, so the fix was the same - create two SPNs for the CNAME, one with the FQDN:

```bash
setspn -S HOST\<CNAME> <host/target>
setspn -S HOST\<CNAME>.domain.name <host/target> # FQDN
```

With those two issues resolved, there were no further NTLM warnings related to SQL Server.
