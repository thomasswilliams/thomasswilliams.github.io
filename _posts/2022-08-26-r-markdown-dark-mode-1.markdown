---
layout: post
title:  "Dark mode in R Markdown using prefers-color-scheme: dark"
date:   2022-08-26 12:00:00 +1000
categories: ['development', 'R']
---

Supporting your user's preference for dark mode in an interactive, web-based R Markdown file is straightforward. The ability is not (yet) built in to most themes. I'll show how to quickly add automatic dark mode to any theme in R Markdown.

If you want to skip straight to the finished product, check out `dark-mode.Rmd` at <https://github.com/thomasswilliams/r-markdown-snippets/blob/main/dark-mode.Rmd>.

I scoured articles on dark mode in _&lt;insert choice of technology here&gt;_, looking for code that was a) current and b) simple. I went with CSS variables, which have great support in modern browsers, adapted from <https://radek.io/posts/secret-darkmode-toggle/>.

First, we need to create CSS variables for light (default) and dark colors:

```css
/* specific colors for light and dark mode
   adapted from https://radek.io/posts/secret-darkmode-toggle/ */
:root {
  --background-color: #ffffff;
  --font-color: #24272B;
  /* can set other variables here as needed e.g. secondary font, secondary background etc. */
}
/* detect user preference colors
   adapted from https://radek.io/posts/secret-darkmode-toggle/ */
@media (prefers-color-scheme: dark) {
  :root {
    --background-color: #24272B;
    --font-color: #f6f6f6;
  }
}
```

Adding (or referencing) this CSS in an R Markdown file will have no effect, as at this stage it's merely _defining_  variables. Next we need to use the variables to override colors:

```css
/* override colors in R Markdown theme, with variables */
body {
  /* colors from variables - need "!important" so takes priority over settings elsewhere */
  background: var(--background-color) !important;
  color: var(--font-color) !important;
}
/* headings */
h1, h2, h3, h4, h5, h6, .h1, .h2, .h3, .h4, .h5, .h6 {
  color: var(--font-color) !important;
}
```

These few lines of CSS cover 80% of implementing automatic dark mode. The remaining 20% is identifying elements in the page that have explicit colors set by CSS, then overriding that with another color or variable. For example, here's the CSS I came up with while including a DT data table and Highcharter chart (with some specific styles for just dark mode, leaving light mode as-is):

```css
/* specific colors for light and dark mode
   adapted from https://radek.io/posts/secret-darkmode-toggle/ */
:root {
  --background-color: #ffffff;
  --font-color: #24272B;
  /* can set other variables here as needed e.g. secondary font, secondary background etc. */
}
/* detect user preference colors
   adapted from https://radek.io/posts/secret-darkmode-toggle/ */
@media (prefers-color-scheme: dark) {
  :root {
    --background-color: #24272B;
    --font-color: #f6f6f6;
  }
  /* any styles that should just apply to dark mode can be added here */
  /* hacky dark mode code blocks */
  pre {
    filter: invert(0.8);
  }
  /* make striped rows less conspicuous
     depending on version of data tables, may need one or more of the following selectors */
  .table-striped > tbody > tr:nth-of-type(odd),
  table.dataTable.stripe tbody tr.odd,
  table.dataTable.display tbody tr.odd {
    background-color: #f9f9f911;
  }
  /* hover rows less conspicuous */
  .table-hover > tbody > tr:hover,
  table.dataTable.hover tbody tr:hover,
  table.dataTable.display tbody tr:hover {
    background-color: #f5f5f522 !important;
  }
}

/* override colors in R Markdown theme, with variables */
body {
  /* colors from variables - need "!important" so takes priority over settings elsewhere */
  background: var(--background-color) !important;
  color: var(--font-color) !important;
}
/* headings */
h1, h2, h3, h4, h5, h6, .h1, .h2, .h3, .h4, .h5, .h6 {
  color: var(--font-color) !important;
}

/* data tables div */
div.datatables {
  color: var(--font-color) !important;
}
/* table rows */
table.dataTable tbody tr {
  background-color: var(--background-color);
}
/* number of records */
.dataTables_info {
  color: var(--font-color) !important;
}
```

The R Markdown file can be found at <https://github.com/thomasswilliams/r-markdown-snippets/blob/main/dark-mode.Rmd>.

Another option for dark mode in R Markdown is via a pre-made dark theme, such as `downcute chaos` from <https://juba.github.io/rmdformats/articles/examples/downcute_chaos.html>.

**Further reading:**

- <https://radek.io/posts/secret-darkmode-toggle/>
- <https://speckyboy.com/css-javascript-snippets-dark-light-mode/>
- <https://dev.to/ananyaneogi/create-a-dark-light-mode-switch-with-css-variables-34l8>
- <https://dev-tips.com/css/dark-mode-in-css>