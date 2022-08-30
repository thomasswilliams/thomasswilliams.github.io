---
layout: post
title:  "Passing a query string value to R Markdown"
date:   2022-08-19 12:00:00 +1000
categories: ['development', 'R']
---

Even though I'm an R rookie, I've appreciated R Markdown (R files with an `.Rmd` extension) for easy single page interactive "reports" that can combine inputs, tables, charts and more. In this post, I'll describe how I pass & read values from a query string in R Markdown, which works on a development computer with RStudio or on a Shiny server.

The code below has been tested with a recent version of RStudio (August 2022), running R version 4.2.0. R Markdown can be output to many different formats, I'm most interested in web pages and haven't tried this code with PDF, Word or other outputs.

As background, a query string is part of a web page address. Query strings are used to pass information to web pages, in name/value pairs separated by an equals sign - for instance, <code>user<span style="background-color:#ffcc0033">=</span>Andrew</code> or <code>country<span style="background-color:#ffcc0033">=</span>au</code>. Name/value pairs are themselves separated by ampersands, so passing multiple values looks like <code>user<span style="background-color:#ffcc0033">=</span>Andrew<span style="background-color:#ccff0055">&</span>country<span style="background-color:#ffcc0033">=</span>au</code>.

Back to R Markdown: in specially-formatted header text (also known as YAML front-matter), default values for parameters can be defined like below. In addition to RStudio, the "shiny" and "rmarkdown" packages are required, and the file name - which will be important soon - is `test.Rmd`:

````R
---
title: "test.Rmd"
output: html_document
runtime: shiny
params:
  name: "Sam"
---

```{r echo = FALSE}
cat("Parameter \"name\" is", params$name)
```
````

Save and run `test.Rmd`, and you'll see something like:

`## Parameter "name" is: Sam`

The code above says the output should be a web page, calling Shiny, and to display the value of the "name" parameter (referenced as `params$name`). If you want to know more, the _definitive_ guide to parameters in R Markdown is at <https://garrettgman.github.io/rmarkdown/developer_parameterized_reports.html> which covers parameter types, ranges and more about the user interface.

Next, let's read from the query string (even though it's initially empty) and put it into a variable called `name`. Add the code below to `test.Rmd`:

````R
```{r echo = FALSE}
# get the value of query string parameter "name"
# if missing, will be NULL
# "session$" is special Shiny variable (ignore "no variable...in scope" warning)
# needs to be wrapped in reactive
name <- shiny::reactive(shiny::parseQueryString(session$clientData$url_search)[["name"]])
# output value of query string parameter "name"
# need special syntax to get at reactive value, see
# https://mastering-shiny.org/reactive-motivation.html
cat("Query string \"name\" is:", shiny::isolate(name()))
# can test if we have a value using is.null
cat("Query string \"name\" is null?", is.null(shiny::isolate(name())))
```

<!-- output a link to take us to this same page, with a query string "name" of "Bob" -->
<h2><a href="test.Rmd?name=Bob">Click to pass query string "name" of "Bob"</a></h2>
````

If you run `test.Rmd` now, nothing much has changed. The default "name" parameter `params$name` is still "Sam" (we can't change that), and there's no query string "name" value. Click on the link at the bottom of the page, though, and the page will load and display:

`## Query string "name" is: Bob`

`## Query string "name" is null? FALSE`

The magic is done by Shiny's [session\$clientData\$url_search](https://shiny.rstudio.com/articles/client-data.html) and using [reactive](https://shiny.rstudio.com/articles/reactivity-overview.html) and [isolate](https://shiny.rstudio.com/articles/isolation.html) calls to glue it all together in R Markdown.

This approach is useful to set a default value as well as allow passing values, and could be built on to dynamically link from one R Markdown file to another.