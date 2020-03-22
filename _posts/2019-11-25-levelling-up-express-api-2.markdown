---
layout: post
title:  "Levelling up an Express API, Part 2"
date:   2020-03-19 23:30:00 +1100
categories:
---
In [part 1]({% post_url 2019-11-19-levelling-up-express-api-1 %}) of this series I explained 3 techniques to "level up" a simple Express API: using TypeScript, linting and automated testing.

I did this because I wanted to build on the numerous great tutorials for beginners to Express & TypeScript, working towards getting an Express API production-ready.

Continuing that theme, in this post I'll cover 3 more incremental improvements, linked to code samples where relevant: secrets, deployment, and caching.

# Level 4: Secrets and configuration
Some types of data should not be in code - for instance, usernames, passwords, and API keys. For security, these are better placed in configuration files or environment variables that are not committed to your version control system.

Apart from security, the other advantage of having these types of data outside TyeScript code is that it's simple to have different values for different environments e.g. development, testing, production.

I'd recommend [dotenv](https://www.npmjs.com/package/dotenv) which loads keys and values from a configuration file (similar to an .ini file) and exposes them as environment variables. I'll start by adding the NPM package to my project:

```bash
npm install --save dotenv
```

Then in my `server.ts` file ([here's one I prepared earlier](https://gist.github.com/thomasswilliams/39c3d38b4c5b0ac88f7959f6edf6ee29#file-server-ts)), near the top, I import and configure dotenv:

```javascript
import dotenv from 'dotenv';
// get .env file keys and values
const dot_env_result = dotenv.config();
// error if we do not get a .env file
if (dot_env_result.error) {
  throw dot_env_result.error;
}
```

Lastly, I create a file called `.env` and store a key & value:

```bash
SECRET=s3cr3t
```

Values stored in the `.env` file can be accessed in my Express API like: `process.env.SECRET`

# Level 5: Deployment considerations
The earlier you practice production deployment, the faster (and more painlessly) you'll be able to deploy. There's little value having great code that "works on my machine", only to find later that the production environment cannot support it.
 
It’s too large of a topic to cover in this post (sorry!). I’ve had success with [PM2](https://pm2.keymetrics.io/) to manage deployed Express APIs. Depending on the size of the Express API, I've used simple deployment tactics such as copying both `package.json` and `package-lock.json` to the production server, then running a command like
`npm install --only=production --ignore-scripts --no-audit` to install only production dependencies (reducing the size of
`node_modules`) without running post-install scripts. An alternative might be [`npm ci`](https://docs.npmjs.com/cli/ci.html)
which aims for reproducible, clean installs.

# Level 6: Caching
Caching balances faster response time against "freshness" of data and load on the data source. Some considerations for caching are:

- how frequently does data change? If infrequently, can be safely cached
- how long can the data be cached for? Even 5 minutes makes a difference to the load on the data surce - maybe a database or 3rd-party API
- how many users? The number of users is multiplier e.g. 100 users all accessing same data - get the data once, then cache!
- in my experience I've often, eventually, needed a way to clear the cache if data is changed (alternatively, I could just advise users to wait *x* minutes for the cache to expire)

In short, caching is probably the easiest win in terms of overall impact e.g. avoids frequently hitting database, provides lightning-fast response to users if data is from cache.

That said, it doesn't make sense to cache some types of data (frequently changing, short lived). I've actually gone in the opposite direction and not cached some routes in an Express API.

I'm demonstrating an NPM package called [apicache](https://www.npmjs.com/package/apicache) that provides simple in-memory caching, which has room to grow into a more resilient solution like Redis. First, from a command line, install `apicache`:

```bash
npm install --save apicache
```

In the `server.ts` file, add:

```javascript
import apicache from 'apicache';

// configure caching, needs to be applied to routes
// will add HTTP headers "apicache-store", "apicache-version"
const cache = apicache.middleware('5 minutes');

// route: get pedals collection
// cache this route for 5 minutes
app.get("/pedals", cache, (req, res) => {
  console.log("Got pedals collection");
  // hard-code JSON response
  res.send({ pedals: [{ name: "Boss SY-1", id: 1 }] });
});
```

That wraps up part 2 - in part 3, I'll return to my sample guitar pedals API and add a couple more production-ready touches to my Express API.
