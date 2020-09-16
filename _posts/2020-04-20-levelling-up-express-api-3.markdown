---
layout: post
title:  "Levelling up an Express API, Part 3"
date:   2020-04-20 22:00:00 +1100
categories: [development, expressjs]
---
This is the final post in my 3-part series on “levelling up” an Express API to make it production-readier. [Part 1]({% post_url 2019-11-19-levelling-up-express-api-1 %}) touched on the basics - version control, TypeScript, linting, testing - and [part 2]({% post_url 2019-11-25-levelling-up-express-api-2 %}) added secrets & configuration, deployment considerations, and caching.

I took the approach of building on existing simple code, rather than creating a ready-to-go starter, as I like to better understand any dependencies I add to my code. Any of the “level ups” I’ve described can be used in isolation, or even skipped.

The rest of this post continues production-ready tips, and assumes Express 4.17 (circa mid 2019), Typescript and a main file `server.ts`.

The complete project is at <https://github.com/thomasswilliams/pedals-api-nov-2019>.

# Level 7: Rate limiting

A properly configured Express API can serve thousands of requests per second. Rate limiting helps by restricting one client's ability to make too many requests ("spamming"). Spamming could be caused intentionally/maliciously or by accidental misconfiguration. There’s even a HTTP status to inform clients that they’re being rate limited (HTTP status 429).

I was once involved in a real world example where rate limiting could have saved $$$. A browser kept re-sending a request to an API, and the API sent a text message to a mobile phone. The fix seemed simple enough - find the user and politely ask them to stop. When that wasn’t immediately possible, an outage was necessary to add rate limiting to the API.

I'm using NPM package [express-rate-limit](https://www.npmjs.com/package/express-rate-limit) - first, I add to my project at a command prompt:

```bash
npm install --save express-rate-limit
npm install --save-dev @types/express-rate-limit
```

This adds `express-rate-limit` and typings for TypeScript completion in an editor like VS Code. Then in my `server.ts` file, I add:

```javascript
// rate limiter for Express routes https://www.npmjs.com/package/express-rate-limit
import rateLimiter from 'express-rate-limit';

…other code…

// prior to defining routes, wire up rate limiter for all requests
app.enable('trust proxy');

// create new rate limiter
// eslint-disable-next-line @typescript-eslint/no-explicit-any
const limiter = new (rateLimiter as any)({
  // timeframe is 3 seconds
  windowMs: 3 * 1000,
  // limit each IP to 5 requests per timeframe
  max: 5
});
// apply rate limiter to all requests
// also needs to be applied per route, before cache middleware
app.use(limiter);

// route: get pedals collection
// rate limit route using default settings
// cache this route for 5 minutes
app.get('/pedals', limiter, cache, (req, res) => {
  console.log('Got pedals collection');
  // hard-code JSON response
  res.send({ pedals: [{ name: 'Boss SY-1', id: 1 }] });
});
```

In production Express APIs, I also rate limit my login route as well as my catch-all 404 route, and add rate limiting tests to my test script.

This is a good time to note that the order of Express middleware matters. I chose to put the rate limiter before caching. If it was the other way around, the cached response would be sent before rate limiting.

# Level 8: Security headers
Security can be a touchy topic for developers. It’s necessary to consider, yet difficult to add later in the project life, and recommended practice seems to be regularly changing. 

While I won’t cover every aspect of security, I production-ready my Express APIs with Cross-Origin Resource Sharing AKA [CORS](https://www.npmjs.com/package/cors) and a great multi-purpose HTTP header solution called [helmet](https://www.npmjs.com/package/helmet). Note CORS may need configuration on the client, which is unfortunately out of scope for this blog post.

First I add `cors` and `helmet` and typings from a command prompt:

```bash
npm install --save cors helmet
npm install --save-dev @types/cors @types/helmet
```

Then in my `server.ts`, I import them and configure (towards the top of the file, before defining routes):

```javascript
// CORS HTTP headers https://www.npmjs.com/package/cors
import cors from 'cors';
// common security HTTP headers https://www.npmjs.com/package/helmet
import helmet from 'helmet';

…other code…

// simple usage for CORS
// more docs at https://www.npmjs.com/package/cors
app.use(cors());
// wire up all helmet HTTP headers
app.use(helmet());

// route: get pedals collection
// rate limit route using default settings
// cache this route for 5 minutes
// return CORS and other common security HTTP headers
app.get('/pedals', limiter, cache, cors(), helmet(), (req, res) => {
  console.log('Got pedals collection');
  // hard-code JSON response
  res.send({ pedals: [{ name: 'Boss SY-1', id: 1 }] });
});
```

# Level 9: a couple of cosmetic touches

My last “level up” is a few cosmetic touches for my Express API:

- ignore requests for "favicon"
- increment `package.json` version each time I build for production
- pre-build script to clean distribution directory

## Ignore requests for "favicon"

I’ve added the code below to my Express APIs as some browsers request “favicon.ico”. There’s no impact on functionality - I put the following statements near the top of `server.ts` - just below where I declare the Express app:

```javascript
// ignore requests for favicon adapted from https://stackoverflow.com/a/35408810/116288
// wire up earlier, before other middleware
app.get('/favicon.ico', (req, res) => {
  // return HTTP status 204 "No content" and end the response
  return res.sendStatus(204).end();
});
```

## Increment `package.json` version on build

This is a “nice-to-have”, rather than must-have, step when building in the distribution directory (“dist”, can be configured in the `tsconfig.json` file).

First, I add a “build” script to `package.json` “scripts”:

```javascript
“build”: “tsc”
```

Then I add a “postbuild” script, again in `package.json` “scripts”:

```javascript
“postbuild”: “npm version patch -s --no-git-tag-version”
```

The NPM `version` command above increments the “patch” version number in ‘package.json’ by 1, without creating a Git version and tag.

More details of the NPM `version` command are at <https://docs.npmjs.com/cli/version>. My complete repo, including the “build” and “postbuild” scripts, is at <https://github.com/thomasswilliams/pedals-api-nov-2019>.

## Pre-build script

Another minor improvement I’ve made when building my Express API for production is a pre-build script that clears the distribution directory. This uses the cross platform NPM package [rimraf](https://www.npmjs.com/package/rimraf); first, add `rimraf` to the project from a command line:

```bash
npm install --save-dev rimraf
```

Then add a “prebuild” script to `package.json` “scripts”:

```javascript
“prebuild”: “rimraf dist"
```

Now when I run “npm run build”, previous builds are removed and I start with a clean distribution directory.

That wraps up my blog series on taking a “getting started” Express API and gradually “levelling up” to production readiness. Even though it’s not a complete list of tips it’s what I consider some of the biggest, easy wins. I hope it was useful! 
