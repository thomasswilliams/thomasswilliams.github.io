---
layout: post
title:  "Linting…your writing"
date:   2026-02-02 12:00:00 +1100
categories: general
---

"Linting" is a technique used on code to identify common issues based on accepted good practice. Linting is referred to as "static" checking, because the code isn't run to find particular problems.

I wrote about linting in [2019 for Express]({% post_url 2019-11-19-levelling-up-express-api-1 %}) and [2022 for client-side Javascript]({% post_url 2022-06-07-leaflet-antarctica-demo-4 %}), and I've used linters such as [ESLint](https://eslint.org/) (Javascript & Typescript), [lintr](https://lintr.r-lib.org/) (R) and [Ruff](https://docs.astral.sh/ruff/linter/) (Python).

So I was intrigued when I came across [Vale](https://vale.sh/), a linter for…writing?

## Before

For this blog, which I write in VS Code, I use the [Code Spell Checker](https://marketplace.visualstudio.com/items?itemName=streetsidesoftware.code-spell-checker) extension and [Australian English dictionary](https://marketplace.visualstudio.com/items?itemName=streetsidesoftware.code-spell-checker-australian-english).

From time to time I've used other tools such as Grammarly, [Hemingway](https://hemingwayapp.com/), and plain old Word. I don't always agree with the "grammar"/readability recommendations made by those tools. My readability scores (when I bother to check) often edge up towards Year 11 or 12 levels - which seem appropriate for technical writing.

## Now I can go further

Now, with [Vale](https://vale.sh/) and the [Vale VSCode extension](https://marketplace.visualstudio.com/items?itemName=ChrisChinchilla.vale-vscode), I have immediate, useful and controllable feedback where I write my blog posts - in VS Code.

Beyond just grammar, Vale can also be used as a writing style guide.

I adapted the installation steps over at <https://www.nikhilajain.com/post/how-to-install-vale-linter-for-documentation-in-vs-code> for my Jekyll blog; but I assume would work similarly on a Hugo or other markdown-based blog.

<div markdown="1" class="note">
On first use, the sheer number of rules can seem overwhelming. I'd suggest focusing on rules that help readers understand your writing. Individual rules can be turned off.
</div>
<br/>

- install Vale using homebrew: `brew install vale`
  - or run on-demand using Docker (not covered here) - no local install required
  - while on the command line I noticed out-of-date brew packages, so updated with this handy one-liner: `brew update && brew upgrade && brew upgrade --cask && brew cleanup`
- create a `.vale.ini` file in your blog root directory (if using Jekyll, the directory with  `Gemfile` and `_config.yml`)
  - this will define styles and rules, and specify the styles (also known as packages) to install:
    - <https://github.com/errata-ai/proselint> aggregating best practices for writing
    - <https://github.com/errata-ai/alex> identify insensitive terms
    - <https://github.com/errata-ai/Google> Google style guide, or <https://github.com/errata-ai/Microsoft> Microsoft style guide (overlaps with Google's)

```ini
# subdirectory where vale styles are to be installed (must exist)
StylesPath = _vale-styles
# minimum level to report - can be set to "warning" or "error" ("suggestion" is default)
MinAlertLevel = suggestion
# styles AKA packages, named or from zip file
# not listed here - others I've tried like write-good, Microsoft
# just an example - YMMV
Packages = alex, Google, proselint

# rules for .markdown and .md files
[*.{md,markdown}]
BasedOnStyles = Vale, alex, Google, proselint
```

- side note: Vale has three levels of rules - suggestion, warning and error
  - can turn off "suggestions" in `.vale.ini` by setting `MinAlertLevel` to `warning` (you could go further and set to `error` to ignore suggestions as well as warnings)
- create a local subdirectory for Vale styles, for example `_vale-styles`
  - this must match the "StylesPath" in `.vale.ini`
- create a `config` subdirectory inside `_vale-styles`
- from a command prompt, run `vale sync` to download styles set in `.vale.ini`
- now you can run Vale from the command line on an example file like:

```bash
vale example.markdown
```

- since there's some overlap between Vale, proselint and Google styles, let's turn off a couple of unneeded rules in `.vale.ini` by adding to the end of the file, below the "markdown" section:

```ini
# this is a blog which will use "I" a lot
Google.FirstPerson = NO
# disable rule that expects space between number and unit
Google.Units = NO
# disable rule that suggests not using so many parentheses
Google.Parens = NO
# disable warning on using the word "will"
Google.Will = NO
# disable error for exclamation marks
Google.Exclamation = NO
# disable some rules duplicated in different styles
# disable duplicate suggestion about passive voice
Google.Passive = NO
```

- now is a good time to install the VS Code extension [Vale VSCode extension](https://marketplace.visualstudio.com/items?itemName=ChrisChinchilla.vale-vscode)
  - if using VS Code extension, may need to close and re-open VS Code to pick up changes made to `.vale.ini` (for example, disabling rules)
- don't forget to update Git ignore file `.gitignore` to ignore downloaded Vale styles (but, don't ignore custom config)

```ini
...
_vale-styles/*
!_vale-styles/config/

._vale-styles/config/*
!_vale-styles/config/vocabularies/

._vale-styles/config/vocabularies/*
!_vale-styles/config/vocabularies/blog
...
```

- every time you add a new style/package, need to run `vale sync`

### Next level - adding your own technical terms

- for acronyms, best option is to fully spell the term out first like "Network Attached Storage (NAS)", which passes rules
- otherwise, to add custom words and terms (including accepted capitalisation), under __vale-styles/config/vocabularies/blog/accept.txt_ enter your words, one per line:

```
Unifi
```

- also add the following to the top of `.vale.ini` to tell it about the custom vocabulary:

```ini
# use "blog" directory vocabulary
# expect directory /_vale-styles/config/vocabularies/blog
Vocab = blog
...
```

Now when I use the word "UniFi" or "unifi", Vale will suggest the correct casing based on the `accept.txt` file.

You can check out my full `.vale.ini`, custom words or more at my blog's source code at GitHub: <https://github.com/thomasswilliams/thomasswilliams.github.io>