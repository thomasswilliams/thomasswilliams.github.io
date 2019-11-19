---
layout: post
title:  "Levelling up an Express API, Part 1"
date:   2019-11-19 20:25:00 +1000
categories: 
---
Over the past 18 months I've built and deployed a couple of APIs using Node, Express & TypeScript, typically serving data to a web site, sometimes with endpoints to validate and write data to a database.

I wanted to share some techniques past "getting started" (if you're at that stage, a couple of great guides are at <https://developer.okta.com/blog/2018/11/15/node-express-typescript> and <https://itnext.io/building-restful-web-apis-with-node-js-express-mongodb-and-typescript-part-1-2-195bdaf129cf>). I'll cover my learnings one by one, explaining how they incrementally improve code, help towards production quality, and take advantage of tens of hours of knowledge and research in ready-to-go dependencies.

My base API contains 3 files, currently serving a single endpoint `pedals` that returns a JSON collection of guitar effect pedals:

- `package.json` - dev and production dependencies (initially, Express, TypeScript, and types only)
- `src/server.ts` - Express server written in TypeScript, will be compiled to javascript to run by command in `package.json`
- `tsconfig.json` - Typescript config file, borrowed from <https://developer.okta.com/blog/2018/11/15/node-express-typescript>

<script src="https://gist.github.com/thomasswilliams/59ddc596a0bc6c569ab6f55cff661014.js"></script>

<script src="https://gist.github.com/thomasswilliams/39c3d38b4c5b0ac88f7959f6edf6ee29.js"></script>

<script src="https://gist.github.com/thomasswilliams/4e56d8ba7d2396af4fa56006e30be47c.js"></script>

The Express server can be run from a terminal by calling `npm run serve` (after installing necessary dependencies using `npm install`), and then also calling `curl -s http://localhost:34512/pedals` in another terminal to demonstrate getting JSON from the running server.

# Level 0: Version control
Before I start anything, I use version control. [Git](https://git-scm.com/) is easy to use, even as a solo developer. I'd suggest setting up a good `.gitignore` file too (I won't be spending time explaining Git in this blog post, though).

# Level 1: TypeScript
TypeScript includes javascript, adding explicit typing which helps avoid simple errors and leads to more correct code. TypeScript and javascript can be mixed in the same project too.

I went ahead and wrote my code in TypeScript already. I added a `tsconfig.json` file and a command in `package.json` to call the TypeScript compiler and serve the resulting javascript.

# Level 2: Linting
I'd say linting is the next best "level up" after TypeScript. Regardless if you’re permissive or strict with your code style, linting can help. A linter like [ESLint](https://eslint.org/) can be enhanced by adding [Prettier](https://prettier.io/) to handle "cosmetic" preferences like indents, tabs vs. spaces, line length etc.

To add basic linting to the base API, first stop the server if it's started, then install ESLint and friends: `npm install --save-dev eslint @typescript-eslint/eslint-plugin @typescript-eslint/parser`

Next, create an `.eslintignore` file:

<script src="https://gist.github.com/thomasswilliams/465055148f62c2866f7cda2d9a6b7d02.js"></script>

Then add a `lint` command and `eslintConfig` section to your `package.json`. The new `package.json` file looks like:

<script src="https://gist.github.com/thomasswilliams/71509330115c50e1fdb9cbb7388ad5a2.js"></script>

Going further - I've tried a couple of useful ESLint plugins that add checks and rules, such as:

- [eslint-plugin-import](https://www.npmjs.com/package/eslint-plugin-import) - "This plugin intends to support linting of ES2015+ (ES6+) import/export syntax, and prevent issues with misspelling of file paths and import names. All the goodness that the ES2015+ static module syntax intends to provide, marked up in your editor."
- [eslint-plugin-json](https://www.npmjs.com/package/eslint-plugin-json) - "Eslint plugin for JSON files"
- [eslint-plugin-node](https://www.npmjs.com/package/eslint-plugin-node) - "Additional ESLint's rules for Node.js"
- [eslint-plugin-promise](https://www.npmjs.com/search?q=eslint-plugin-promise) - "Enforce best practices for JavaScript promises."
- [eslint-plugin-security](https://www.npmjs.com/package/eslint-plugin-security) - "ESLint rules for Node Security. This project will help identify potential security hotspots, but finds a lot of false positives which need triage by a human."
- [eslint-plugin-sonarjs](https://www.npmjs.com/package/eslint-plugin-sonarjs) - "SonarJS rules for ESLint to detect bugs and suspicious patterns in your code."
- [eslint-plugin-standard](https://www.npmjs.com/package/eslint-plugin-standard) - "ESlint Rules for the Standard Linter"

Unfortunately, configuring the plugins is outside what I can cover in this post, though.

# Level 3: Testing
Lastly (for part 1), good tests will provide confidence when updating or adding dependencies or features to your code. Overall, I try and test for the "happy path" in an Express API as well as errors like:

- non-existent endpoints
- too may requests
- missing request headers
- missing response headers
- parameters too short
- parameters too long etc.

I can suggest a couple of great resources for adding tests to Express, at <https://blog.jscrambler.com/testing-apis-mocha-2/>, <https://hackernoon.com/testing-node-js-in-2018-10a04dd77391>, and <https://medium.com/@jodylecompte/express-routes-a-tdd-approach-1e12a0799352>.

That's all for part 1 - in part 2, I'll cover a few easy, practical techniques to further production-ready an Express API.
