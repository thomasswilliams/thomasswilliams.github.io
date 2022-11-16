---
layout: post
title:  "Master/detail with dynamic hiding & showing in R Markdown"
date:   2022-11-16 12:00:00 +1100
categories: ['development', 'R']
---

R Markdown web pages are great for interactivity, with all the power of Shiny plus the ability (with a little creativity) for more complex workflows, often in just a single file. In this post I demonstrate a master/detail view in R Markdown - the end result looks like (available at my GitHub repo at <https://github.com/thomasswilliams/r-markdown-snippets/blob/main/master-detail.Rmd>):

![Master/detail R Markdown preview](/images/r-markdown-master-detail-nov-2022.gif)

Master/detail views are ubiquitous in software - a user interface technique to show a summary ("master") collection of data, and then on selection show further detail, in a popup, tree, or separate view. In real life, there's many uses for master/detail views, for instance editing detail for a selected item, displaying an image from a gallery, or displaying properties for an item in an online store.

This R Markdown demo is built on an answer from Stack Overflow at <https://stackoverflow.com/a/49989271>, to dynamically hide and show parts of an R Markdown file, and my earlier R snippet ["Passing a query string value to R Markdown"]({% post_url 2022-08-18-r-markdown-querystring %}).

After some setup, the first thing to do is check if the page was passed an "id" parameter in the query string, and if so, save as variable `detail_id`:

```R
# R
# were we passed an ID to show detail for? Initially NULL
detail_id <- NULL
# get (optional) passed detail ID in query string; may be missing
# "session$" is special Shiny variable, needs to be wrapped in reactive
qs_detail_id <- shiny::reactive(
  shiny::parseQueryString(session$clientData$url_search)[["id"]]
)
# if we were passed a detail ID in query string, set page-level variable
# need special syntax to "unwrap" reactive value, see https://mastering-shiny.org/reactive-motivation.html
if (!is.null(shiny::isolate(qs_detail_id()))) {
  detail_id <- shiny::isolate(qs_detail_id())
}
```

Whether or not we got a `detail_id` is used to hide and show parts of the R Markdown file later using HTML comment tags.

Next, the demo loads a dataframe of the first 6 Star Wars films from the Star Wars API at <https://swapi.dev/api/films/>:

```R
# R
# call Star Wars movie API, get film titles & details
df <- jsonlite::fromJSON(
  "https://swapi.dev/api/films/",
  flatten = TRUE
)

# create new dataframe from results JSON array by just getting fields we want
df.results <- df$results %>%
  dplyr::select(episode_id, title, opening_crawl, director, release_date)
```

Every API is different, and I needed to tailor the approach from the Star Wars API to the returned JSON, taking into account the fields I wanted to retain. In any case, we now have a dataframe `df.results` that can be manipulated and displayed later.

Now here's the dynamic hide and show. If we _did_ get a `detail_id`, the following code block to show the table should be hidden - commented out. This is done using inline expressions to output the start and end of a HTML comment tag. On initial load though, we would not get a `detail_id`, so the table will be shown:

````md
`r if (is.character(detail_id)) {"<!--"}`
```{r, echo = FALSE}
...R code
```
`r if (is.character(detail_id)) {"-->"}`
````

Each opening HTML comment tag needs a matching closing comment tag.

If we did _not_ get a `detail_id`, the episode number and film title are shown in a `DT` data table; each film title is a link to the current page, passing an "id" parameter in the query string:

```R
# R
# placeholder for datatable
DT::dataTableOutput("table", width = "100%", height = "auto")

# render datatable, display title and ID
output$table <- DT::renderDataTable({
  DT::datatable(
    # bind to results dataframe, only show episode ID and title
    df.results %>%
      dplyr::select(episode_id, title),
    options = list(
      # only display table (no paging, no info) in output
      dom = "t",
      # default ordering is episode_id
      order = list(
        list(1L, "asc")
      ),
      # number of records visible (i.e. all)
      pageLength = 9999L,
      # specific styles and output for columns
      columnDefs = list(
        list(
          # hide auto-created row ID from output (column 0)
          visible = FALSE, targets = 0L
        ),
        list(
          # set episode_id column header and width
          title = "Episode #",
          targets = 1L,
          width = "120px"
        ),
        list(
          # set column header and make title clickable link
          title = "Title <small>(click to view detail)</small>",
          targets = 2L,
          # on click, goes to this page passing a detail ID in query string
          # detail ID ("episode_id") is in first column, use that for link
          render = htmlwidgets::JS(
            "function(data, type, row, meta) {
              return '<a href=\"master-detail.Rmd?id=' + row[1] + '\" target=\"_self\" title=\"View details\"><strong>' + data + '</strong></a>';
            }"
          )
        )
      )
    )
  )
})
```

Clicking on a film title link (which looks like `"master-detail.Rmd?id=1"`) reloads the page with the "id" parameter.

The last major section of R Markdown code (starting from about line 131) displays the detail of the selected film, and is hidden using the same dynamic R inline expression/HTML comment approach if we did _not_ get a `detail_id`:

```R
# get just the result from the dataframe that matches the passed detail ID
selected_result <- df.results[df.results$episode_id == detail_id, ]
# get fields to display from selected result
title <- selected_result$title
opening_crawl <- selected_result$opening_crawl
director <- selected_result$director
release_date <- selected_result$release_date

# basic display of details
# this "detail" view could potentially be used for anything e.g. a chart, a data entry form, further selections
shiny::uiOutput("details_view")

# render details as paragraphs for demo purposes
output$details_view <- shiny::renderUI({
  shiny::tagList(
    tags$p(
      tags$strong("Episode #:"),
      detail_id
    ),
    tags$p(
      tags$strong("Title:"),
      title
    ),
    tags$p(
      tags$strong("Description:"),
      opening_crawl
    ),
    tags$p(
      tags$strong("Directed by:"),
      director
    ),
    tags$p(
      tags$strong("Released:"),
      # get just the release year, first 4 characters
      substr(release_date, 1, 4)
    )
  )
})
```

The complete demo at <https://github.com/thomasswilliams/r-markdown-snippets/blob/main/master-detail.Rmd> has a couple of extra comments and notes, and after downloading can be run from R Studio.

Good luck with your own master/detail views in R Markdown!
