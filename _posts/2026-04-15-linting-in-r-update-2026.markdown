---
layout: post
title:  "Improving R linting (2026 update)"
date:   2026-04-15 12:00:00 +1100
categories: ['development', 'R']
---

Linting helps catch potential issues in code before they cause problems, and helps keep coding style consistent, whether for yourself or as part of a team or project. Linting uncovers surprising issues: recently, I added lints which caught that I was passing the same parameter by name twice in a call - meaning one of the parameter values was silently ignored.

Previously, using `lintr` for R, I specified only lint rules I wanted (whitelist). Now, I include all lint rules, and then tune (or disable) rules I don't care about (blacklist).

This has the advantage that, if new rules are added, running `lintr` would automatically includes the new rules.

My lint configuration is below. It suits my style when coding in R: explicitly scoped function calls preceded by name of library (e.g. "DT::renderDataTable" over "renderDataTable"), libraries loaded at top of each script for portability and reproducibility, spaces instead of tabs, double quotes for strings, line lengths less than 120 characters for readability, and more.

`lintr` is pretty particular about lint config file formatting, and will error if the config file isn't correct. Don't forget to leave a blank line at the end of the file.

To lint your R code from RStudio, install the `lintr` package, create a config file _.lintr_ and add rules (or copy-paste my lint rules below), then run from the R console either `lintr::lint(filename = "<file name>.Rmd")` or lint the whole directory with `lintr::lint_dir()`. See the full `lintr` documentation at <https://lintr.r-lib.org/reference/>.

My _.lintr_ file as at 2026:

```R
linters: all_linters(
    # use all lint rules - customise some, and disable others (see below)
    # see linter details at https://lintr.r-lib.org/reference/index.html
    # --------- customised linters ---------
    # line lengths should be less than 120 characters
    line_length_linter(120L),
    # check for unused imports
    # allow packages referenced for namespace (e.g. pkg::function)
    # always allow dplyr
    unused_import_linter(
      allow_ns_usage = TRUE,
      except_packages = c("dplyr"),
      interpret_glue = TRUE
    ),
    # variables should be snake case
    object_name_linter(c("snake_case", "SNAKE_CASE")),
    # assignment should use specific operators (not equal sign)
    assignment_linter(
      operator = c("<-", "<<-", "%<>%")
    ),
    # consistent pipes
    pipe_consistency_linter(pipe = "auto"),
    # ---------- disabled linters ----------
    # lint rules are disabled by setting them to NULL
    # allow "stop" calls, used in Rmd database connection errors
    condition_call_linter = NULL,
    # not cyclomatic complexity
    cyclocomp_linter = NULL,
    # allow relative paths (expected by some of the javascript libraries)
    nonportable_path_linter = NULL,
    # allow "paste" and "paste0"
    paste_linter = NULL,
    # allow comparisons to empty strings for readability
    nzchar_linter = NULL,
    # allow one pipe commands
    one_call_pipe_linter = NULL,
    # allow redundant calls to "== TRUE" for readability
    redundant_equals_linter = NULL,
    # turn off "trailing blank lines"
    trailing_blank_lines_linter = NULL,
    # allow calls to "library" (helps with portability)
    undesirable_function_linter = NULL
  )
encoding: "UTF-8"

```

Linting can be ignored for specific lines of code. For example, if there's a line of code longer than 12 characters, add `# nolint: line_len` to the end to have it ignored by `lintr`.

Going further: linting for R has room to improve. By comparison, linting in Python is a little more mature, and some issues can be automatically fixed.

There's the possibility of better linting with LLMs, such as assessing metrics for code like complexity & readability, and perhaps new metrics that don't exist yet. LLMs could (potentially) suggest better, newer ways to achieve the same outcomes, while still keeping consistency to a preferred style or team norms.

In any case - good luck with linting and finding those tricky issues!
