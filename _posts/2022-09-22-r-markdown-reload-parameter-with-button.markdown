---
layout: post
title:  "Reload parameters without page reload in R Markdown"
date:   2022-09-22 12:00:00 +1000
categories: ['development', 'R']
---

One of the ways I've used R Markdown - rendered as interactive web pages using Shiny - is to 1) load parameters when the page first loads, then 2) dynamically update a table or chart when the parameter changes (R Markdown is _great_ at this):

![R Markdown page load example](/images/r-markdown-page-load-sep-2022.png)

Recently I needed to reload a parameter, without reloading the page. The parameter was bound to a data frame, where end-users selected a value and then I looked up other fields in the data frame further down the page (for example, a name was selected, but I wanted the identifier from the same record). It wasn't exactly intuitive, so here's how I did it.

(As with my other R Markdown snippets, the full code can be found on GitHub at <https://github.com/thomasswilliams/r-markdown-snippets/blob/main/reload-parameters.Rmd>.)

The initial setup is an empty data frame, a placeholder for a parameter, and a "reload" button:

```R
# R
# create empty data frame for user parameter, with columns matching what we will fetch from API
# as this empty "users" variable exists outside render event, can be used elsewhere on page
users <- data.frame(
  username = character(),
  email = character(),
  phone_number = character(),
  stringsAsFactors = FALSE
)

# placeholder for user parameter (div)
shiny::uiOutput("user_select_div")

# placeholder for refresh button
# note icons need "icon()" as per https://shiny.rstudio.com/reference/shiny/0.14/icon.html
shiny::actionButton("refreshbutton", "Reload", icon = shiny::icon("arrows-rotate"))
```

Next, the parameter is rendered:

```R
# R
# render user parameter (dropdown), inside a div
# note the dropdown will be rendered *after* the API call finishes
output$user_select_div <- shiny::renderUI({
  # render function is dependent on "refresh" button, so when refresh button is
  # clicked, select will be re-rendered (this code will be run)
  input$refreshbutton
  # get 5 random users from API using jsonlite and set to global variable using
  # "<<-" (double arrow assignment) notation
  # "flatten" into data frame (default is list of lists)
  users <<- jsonlite::fromJSON(
    "https://random-data-api.com/api/v2/users?size=5&response_type=json",
    flatten = TRUE
  ) %>%
    # keep just the columns we want
    # for all possible fields from the API, see https://random-data-api.com/api/v2/users
    dplyr::select(username, email, phone_number)

  # test if we got any results, if zero leave and return message
  # adapted from https://stackoverflow.com/a/59394360
  shiny::validate(
    shiny::need((nrow(users) != 0L), "No data available")
  )

  # create the actual dropdown control to select user
  # can be referenced elsewhere on the page as "input$user"
  shiny::selectInput(
    "user",
    label = "Select a user",
    # display user name (don't show e-mail, phone number, any other fields)
    choices = users$username,
    # not Selectize
    selectize = FALSE
  )
})
```

There's a couple of things going on in the render function:

- get 5 random users from an API into data frame variable "users" (only keep 3 columns for demo purposes; the parameter could also be loaded from a database or somewhere else)
- exit if no data
- create the parameter dropdown called "user", showing user names from "users"

That's the "reload" - this code is re-run when the "refresh" button is clicked. The main difference is using the "<<-" (double arrow assignment) notation to populate the previously-empty data frame.

Lastly, again for demo purposes, we can do something with the user in the data frame that is selected in the dropdown:

```R
# R
# placeholder for output text of selected user
# of course, instead of text, this could be used in anything: table, chart, further API call etc.
shiny::uiOutput("output")

# render output text for the selected user
# note will not run immediately, as user select is being loaded when this page first loads
output$output <- shiny::renderUI({
  # make this render function also dependent on "refresh" button
  # not needed, but makes the output inactive while reloading
  input$refreshbutton

  # get just the single result from users data frame, based on selected username in dropdown
  # this will be a list with username, email, phone_number
  selected_user <- users[users$username == input$user, ]

  # make sure we've selected a user, test if the username field is empty
  shiny::validate(
    shiny::need(selected_user$username, "No user selected")
  )

  # for demo purposes only, just render simple HTML
  htmltools::pre(
    paste0("User: ", selected_user$username),
    paste0("E-mail: ", selected_user$email),
    paste0("Phone: ", selected_user$phone_number)
  )
})
```

The full code, and other R Markdown snippets, can be found on my GitHub repo at <https://github.com/thomasswilliams/r-markdown-snippets>.