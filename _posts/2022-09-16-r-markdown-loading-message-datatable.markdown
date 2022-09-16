---
layout: post
title:  "Displaying loading messages in DataTables in R Markdown"
date:   2022-09-16 12:00:00 +1000
categories: ['development', 'R']
---

Waits are inevitable, whether getting data from an API or database, or manipulating data in an interactive R Markdown document. Showing a "loading" or "updating" message is a beneficial incremental improvement to users' experience.

The code at <https://github.com/thomasswilliams/r-markdown-snippets/blob/main/loading-message-datatable.Rmd>, when run from RStudio, demonstrates using CSS and pseudo-elements to display text in a DataTables (`DT` package).

The code has two tables with random values. The tables can be interacted with as expected (pagination, filtering, ordering etc.). The loading times are exactly the same for both tables; however, the table on the right shows two messages:

- initial empty state “Loading (please wait)...” – no table is visible, just blank space where table will eventually be (when page first loads)
- reloading message “Updating (please wait)... “ – the table is visible, but not interactive while data is reloaded

The key parts of the code for the loading message are below. The DataTable output name must match the HTML id - in this case, `table`. The message is shown in place of an empty div:

```R
# R
# output placeholder for table
DT::dataTableOutput("table")
```

```css
/* CSS */
/* display message in empty DT datatable
   this only occurs on initial load of datatable (subsequent loads leave the table
   in place, styled with "recalculating" class to make the table inactive)
   "table" div elements will be empty, use CSS to display message */
#table:empty::after {
  content: "Loading (please wait)...";
  opacity: 0.5;
  /* can be further styled... */
}
```

The updating message is similar, using the CSS `::before` pseudo-element, and the same DataTable `table`. The major difference is that the message is shown on top of the existing DataTable:

```css
/* CSS */
/* when table has the "recalculating" class applied, make the table less prominent */
#table.recalculating {
  opacity: 0.1 !important;
  /* need to position relatively so we can center "Updating" text */
  position: relative;
}

/* display "Updating" message when table reloads (for example, on parameter change)
   will be used when the table is already displayed */
#table.recalculating::before {
  content: "Updating (please wait)...";
  /* text should sit above table controls */
  position: absolute;
  /* centered above table as per https://stackoverflow.com/a/50958847 */
  top: 50%;
  left: 50%;
  transform: translate(-50%,-50%);
  /* content above controls */
  z-index: 1000;
  /* can be further styled... */
}
```

I've tested this code with `DT` package versions 0.23 (May 2022), 0.24 and 0.25.

I'm still enjoying R Markdown for simple, interactive web pages. Check out my repo at <https://github.com/thomasswilliams/r-markdown-snippets> for more snippets.