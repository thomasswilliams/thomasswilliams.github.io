---
layout: post
title:  "Using a .env file to manage secrets in R Markdown"
date:   2022-10-20 12:00:00 +1100
categories: ['development', 'R']
---

You should never embed passwords or other "secrets" - sensitive data - in code. A better way is to put sensitive data into configuration, and load configuration from your code. Read on to find out how to do this in R Markdown (and Shiny).

## Boring background: Environment variables

Environment variables are used in Windows, Linux & Mac operating systems. They are a name/value pair - that is, an identifying name, and associated value. The value can be a number or string (but typically a string, for instance a directory path or even a semi-colon delimited list). Environment variables are helpful because you can share configuration between installed software, great for secrets: usernames, passwords, API keys etc.

## A `.env` file

A `.env` file stores a name and a value, separated by an equals sign, with no spaces around the equals sign; for instance, `DATABASE_USER=test_user` (the name cannot contain an equals sign, however the value can). The value - the right-hand side of the equals sign - can be single- or double-quoted if it contains spaces. A `.env` file is similar to an old-fashioned `.ini` file or PHP configuration file.

Using R and the `dotenv` package, values from the `.env` file are treated just like environment variables, and can be retrieved by name, with the `Sys.getenv` function (example later on).

## The `dotenv` package

To read from a `.env` file using R, use the `dotenv` package (tested with version 1.0.3 from April 2021), see <https://cran.r-project.org/package=dotenv>.

First, install the `dotenv` package (on your Shiny server too if planning on deploying).

Next, create a `.env` file in your development environment, and deployment environment:

- can be different between environments
- can use other file names, however `.env` is the default
- to create in Windows Explorer, create a new file named ".env." (the second dot will be ignored)
- edit the file with your favorite text editor, and make sure to end the file with a blank line
- convention is for names to be upper-case e.g. “DATABASE_USER”, “DATABASE_PASSWORD”, “API_KEY”
- the `.env` file needs to go in the same directory as your R Markdown file(s)

Here's my demo `.env` file, with a username and password for a database:

```ini
DATABASE_USER=test_user
DATABASE_PASSWORD="correct horse battery staple"

```

## The $1,000,000 question: how is this different from embedding the password in code?

Answer: the `.env` file is not in version control. The `.env` file should be ignored in your `.gitignore` file (if you don't have a `.gitignore` file, a good start is the up-to-date R `.gitignore` file from <https://github.com/github/gitignore/blob/main/R.gitignore>). I'd suggest documenting the `.env` file in the project's `README`, and creating an empty example file, for instance `.env.example` (make sure the example file is not ignored by your `.gitignore`):

```ini
DATABASE_USER=
DATABASE_PASSWORD=

```

## Development vs. deployment

If you've followed the steps above, you'll notice a difference between files for development, deployment and in your version control repository:

```bash
Development
├── best-R-markdown-file-eva.Rmd
├── .env
├── .env.example
├── .gitignore
├── README
└── ...

Deployment (e.g. Shiny server)
├── best-R-markdown-file-eva.Rmd
└── .env

Version control (e.g. GitHub repo)
├── best-R-markdown-file-eva.Rmd
├── .env.example
├── .gitignore
├── README
└── ...
```

The `.env` file is not in version control.

## Use in R code

Congratulations on getting this far!

The demo code below shows how to load the `.env` file created above using the `dotenv` package, and read into variables.
I've included the code in an R Markdown file at <https://github.com/thomasswilliams/r-markdown-snippets/blob/main/dotenv.Rmd>.

A tip: if the code doesn’t seem to work (values aren’t being retrieved from the `.env` file), make sure your working directory is set to the directory containing the `.env` file and R Markdown files:

```R
# R
# dotenv for loading a .env file as environment variables
# https://github.com/gaborcsardi/dotenv
library(dotenv)

# load the file (defaults to “.env” file)
# will throw error if file is not found, or file is not valid
dotenv::load_dot_env()

# get values from environment variables
# will be returned as character vectors (see docs at https://www.rdocumentation.org/packages/base/versions/3.6.2/topics/Sys.getenv)
# will be NULL if the passed name does not exist
# also used to get other system environment variables like “TEMP”, “PATH”, "SHELL" etc.
user <- Sys.getenv("DATABASE_USER")
password <- Sys.getenv("DATABASE_PASSWORD")

# do something with values
…
```
