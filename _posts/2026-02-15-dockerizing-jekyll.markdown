---
layout: post
title:  "Dockerising your Jekyll blog to run locally"
date:   2026-02-15 12:00:00 +1100
categories: general
---

I first set up this blog (my third blog) almost 10 years ago. Since then, I've moved between computers and have generally forgotten how Jekyll - the blog technology underpinned by Ruby - works. As at now, I don't even have Ruby installed; I treat blog files on my current computer as just a collection of markdown (blog post) files.

Which has issues.

As I mentioned in my earlier [post on Vale]({% post_url 2026-02-02-linting-your-blog %}), I author blog posts in markdown using VS Code, and then push to GitHub. GitHub Pages actions take care of automating publishing in HTML format to my blog.

While I can _preview_ markdown files in VS Code, they don't use my blog's styles, and so it bothered me that I had to wait until posts were published to see how they really look. This often means a bit of back and forth editing typos, and even worse, a long wait if I got the date wrong in the post itself (Jekyll has a neat feature to hide posts until a specified date & time, which I don't use).

So, time to research how to run my blog locally, again.

## Docker to the rescue

Docker is the perfect tool to run my blog locally, when I need to. I won't need to set up a local server to host it, and try and mimic GitHub Pages actions. I just use Docker to run it on demand, then proofread and make edits. Finally, I push to GitHub as normal.

Here's what I needed to do to get my Jekyll blog running locally using Docker on Mac:

- make sure Docker Desktop is running
- in my blog root directory, create a minimal `Gemfile` and `Gemfile.lock` (I did not have these already, apparently not needed by GitHub Pages)
- here's the `Gemfile`:

```ruby
source "https://rubygems.org"

# minimal Gemfile to run blog in Docker
gem "github-pages", group: :jekyll_plugins
```

- after saving `Gemfile`, I generated `Gemfile.lock` using Docker: `docker run --rm -v "$PWD:/site" -w /site ruby:3.2 \
 bash -c "gem install bundler && bundle install"`
- or, you can just copy my already-generated file, see <https://raw.githubusercontent.com/thomasswilliams/thomasswilliams.github.io/refs/heads/master/Gemfile.lock>
  - note it doesn't matter if `Gemfile` and `Gemfile.lock` are pushed to GitHub (it won't impact GitHub Pages)
- next, I created a `Dockerfile` and `.dockerignore`, both in the blog root diectory:

```dockerfile
# use minimal Ruby image
FROM ruby:3.2-slim

# updates, install dependencies
#  * build-essential: needed for native Ruby extensions
#  * git: required by some Jekyll/GitHub Pages plugins
RUN apt-get update && apt-get install -y \
    build-essential \
    git \
    && rm -rf /var/lib/apt/lists/*

# set working directory inside container
WORKDIR /site

# copy Gemfiles first for caching
COPY Gemfile Gemfile.lock ./
# install bundler + project dependencies
RUN gem install bundler && bundle install

# copy the rest of the site
COPY . .

# expose port 4000 (default Jekyll port)
EXPOSE 4000

# run Jekyll with live reload for local development
CMD ["bundle", "exec", "jekyll", "serve", "--host", "0.0.0.0", "--livereload"]
```

- I also needed to create a `.dockerignore` - see mine at <https://raw.githubusercontent.com/thomasswilliams/thomasswilliams.github.io/refs/heads/master/.dockerignore>
- now that I have a `Dockerfile` and `.dockerignore`, I'll build an image "jekyll-blog":

```bash
docker build -t jekyll-blog .
```

## The results

Now, any time I want, I can run my blog locally in a container with live reloading on port 4000 (the volume mount `-v "$PWD:/site"` allows live editing):

```bash
docker run \
  -p 4000:4000 \
  -v "$PWD:/site" \
  jekyll-blog
```

Then I open <http://localhost:4000/> in a browser. I can stop the container with Ctrl+C.

This is really helpful to preview what my blog posts will look like before publishing to the world. Saving a file in VS Code triggers Jekyll to regenerate the blog post HTML locally.

And just like the `Gemfile` and `Gemfile.lock` files, it doesn't matter if `Dockerfile` and `.dockerignore` get pushed to GitHub - they're ignored by GitHub Pages actions.
