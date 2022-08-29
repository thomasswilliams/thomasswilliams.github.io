---
layout: post
title:  "Toggling dark mode in R Markdown"
date:   2022-08-30 12:00:00 +1000
categories: development R
---

In my last R post I described [how to automatically detect dark mode in a web-based R Markdown file]({% post_url 2022-08-26-r-markdown-dark-mode-1 %}). In this post, I'll add a toggle between dark and light mode, and store the user's choice in browser local storage.

As before, the code in this post can be used with any existing R Markdown light theme, by overriding hard-coded colors to a CSS variable as per the last post.

The end result (at <https://github.com/thomasswilliams/r-markdown-snippets/blob/main/toggle-dark-mode.Rmd> if you want to skip straight to the code) looks like either the left or right half of:

![Toggle dark mode screenshot](/images/toggle-dark-mode-aug-2022.png)

First, the CSS is different from earlier as dark mode receives its own "dark" class on the HTML document. This simplifies the CSS while still using CSS variables (see the [R Markdown file for the CSS](https://github.com/thomasswilliams/r-markdown-snippets/blob/main/toggle-dark-mode.Rmd)).

The next difference is a link in the top right-hand corner which dynamically toggles between light and dark mode using javascript. The link has an id of `light-toggle`, adapted from code at <https://github.com/dandalpiaz/markdown-pages>:

```html
<!-- link to toggle between dark & light mode; default is light, so initial text should read "Dark"
     adapted from https://github.com/dandalpiaz/markdown-pages -->
<a href="#" role="button" onclick="toggleLight();return false;" id="light-toggle" class="contrast">🌗 Dark</a>
```

The last piece is using javascript to a) toggle the theme and b) detect dark mode using the system setting and local storage:

```js
// function to toggle between light and dark mode
// adapted from https://github.com/dandalpiaz/markdown-pages
function toggleLight(forceDark) {
  // get current theme (default to "light" if not found)
  let current_theme = localStorage.getItem('mode') || 'light';
  // set new theme to "dark" if current is "light"
  let new_theme = (current_theme === 'light') ? 'dark' : 'light';
  // special case: if "forceDark", set new theme to "dark"
  if (forceDark) {
    current_theme = 'light';
    new_theme = 'dark';
  }
  // HTML document element
  const htmlEl = document.documentElement;
  // add class name for new theme to HTML element
  htmlEl.classList.add(new_theme);
  // remove class name of old theme from HTML element
  htmlEl.classList.remove(current_theme);

  // set local storage to new theme
  localStorage.setItem('mode', new_theme);

  // update theme switcher toggle with id of "light-toggle"
  if (new_theme === 'dark') {
    document.getElementById('light-toggle').innerHTML = '🌗 Light';
  } else {
    document.getElementById('light-toggle').innerHTML = '🌗 Dark';
  }
}

// set theme on load, adapted from https://radek.io/posts/secret-darkmode-toggle/
// first check "prefers-color-scheme"
const osPreference = window.matchMedia('(prefers-color-scheme: dark)').matches ? 'dark' : 'light';
// next check local storage
const preferredTheme = localStorage.getItem('mode') || osPreference;
// if preferred theme is dark, force theme change, else leave as-is
if (preferredTheme === 'dark') {
  toggleLight(true);
}
```

As a side note, CSS and javascript can easily be added to R Markdown files using three back-ticks and a code type of `{css}` or `{js}` (add `echo = FALSE` to hide the code but still output it to the page).

I hope you'll find a use for the CSS, HTML and javascript discussed in this post in your own R Markdown files.