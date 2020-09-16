---
layout: post
title:  "Using Terser to minify and compress Express javascript code for deployment"
date:   2020-09-16 17:00:00 +1000
categories: development expressjs
---
Terser is a "JavaScript parser, mangler and compressor toolkit for ES6+". It's a popular and active [NPM package](https://www.npmjs.com/package/terser) (at the time of writing, 13 million weekly downloads and GitHub repo has 5,100 stars).

In this post, I'm going to demonstrate using terser to compress (minify) built javascript files in Express, before deploying to a production server. I'm aiming for an automated process as part of a production build that can be run from a command line using `npm run build`.

The question is - why would we want to do this?

My general approach is that deployed code = code that will be used. Anything that will not be used in production - unnecessary artifacts, build instructions, thumbs.db etc. - should not be deployed.

Some of the differences between source code and deployed code are:

- comments can be excluded (regular comments and comments included for test automation)
- code branches not applicable to production can be safely removed
- readability - including whitespace - is not as important for deployed code (assuming you have the original source!)
- variable and/or function names - for example, parameter names for functions can be shortened

Terser can do the above while optionally preserving source maps. The resulting minified javascript files are functionally the same and can be up to 50% smaller than without using terser. Terser expects javascript and outputs javascript - perfect for how I deploy Express.

By the way, there's excellent documentation at [the project's web site](https://terser.org/docs/cli-usage) and [NPM page](https://www.npmjs.com/package/terser),

On to adding terser. I've done this in Windows, and I'm assuming an Express project, with built files in the "dist" directory.

<div markdown="1" class="note">
**Thomas's "but it worked for me" disclaimer:** before using any code you find on the internet, especially on this blog, take time to understand what the code does and test, test, test. I'm not responsible for damage caused by code from this blog, and don't offer any support or warranty.
</div>
<br/>

First, add terser as a development dependency to the Express project, from the command line:
```bash
  npm install --save-dev terser
```

Next, create a terser config file in JSON format in the project root directory e.g. `.terser`. This will:

- enable the compressor with defaults, and enable unsafe transformations (see more details at <https://github.com/terser/terser#the-unsafe-compress-option>)
- mangle e.g. rename variables (lots more options I haven't explored)
- (my preference) keep function names and class names the same when mangling, helps with logging

```json
  {
    "compress": {
      "unsafe": true
    },
    "mangle": true,
    "keep_fnames": true,
    "keep_classnames": true
  }
```

Next, add a postbuild step to `package.json` which will:

- explicitly run terser, only on a built javascript file called "server.js" - so could be used on my example repo at <https://github.com/thomasswilliams/pedals-api-nov-2019>.
- set the value of variable "process.env.NODE_ENV" to "production", allowing terser to remove any code branches which test this and evaluate to a value other than "production"
- pass the config file specified above `.terser`
- output the minified javascript to the same file (overwrite)

```json
  "postbuild": "terser dist/server.js --define process.env.NODE_ENV=\"'production'\" --config-file .terser -o dist/server.js"
```

Alternatively, if you use source maps, the postbuild step below will keep a reference to the existing source maps in the compressed file:
```json
  "postbuild": "terser dist/server.js --define process.env.NODE_ENV=\"'production'\" --config-file .terser --source-map \"content='dist/server.js.map',root='./src/',url='server.js.map'\" -o dist/server.js"
```

Now, when you run `npm run build`, after the build terser will compress built "server.js" file in the "dist" directory. This could easily be adapted to other files - to use on multiple files, I would call a separate file (for example a batch file or PowerShell script).

(A reminder to test the minified Express project - the above terser config should not alter functionality in any way, but I haven't tested all possible cases.)
