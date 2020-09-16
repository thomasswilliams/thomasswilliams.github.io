---
layout: post
title:  "Stylelint is FxCop/Web Essentials/JSHint for your CSS stylesheets"
date:   2016-06-24 22:25:00 +1000
categories: development
---
Just because code compiles doesn’t mean it’s perfect. Code analysis is the closest thing to an expert scrutinising your code; used correctly, it provides guidance for a range of issues even down to the level of "things that may not break the build” but can make future troubleshooting harder.

Stylelint <http://stylelint.io/> is a free code analysis tool that “lints” CSS/LESS/SASS stylesheets. Stylelint can be run with as many/few rules as needed to detect obvious issues like non-existent CSS properties, misspelled properties, and repeated properties. It’s flexible enough to support coding styles too - for instance, I like a single space after a colon, no vendor prefixes and a newline after opening curly braces.

A quick search in CSS code on GitHub for misspelled properties shows how Stylint could help: “backgrond”, “margin-botom”, “dipslay” and “pading-top” appear hundreds of times…better go check my repositories!

There’s plenty of great articles on incorporating Stylelint into a build process and rules to get you started:

* Facebook <https://code.facebook.com/posts/879890885467584/improving-css-quality-at-facebook-and-beyond/>
* Smashing Magazine <https://www.smashingmagazine.com/2016/05/stylelint-the-style-sheet-linter-weve-always-wanted/>
* CSS-Tricks <https://css-tricks.com/stylelint/>

I’ve kept my setup simple by running Stylelint via the linter-stylelint package <https://atom.io/packages/linter-stylelint> in Atom. Once the rules are saved in a `.stylelintrc` file, editing any CSS file will trigger the code analysis process.

Here's my current `.stylelintrc` file for reference:

```
{
  "rules": {
    "block-closing-brace-newline-after": "always",
    "block-closing-brace-newline-before": "always",
    "block-no-empty": true,
    "block-no-single-line": true,
    "block-opening-brace-newline-after": "always",
    "block-opening-brace-space-before": "always",
    "color-hex-case": "lower",
    "color-hex-length": "long",
    "color-no-invalid-hex": true,
    "color-named": "never",
    "custom-property-no-outside-root": true,
    "declaration-bang-space-after": "never",
    "declaration-bang-space-before": "always",
    "declaration-block-no-shorthand-property-overrides": true,
    "declaration-block-semicolon-newline-after": "always",
    "declaration-block-semicolon-space-before": "never",
    "declaration-block-trailing-semicolon": "always",
    "declaration-colon-space-after": "always",
    "declaration-colon-space-before": "never",
    "function-comma-space-after": "always",
    "function-comma-space-before": "never",
    "function-parentheses-space-inside": "never",
    "function-url-quotes": "none",
    "indentation": 2,
    "media-feature-colon-space-after": "always",
    "media-feature-colon-space-before": "never",
    "media-feature-no-missing-punctuation": true,
    "media-query-list-comma-newline-after": "never-multi-line",
    "media-query-list-comma-newline-before": "never-multi-line",
    "media-query-parentheses-space-inside": "never",
    "number-leading-zero": "always",
    "number-zero-length-no-unit": true,
    "rule-nested-empty-line-before": "never",
    "rule-non-nested-empty-line-before": "never",
    "selector-combinator-space-after": "always",
    "selector-combinator-space-before": "always",
    "selector-list-comma-newline-before": "never-multi-line",
    "selector-list-comma-space-before": "never",
    "selector-pseudo-element-colon-notation": "double",
    "selector-type-case": "lower",
    "string-quotes": "double",
    "value-list-comma-space-after": "always",
    "value-list-comma-space-before": "never"
  }
}

```
