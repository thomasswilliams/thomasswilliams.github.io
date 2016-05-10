---
layout: post
title:  "My .gitignore template"
date:   2016-05-09 19:38:00 +1000
categories: 
---
**TL;DR: the best resources for creating a .gitignore template are GitHub's own well-maintained repo at <https://github.com/github/gitignore>, and the generator at [gitignore.io][1].**
 
I switched to Git from Subversion recently and have been getting my head around .gitignore templates. My current .gitignore template is simple, yet hopefully broad enough to re-use with few changes across my two primary development tools, Visual Studio 2015 and SQL Server Management Studio.
 
I'm a fan of having a .gitignore template in each repository – though this does not seem to be universal practice. 

I commit the .gitignore template to Git so that other developers who use the repository a) don't get build artefacts from my machine and b) don't commit build artefacts like the `bin` and `obj` folders, and NuGet and NPM folders. Subversion had a "global ignore pattern" which served a similar purpose but needed to be set up on each machine. 

My particular .gitignore template at the bottom of this post is adapted from from <https://gist.github.com/tobinharris/114476> and <https://gist.github.com/kmorcinek/2710267>, and pared down from probably the best resource, [gitignore.io][1] (which looks like it uses GitHub's own .gitignore template): <https://www.gitignore.io/api/visualstudio>

Some .gitignore templates can be really large. Check out <https://gist.github.com/jiahao/8b19775cee3a6d51706acf0a8c0ec376> for comparisons between .gitignore templates from major programming languages.

```
#Visual Studio files
.vs/
[Bb]in/
[Oo]bj/
*.suo
*.ssms_suo
*.sqlsuo
*.pdb
*.bak
*.user
#Visual Studio conversion files
_UpgradeReport_Files/
Backup*/
UpgradeLog*.xml
UpgradeLog*.htm
#OS
[Tt]humbs.db
.*~
*~
#Subversion
.svn
#Dependency directories
node_modules
bower_components
packages
#Others
```

[1]: https://www.gitignore.io/