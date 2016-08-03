---
layout: post
title:  "Why you shouldn't use Bootstrap"
date:   2016-08-03 21:00:00 +1000
categories:
---
<div style='margin-bottom:10px' about='https://farm4.static.flickr.com/3258/2809583137_1f0e6ef808.jpg'><a href='https://www.flickr.com/photos/fotosbyflick/2809583137/' target='_blank'><img xmlns:dct='http://purl.org/dc/terms/' href='http://purl.org/dc/dcmitype/StillImage' rel='dct:type' src='https://farm4.static.flickr.com/3258/2809583137_1f0e6ef808.jpg' alt='deviant-204-hp by Aflickion, on Flickr' title='deviant-204-hp by Aflickion, on Flickr' border='0'/></a><br/><small>&quot;<a href='https://www.flickr.com/photos/fotosbyflick/2809583137/' target='_blank'>deviant-204-hp</a>&quot;&nbsp;(<a rel='license' href='https://creativecommons.org/licenses/by/2.0/' target='_blank'>CC BY 2.0</a>)&nbsp;by&nbsp;<a href='https://www.flickr.com/people/fotosbyflick/' target='_blank'>&nbsp;</a><a xmlns:cc='http://creativecommons.org/ns#' rel='cc:attributionURL' property='cc:attributionName' href='https://www.flickr.com/people/fotosbyflick/' target='_blank'>Aflickion</a></small></div>

Sometimes I need to create websites to be used internally. I've experimented with a couple of CSS frameworks but found I was most productive, quickest, with [Bootstrap][1]. Below are the most common for and against points I've come across in numerous discussions and internet posts:

### Why you __shouldn’t__ use Bootstrap:

- you only need a few simple styles
- you don’t want your website to look like “yet another Bootstrap web site" e.g. <https://news.ycombinator.com/item?id=11287413>
- you’d rather spend time crafting, debugging and improving your own framework (when developing a website of more than just a landing page, you need structure and reusability in your styles e.g. a “framework”)
- you prefer an alternative framework like [Pure][3] or [Foundation][4]
- you want a "lighter touch", perhaps only a portion of what Bootstrap has to offer and don’t want the “bloat” around unnecessary, unused styles
- you're the only person working on the website
- you are either a) not targeting multiple devices and screen sizes or b) have a plan for multiple devices and screen sizes
- you don't want lock-in to a framework (or particular version)
- you're being paid to design web sites
- you want your website to look different or innovative
- you don't want to add additional classes for styling e.g. "col-md-x", "row" etc.
- you're already using a competing framework (sometimes frameworks can be "all or nothing" and may not play nicely with existing styles)

### Why you __[should][2]__ use Bootstrap:

- you want a professional, modern-looking website with a lot less effort than starting from scratch (these arguments can apply to other frameworks as well)
- you are not a designer
- you want to incorporate the result of 100s of hours of work and best practice
- you want the low-level layout taken care of (for the most part) so you can concentrate on solving problems
- you want a consistent and standard way to style your website/s - you want to be able to re-use styles between websites
- you want documentation
- you want a tested product
- you're creating a quick and dirty prototype that needs to look half decent; you may replace the framework later
- you want access to an ecosystem of themes and 3rd-party plugins such as date pickers, dropdown, carousels etc.
- you don't want to spend time debugging and updating the framework (Bootstrap *is* open source, though, just sayin')
- you want your website to "just work" with different devices and screen sizes

[1]: https://getbootstrap.com/
[2]: http://www.zingdesign.com/twitter-bootstrap-decision-time/
[3]: http://purecss.io/
[4]: http://foundation.zurb.com/
