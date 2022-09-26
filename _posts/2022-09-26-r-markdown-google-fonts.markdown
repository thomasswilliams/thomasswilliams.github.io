---
layout: post
title:  "Use Google Font in R Markdown web page"
date:   2022-09-26 12:00:00 +1000
categories: ['development', 'R']
---

Setting a different font is a minor tweak to an R Markdown file that might help it fit better with a corporate or company look. Google Fonts is an industry-accepted method to reference fonts on web pages and can be used with R Markdown rendered by Shiny. There’s no need to download anything while developing the R Markdown file in RStudio, or viewing it in a web browser from a Shiny server.

I’ve recently used this technique to integrate the "Atkinson Hyperlegible" font, a font with "…greater legibility and readability for low vision readers…" from <https://brailleinstitute.org/freefont>. Since Shiny themes already specify a font, the steps below show how to override that with the Google Font, demo'd with the `spacelab` Shiny theme.

The full code can be found on my GitHub R Markdown snippets repo at <https://github.com/thomasswilliams/r-markdown-snippets/blob/main/google-fonts.Rmd>.

## Get the Google Font link

This is the HTML code to paste into the R Markdown file, for example `<link href="https://fonts.googleapis.com/css2?family=Lobster&display=swap" rel="stylesheet">`.

- go to Google Fonts <https://fonts.google.com/>
- click on a font (I clicked on Lobster) <https://fonts.google.com/specimen/Lobster>
- go to the "Type tester" tab in the toolbar and select styles ("Lobster" has only regular, but other fonts may have additional "bold", "italic", or "bold italic" styles)
- copy just the link from the panel at right

You can get further detail on referencing Google Fonts at <https://developers.google.com/fonts/docs/getting_started>.

## Include the Google Font link in an R Markdown file

Copy-paste to the start of the R Markdown file, after the YAML front matter. As the link is HTML code, you won't see anything on the page when you click "Run Document".

## Override the original Shiny theme font, everywhere it’s mentioned, with new font name in CSS

Now the font is referenced, it's time to use it. To do so, I suggest adding the new font name before any existing font names in CSS, so there’s a fallback. For instance, in the `spacelab` theme, "Open Sans" is the first font in the font stack. The new font stack will be "Lobster", then a comma, then "Open Sans", then the rest of the existing fonts.

Before:

```css
font-family: "Open Sans", "Helvetica Neue", Helvetica, Arial, sans-serif;
```

After:

```css
font-family: Lobster, "Open Sans", "Helvetica Neue", Helvetica, Arial, sans-serif;
```

You'll need to do this everywhere a font is referenced in the theme (I did a search on the theme CSS file for "font"). The final custom CSS code in the R Markdown file, specific to the `spacelab` theme, is:

````R
```{css, echo = FALSE}
/* override font family with new font family
   need to override all places "spacelab" theme explicitly sets fonts */
body {
  /* new font "Lobster", add to start of "spacelab" stack
     Google Fonts link needs to be referenced elsewhere */
  font-family: Lobster, "Open Sans", "Helvetica Neue", Helvetica, Arial, sans-serif;
}
h1, h2, h3, h4, h5, h6, .h1, .h2, .h3, .h4, .h5, .h6 {
  font-family: Lobster, "Open Sans", "Helvetica Neue", Helvetica, Arial, sans-serif;
}
.tooltip, .popover {
  font-family: Lobster, "Open Sans", "Helvetica Neue", Helvetica, Arial, sans-serif;
}
```
````

## Bonus step: set Highcharter charts to use the Google Font

Normal text and DT DataTables pick up the Google Font without special code. Highcharter charts require two additional steps:

**Before rendering Highcharts, create a new theme**

```R
# create new Highchart theme with "Lobster" Google Font as per https://stackoverflow.com/a/64737095
# as at Highcharter 0.9.4 (Sep 2022), this looks to create own Google Fonts link in
# older style e.g. https://fonts.googleapis.com/css?family=Lobster
# so, new fonts may not be available using this method
new_font_theme <- highcharter::hc_theme(
  chart = list(
    style = list(
      # set just new font name
      fontFamily = "Lobster"
    )
  )
)
```

**Explicitly set the theme when rendering the Highchart**

```R
highcharter::highchart() %>%
  # set theme as per https://stackoverflow.com/a/64737095
  highcharter::hc_add_theme(new_font_theme) %>%
  …
```

If you have more than one Highchart on the page, each will need the theme explicitly set.

Check out the finished code at <https://github.com/thomasswilliams/r-markdown-snippets/blob/main/google-fonts.Rmd>. A more complete solution to changing fonts in R Markdown might be to make your own theme or use theme-specific libraries like `thematic` at <https://rstudio.github.io/thematic/articles/auto.html>.
