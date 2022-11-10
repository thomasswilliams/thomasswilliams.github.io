---
layout: post
title:  "QR codes in R Markdown"
date:   2022-11-10 12:00:00 +1100
categories: ['development', 'R']
---

This short demo gives options to display a QR code in an R Markdown web page - a technique which could also be used in a Shiny app.

Instead of using the R package [`qrcode`](https://thierryo.github.io/qrcode/) which utilises `plot()` and saving files, I wanted a lighter alternative - below are the two options I came up with, perhaps more suitable for web pages.

Option one makes use of a 3rd-party javascript file from <https://davidshimjs.github.io/qrcodejs/>. Once the javascript file is loaded, creating a QR code is as straightforward as calling a function, passing a HTML element and the data to be encoded (in this case, the URL `www.google.com`).

Option two is even simpler, using a HTML image element pointing to a Google Charts API passing the data to be encoded which returns the QR code (however, be aware this method is deprecated as at late 2022, and may not work in future).

When run, the QR codes are displayed in an R Markdown document as shown below. The full code can be found at my GitHub repo at <https://github.com/thomasswilliams/r-markdown-snippets/blob/main/qr-code.Rmd>, otherwise read on for an explanation of how both methods work:

![QR codes in R Markdown preview](/images/qr-code-r-markdown-preview-nov-2022.png)

## Using javascript

I mentioned you need a HTML element and a 3rd-party javascript file. First, the HTML element:

```html
<!-- HTML
     QR code div element
     note R Markdown looks to rename to "section-(original id)" -->
<div id="qrcode-js"></div>
```

One gotcha with loading the javascript file is to make sure it's loaded before calling the function. To achieve this, I adapted code from Stack Overflow at <https://stackoverflow.com/a/59041377>.

All the following javascript code needs to be in a `<script>` block in your R Markdown file:

```javascript
// javascript
// load 3rd-party script for javascript QR codes, then create a QR code in div "qrcode-js"
// dynamic load technique adapted from https://stackoverflow.com/a/59041377
// this is necessary as sometimes the script was not loaded before trying to generate a QR code
// this way we control loading the script *then* generating QR code

// create a script HTML element
const script = document.createElement("script");
// script source is javascript QR code file, hosted on GitHub
script.src = "https://cdn.rawgit.com/davidshimjs/qrcodejs/gh-pages/qrcode.min.js";
// add the script to the HTML document
document.body.appendChild(script);

// listen for the script to be loaded, then create QR code in div "qrcode-js"
script.addEventListener("load", function() {
  new QRCode(document.getElementById("section-qrcode-js"), "http://www.google.com");
});
```

## Using Google Charts

Below is the HTML image element used in the demo. See full docs at <https://developers.google.com/chart/infographics/docs/qr_codes>.

The URL for Google Charts API includes the data to be encoded; I've escaped the colon (replacing it with `%3A`):

```html
<img src="https://chart.googleapis.com/chart?chs=160x160&cht=qr&chl=http%3A//www.google.com&choe=UTF-8&chld=L|0" title="http://www.google.com"/>
```

The code above specifies an image 160 x 160 pixels, with no margins, and data (`chl` parameter) of `http://www.google.com`.
