---
layout: post
title:  "Leaflet production considerations (part 4)"
date:   2022-06-07 12:00:00 +1000
categories: development
---

This post is the final of my short series on web development of an an Antarctic map using [Leaflet](https://leafletjs.com/) (see [part 1 where I create the map]({% post_url 2022-05-02-leaflet-antarctica-demo %}), [part 2 which adds loading a shapefile]({% post_url 2022-05-19-leaflet-antarctica-demo-2 %}), and [part 3 which covers displaying GeoJSON points as labels]({% post_url 2022-06-02-leaflet-antarctica-demo-3 %})).

The completed Leaflet map is at <https://thomasswilliams.github.io/leaflet-antarctic-demo/>, and the repository with the code (most of which is in a single `index.html` file) is at <https://github.com/thomasswilliams/leaflet-antarctic-demo>.

I won't be adding anything to the map in this post. Instead, I'll cover a few things to think about to make the map web site "production ready". These factors don't _just_ apply to Leaflet. As you read through the list, you'll probably recognise features that some of your favorite map sites or web sites in general have implemented; "quality of life"-type improvements. Others will make a difference to the team that needs to support a production map:

- 1-pixel gap between tiles: could be addressed with code like <https://github.com/Leaflet/Leaflet.TileLayer.NoGap>
- browser dark mode: for instance, <https://gist.github.com/BrendonKoz/b1df234fe3ee388b402cd8e98f7eedbd>
- browser pre-connect to CDN: need code like below in the `index.html` head (suggest same for tiles):

```html
<!-- pre-connect to CDN, also with crossorigin -->
<link rel="preconnect" href="https://unpkg.com">
<link rel="preconnect" href="https://unpkg.com" crossorigin>
```

- Lighthouse score: Lighthouse is a Chrome browser feature that will highlight performance issues (some of which are in my list), see <https://github.com/GoogleChrome/lighthouse>
- webhint score: _"webhint helps you improve your site's accessibility, speed, cross-browser compatibility, and more by checking your code for best practices and common errors."_ <https://webhint.io/>
- browser style differences: may need a basic CSS reset
- error handling: gracefully letting the user know if files can't be loaded
- noscript tag: display a message to users that do not have javascript enabled, such as <https://stackoverflow.com/a/22744494>
- accessibility (arrow keys for map, plus/minus zoom): a handy checker is the WAVE Web Accessibility Evaluation Tool at <https://wave.webaim.org/>
- optimise images (e.g. PNGs): use a web site like <https://tinypng.com/>
- permalinks: allows users to return to the same place on a map (zoom level & coordinates), suggest Leaflet plugin <https://github.com/MarcChasse/leaflet.Permalink>
- HTTPS: keep your users safe
- HTTP/2: faster serving of files
- linting javascript: I recommend [ESLint](https://eslint.org/) - the aim is more readable, and maintainable, code
- testing for browser compatibility: including mobile devices, based on your audience...and a lot of testing
- keeping dependencies up-to-date: for instance, new versions of Leaflet or plugins
- web site analytics
- security (for instance, who can change the source code)
- branding e.g. logo, an about page, favicons: see example watermark at <https://leafletjs.com/examples/extending/extending-3-controls.html>
- bundling scripts, minifying, obfuscating
- loading scripts as async/defer, web workers: see recent article ["Don’t sink your website with third parties" at Smashing Magazine](https://www.smashingmagazine.com/2022/06/dont-sink-website-third-parties/)

Hopefully the list (while not comprehensive) is helpful. Enjoy making maps! And keep an eye on new developments like Felt <https://felt.com/>.