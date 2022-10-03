---
layout: post
title:  "Debouncing input in R Markdown"
date:   2022-10-03 12:00:00 +1100
categories: ['development', 'R']
---

This R Markdown snippet demonstrates "debouncing": waiting until a user stops changing an input, before updating dependent charts and tables. Debouncing is often used in web sites to prevent the user interface "jumping" as data is being entered, especially when the update takes a noticeable amount of time - for instance calling an API or database, or doing a calculation.

Done well, debouncing can make updates using inputs - such as typing in a search box - feel more natural, and make web pages feel more responsive rather than waiting on multiple updates to finish.

The R documentation at <https://rstudio.github.io/shiny/reference/debounce.html> explains:

> Transforms a reactive expression by preventing its invalidation signals from being sent unnecessarily often. This lets you ignore a very "chatty" reactive expression until it becomes idle, which is useful when the intermediate values don't matter as much as the final value, and the downstream calculations that depend on the reactive expression take a long time.

I adapted the documentation example and a forum post at <https://community.rstudio.com/t/trying-to-understand-how-to-use-debounce-in-shiny/47933> for R Markdown. The main difference is that instead of using `input$input_name` (value) in an update, it is wrapped in a reactive and accessed via a `debounce` function:

```R
# R pseudocode
value <- reactive(input$input_name)
# debounced variable
# debounce time can be tuned - example set to 800 milliseconds
value_d <- value %>%
  debounce(800)

# accessing the debounced value needs to done via function (brackets after debounced variable name)
value_d()
```

The complete example is at <https://github.com/thomasswilliams/r-markdown-snippets/blob/main/debounce-input.Rmd>. Helpfully, debouncing is built in to Shiny and does not require additional packages.
