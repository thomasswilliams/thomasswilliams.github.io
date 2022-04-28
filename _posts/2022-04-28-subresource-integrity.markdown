---
layout: post
title:  "Notes to self: Calculating an SRI hash for javascript and CSS files"
date:   2022-04-28 12:00:00 +1000
categories: development
---
_Posting this here as I often end up searching the web to remember what I once knew..._

Subresource Integrity (SRI) hashes are an optional web browser security feature to ensure that javascript and/or CSS files, tested during development, are not altered after deployment. "Altered" covers legitimate - for example, in the case of a version change - or malicious purposes. The nitty-gritty behind SRI hashes can be found at <https://developer.mozilla.org/en-US/docs/Web/Security/Subresource_Integrity> and <https://www.w3.org/TR/SRI/>.

The SRI hash is a "cryptographic digest" of the file, which is then base64 encoded. An SRI hash looks like a long string of nonsense including upper- and lower-case letters, numbers and some symbols. SRI hashes work because the web browser fetches the file, then calculates a hash, then compares the calculated hash to the SRI hash. If the hashes are different, the file will not be loaded and the error will be logged in the web browser console.

The SRI hash is implemented as an attribute in a HTML tag for the javascript or CSS file called "integrity":

```html
<!-- HTML script tag -->
<script src="file.js" integrity="..." crossorigin="anonymous"></script>
<!-- HTML CSS tag -->
<link rel="stylesheet" href="file.css" integrity="..." crossorigin="anonymous" />
```

It's an easy to use and free security improvement for development. I find the feature important as third-party files are so useful in web development - often loading from a CDN is faster and more reliable than loading from a local web server - and I want to ensure any web pages which use third-party files are using the files I expect, and nothing more.

The SRI Hash Generator web site at <https://www.srihash.org/> is great for javascript and CSS files which are publicly accessible - you paste a URL and the site will generate the entire HTML tag.

An alternative to the SRI Hash Generator web site is to calculate your own SRI hashes, which is a fantastic option for intranet, development, or other local or private scenarios.

Here's the steps I've used on Windows 10 (adapted from <https://www.srihash.org/>):

- (first time set up only) download OpenSSL - I used latest binaries as at April 2022 from <https://kb.firedaemon.com/support/solutions/articles/4000121705-openssl-3-0-and-1-1-1-binary-distributions-for-microsoft-windows>
  - extract entire appropriate directory from the zip file (in my case, _\x64\bin\_) to new directory e.g. _C:\OpenSSL_
    - you don't really need the `*.pdb` files
- copy the file to get an SRI hash for (for simplicity, I've used _file.js_ as an example, same process for CSS files) to directory above (e.g. _C:\OpenSSL_)
- from a command prompt in the directory where you copied the file to (AKA where the OpenSSL binaries are, _C:\OpenSSL_), run:

```bash
openssl dgst -sha512 -binary file.js | openssl base64 -A
```

- copy the output from the command to the "integrity" attribute of HTML script/CSS tag, prefaced with "sha512-" e.g. `integrity="sha512-<output from command>"`
- include the "crossorigin" attribute in the HTML tag e.g. `crossorigin="anonymous"`

You'll end up with a HTML script or CSS tag that looks like the example at the top of this blog post.

Lastly, I found running the command from a PowerShell prompt got a different (unusable) hash than the command line - so I'd recommend sticking to a command prompt.