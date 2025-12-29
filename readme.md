
My blog, built with Jekyll on Github Pages. See <https://thomasswilliams.github.io/>.

Note the `_site` directory represents generated output (the built static site) and should not be committed to Github.

To develop locally using Docker:

* build the image (make sure Docker is running):

```bash
docker build -t jekyll-blog .
```

* run container (volume mount `-v "$PWD:/site"` allows live editing of files on the host without rebuilding the Docker image):

```bash
docker run \
  -p 4000:4000 \
  -v "$PWD:/site" \
  jekyll-blog
```

* open <http://localhost:4000/> in a browser

Stop the container with Ctrl+C.
