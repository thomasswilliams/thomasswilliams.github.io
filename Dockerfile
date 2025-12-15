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
