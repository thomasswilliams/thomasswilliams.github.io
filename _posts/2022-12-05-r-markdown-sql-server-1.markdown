---
layout: post
title:  "Connecting to a SQL Server database from R Markdown (part 1)"
date:   2022-12-05 12:00:00 +1100
categories: ['development', 'R']
---

R code (including in R Markdown and Shiny) can connect to databases, for both reading and writing. This opens up a whole world of powerful analysis - however, it can sometimes be tricky to deal with drivers, error handling and closing connections. In this post, I'll demonstrate how to connect to a SQL Server database and run a query; in part 2, I'll cover some of the things you might want to do with the query results.

Code in this post was tested with up-to-date versions of R and relevant packages as at December 2022. You can skip ahead to the code using the links below:

  - [`DBI` and `odbc` packages](#dbi)
  - [An older package: `RODBC`](#rodbc)
  - [Helpful hints for Shiny & SQL Server](#caveats)

Before we can connect to a database and get data, we'll need a connection string. The basic components of a connection string (across most database platforms like SQL Server, MySQL, Postgres etc.) are a driver, server, database, and authentication (username and password).

I'll assume you already have a valid username and password. In fact, in this post we're going to need to assume a _lot_; the code will need to be tailored to your specific environment unlike some of my other [R Markdown snippets](https://github.com/thomasswilliams/r-markdown-snippets) which can be run as-is.

A reminder about authentication: use the `dotenv` package so sensitive data - like passwords - are not in your code. My blog post ["Using a .env file to manage secrets in R Markdown"]({% post_url 2022-10-20-r-markdown-env-file %}) has a detailed explanation and hints to get you started.

Here's the assumed `.env` file with variables needed for the connection string:

```ini
SERVER=BESTSERVER
DATABASE=BESTDATABASE
DATABASE_USER=test_user
DATABASE_PASSWORD="correct horse battery staple"

```

## DBI

The `DBI` and `odbc` packages are a recommended way to connect to databases: <https://docs.posit.co/shinyapps.io/applications.html#using-the-odbc-package>. The code below shows the steps necessary - put together the connection string, set up the connection, set up a query (using parameters if required), and run the query.

When you run a query using `DBI`, the results are "strongly typed" to corresponding R data types - that is, numbers will be returned as numbers, dates as dates, strings as strings etc.

```R
# R
# R Database Interface
# https://dbi.r-dbi.org/
library(DBI)
# connect to ODBC databases using the DBI interface
# https://github.com/r-dbi/odbc
library(odbc)
# dotenv for loading from environment files
# https://github.com/gaborcsardi/dotenv
library(dotenv)
# glue for better string literals & templating
# https://glue.tidyverse.org/
library(glue)

# load .env file
dotenv::load_dot_env()

# get database connection parameters from environment file
# see my blog post at https://thomasswilliams.github.io/development/r/2022/10/20/r-markdown-env-file.html
server <- Sys.getenv("SERVER")
database <- Sys.getenv("DATABASE")
username <- Sys.getenv("DATABASE_USER")
password <- Sys.getenv("DATABASE_PASSWORD")

# search parameter
search <- "test"

.conn <- DBI::dbConnect(
  # use ODBC driver
  odbc::odbc(),
  # specify connection string, this example uses ODBC Driver 17, driver needs to be installed
  # alternatively can specify parts of connection string like example at:
  # https://docs.posit.co/shinyapps.io/applications.html#using-the-odbc-package
  .connection_string = glue::glue(
    "Driver=ODBC Driver 17 for SQL Server;Server={server};Database={database};UID={username};PWD={password};APP=test-r"
  )
)

# SQL statement with placeholder for parameter
# see full docs at https://dbi.r-dbi.org/reference/sqlinterpolate
sql <- "SELECT * FROM SomeTable WHERE SomeField LIKE ?search"

# create query using SQL statement, pass search parameter
# surround search parameter with wildcards as per https://stackoverflow.com/a/58272408
# using "sqlInterpolate" rather than glue template prevents SQL injection
query <- DBI::sqlInterpolate(
  .conn,
  sql,
  search = paste0("%", search, "%")
)

# run query on connection
results <- DBI::dbGetQuery(.conn, query)

# automatically close connection after running query and leaving the current function
on.exit(DBI::dbDisconnect(.conn), add = TRUE)

# optionally, can test if we got any results, if zero leave and return message
# adapted from https://stackoverflow.com/a/59394360
shiny::validate(
  shiny::need((nrow(results) != 0L), "No results")
)

# do something with results
…
```

An easy way to prove the error handling is to substitute incorrect values while developing, to see how R Markdown (or Shiny) responds to errors. For example, using the name of a non-existent server or database name, bad password, or mis-spelled field name. Just remember to deploy the correct values :-)

The code above is a great candidate for wrapping in a function.

## RODBC

The `RODBC` package (see <https://cran.r-project.org/package=RODBC>) has been around a long time. For completeness, I'll demonstrate similar steps to connect and run a query, although I'd recommend using `DBI` instead. Please do not use string interpolation to include parameters using `RODBC` - your code will be exposed to potentially catastrophic SQL injection attacks:

```R
# R
# R ODBC data access
# https://cran.r-project.org/package=RODBC
library(RODBC)
# dotenv for loading from environment files
# https://github.com/gaborcsardi/dotenv
library(dotenv)
# glue for better string literals & templating
# https://glue.tidyverse.org/
library(glue)

# load .env file
dotenv::load_dot_env()

# get database connection parameters from environment file
# see my blog post at https://thomasswilliams.github.io/development/r/2022/10/20/r-markdown-env-file.html
server <- Sys.getenv("SERVER")
database <- Sys.getenv("DATABASE")
username <- Sys.getenv("DATABASE_USER")
password <- Sys.getenv("DATABASE_PASSWORD")

# connect using RODBC
.conn <- RODBC::odbcDriverConnect(glue::glue(
  "Driver=ODBC Driver 17 for SQL Server;Server={server};Database={database};UID={username};PWD={password};APP=test-r"
))

# handle connection errors as per https://stackoverflow.com/a/3440645
# connection will be set to -1 if connect call above fails
if (.conn < 0L) {
  # stop script
  stop(paste(.conn, collapse = "\n"))
}

# run SQL statement
results <- RODBC::sqlQuery(.conn, "SELECT * FROM SomeTable")

# test for errors with results, test if a string (if so, error)
# adapted from https://stackoverflow.com/a/25728365
if (is.character(results)) {
  # stop script
  stop(paste(results, collapse = "\n"))
}

# close connection (ignore errors)
try(RODBC::odbcClose(.conn), silent = TRUE)

# optionally, can test if we got any results, if zero leave and return message
# adapted from https://stackoverflow.com/a/59394360
shiny::validate(
  shiny::need((nrow(results) != 0L), "No results")
)

# do something with results
…
```

## Caveats

Whichever method - `DBI` or `RODBC` - you use, here's three interesting hurdles you might come across when connecting to SQL Server from R or R Markdown:

### Special case 1: Drivers

If you're hosting your own (Linux) Shiny server, you'll need to install drivers. I've used a fairly modern Microsoft ODBC driver, see instructions to install at <https://docs.microsoft.com/en-us/sql/connect/odbc/linux-mac/installing-the-microsoft-odbc-driver-for-sql-server>.

### Special case 2: No integrated Windows login

You will most likely need a SQL username and password, as "trusted"/"integrated" logins using NTLM probably won't work on a (Linux) Shiny server. You'll see in the code above I explicitly pass a username and password in the connection string.

### Special case 3: NOCOUNT and stored procedures

I had a strange experience with `RODBC` where a complex, multi-statement stored procedure completed without error, but nothing was returned when called from R. The fix was to `SET NOCOUNT ON` at the start of the stored procedure.

That's it for establishing SQL Server database connections; in the next post, I'll cover handling results, adding (and removing) fields from results, and filtering.
