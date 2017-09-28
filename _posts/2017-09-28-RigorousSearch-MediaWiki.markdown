---
layout: post
title:  "RigorousSearch MediaWiki extension updated for MediaWiki 1.28"
date:   2017-09-28 15:00:00 +1000
categories:
---
Recently I had a requirement at [my day job]({% post_url 2017-02-01-my-day-job-2017 %}) to improve the searchability of a locally-hosted MediaWiki wiki.

The wiki is around 400 pages with a handful of users; it was installed with vanilla MediaWiki (version 1.28) settings, writing to a MySQL 5.5 database on a Windows OS.

After sifting through some of the [available extensions](https://www.mediawiki.org/wiki/Category:Search_extensions) for search, I came across [RigorousSearch](https://www.mediawiki.org/wiki/Extension:RigorousSearch) which was designed to query the underlying MySQL database, and matched parts of words like `media` in `MediaWiki`.

RigorousSearch had a few things I liked: small footprint (one page of script), no reliance on anything other than PHP, and no changes to the database. It came with caveats though - the last update was several years and MediaWiki versions ago, the author [Johan the Ghost](https://www.mediawiki.org/wiki/User:JohanTheGhost) didn't recommend the extension for large wikis as it could be resource intensive, and he also mentioned it could potentially be really slow.

I eventually got RigorousSearch to work satisfactorily via a combination of trying "one more thing" and doing just enough to update the code to work with MediaWiki 1.28. I'm happy with how it turned and and have uploaded the result to <https://github.com/thomasswilliams/RigorousSearch-MediaWiki-extension-updated-for-MediaWiki-1.28>, trying to keep as much of that initial one-page script intact:

<div markdown="1" class="note">
**Thomas's "but it worked for me" disclaimer:** before using any code you find on the internet, especially on this blog, take time to understand what the code does and test, test, test. I'm not responsible for damage caused by code from this blog, and don't offer any support or warranty.
</div>
<br>

 - credit for the original code and idea to [Johan the Ghost](https://www.mediawiki.org/wiki/User:JohanTheGhost)
 - I've left most of the legacy code and comments, and kept the GNU license
 - I'm neither a PHP developer nor MediaWiki developer
   - so, there's probably better ways to do search in MediaWiki
 - there's no localisation (English only, sorry)
 - future changes to MediaWiki, PHP, MySQL or the OS *might* break this extension
 - there's lots of ways to improve this extension - unfortunately due to time constraints and other priorities, **I'm not able to maintain the extension**

That said, I hope someone can find a use for a lightweight, "cheap and cheerful" search extension, to suit more recent versions of MediaWiki.
