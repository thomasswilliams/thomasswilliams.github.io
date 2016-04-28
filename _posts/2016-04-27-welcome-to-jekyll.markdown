---
layout: post
title:  "Starting with Jekyll"
date:   2016-04-27 20:34:45 +1000
categories: jekyll meta
---
I'm using Jekyll as the blog engine on this site.

I set up Jekyll by creating a repo on GitHub as per <https://pages.github.com/>, then installed and creating an empty blog by following steps at <https://jekyllrb.com/docs/quickstart/>.

Jekyll uses Markdown syntax (see <https://daringfireball.net/projects/markdown/syntax>), and posts start with a text block like:
{% highlight markdown %}
---
layout: post
title: "Blog post title here"
---
{% endhighlight %}

My workflow starts with editing the Jekyll site locally using the Brackets editor (posts are saved as individual files in the `_posts` directory, Jekyll is served locally at <http://localhost:4000/>), then syncing with the GitHub repo using GitHub Desktop for Mac. Special note: don't edit files in the `_site` directory - files here get overwritten with generated content.