---
layout: post
title:  "Set keyboard focus to a control in R Markdown & Shiny"
date:   2022-09-18 12:00:00 +1000
categories: ['development', 'R']
---

It is possible - though not the default - set set keyboard focus on load to a control in an R Markdown web page rendered with Shiny.

Setting keyboard focus when an R Markdown page is loaded is beneficial to users, who can start interacting with the page without having to first click the control. Not all users will interact with web pages with a mouse, and [Web Content Accessibility Guidelines (WCAG) for "focus"](https://www.w3.org/WAI/WCAG21/Understanding/focus-visible.html) mention:

> ...It must be possible for a person to know which element among multiple elements has the keyboard focus...

> ...This Success Criterion helps anyone who relies on the keyboard to operate the page, by letting them visually determine the component on which keyboard operations will interact at any point in time...

The snippet below sets focus to a control on a R Markdown web page using [jQuery](https://jquery.com/), which is bundled with Shiny. The principle is the same no matter the type of control - I've put together a demo with a text control, Selectize dropdown and normal dropdown at <https://github.com/thomasswilliams/r-markdown-snippets/blob/main/set-focus-for-keyboard-tabbing.Rmd>.

Setting focus is straightforward once you know the control's HTML element identifier. The jQuery code is called after a slight delay, which gives the page time to render (the [R Markdown docs mention you can't rely on traditional browser page load events](https://shiny.rstudio.com/articles/packaging-javascript.html#r-markdown-only-use-a-js-chunk>)):

````R
```{r, echo = FALSE}
# text input, will result in HTML input with id of "text_input"
shiny::textInput("text_input", "Text input")
```
````

````R
```{js}
// set focus to control with id of "text_input" after 800 milliseconds
// "#" in jQuery, like CSS, means a single HTML element with that id
// delay is useful as gives controls time to render, may need to adjust time to taste
setTimeout(function() {
  $("#text_input").focus();
}, 800);
```
````

Open the [GitHub demo in RStudio](https://github.com/thomasswilliams/r-markdown-snippets/blob/main/set-focus-for-keyboard-tabbing.Rmd) to see the above at work. Some things to keep in mind:

- a Selectize dropdown, when focused, drops down the list which may not be what you want
- a select dropdown, when focused, will only drop down the list on click or space bar/down arrow press
- the experience will be different on mobile devices where users may expect to tap into and out of a control
- different R Markdown themes will have different focus highlight (typically provided by the Bootstrap theme, the demo uses `spacelab`)
