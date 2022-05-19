---
layout: post
title:  "Loading shapefiles into Leaflet Antarctic map (part 2)"
date:   2022-05-19 12:00:00 +1000
categories: development
---

This post is part of a short series around a demo of a browser based, interactive map using the recently-released version 1.8 of open-source [Leaflet](https://leafletjs.com/). I'm really enjoying using Leaflet (not sponsored!) and posting about the steps I took learning about mapping and Antarctica. Hopefully the posts and associated [code on GitHub](https://github.com/thomasswilliams/leaflet-antarctic-demo) might help others facing the same challenges.

[Part 1 of the series]({% post_url 2022-05-02-leaflet-antarctica-demo %}) ended up with a basic zoomable and pannable map of Antarctica using tiles from Global Biodiversity Information Facility (GBIF). [Part 1a]({% post_url 2022-05-12-leaflet-antarctica-demo-1a %}) added large iceberg positions from a GeoJSON file.

A common theme has been amazing open-source, start with Leaflet and its ecosystem of plugins. The [map](https://thomasswilliams.github.io/leaflet-antarctic-demo/) is hosted for free on GitHub Pages, referencing libraries using the open-source [unpkg CDN](https://unpkg.com/) - which keeps lines of code to a minimum, while providing a fully-featured experience. Most of the functionality is contained in a single `index.html` file for simplicity, and there's nothing to install.

In this post I'll expand the existing code to include shapefiles from the brilliant Quantarctica project at <https://www.npolar.no/en/quantarctica/>:

> Quantarctica is a collection of Antarctic geographical datasets for
> research, education, operations, and management in Antarctica, and
> let you explore, import, visualize, and share Antarctic data. It
> includes community-contributed, peer-reviewed data from ten different
> scientific themes and a professionally-designed basemap.

Although Quantarctica is designed to be used with free, open-source desktop GIS tool QGIS <https://www.qgis.org/en/site/>, we're going to use a couple of shapefiles to add to the Leaflet map (fortunately the shapefiles are also in EPSG:3031 projection).

A shapefile can contain one or more shapes (points, lines, polygons). It's actually a collection of files, with the same name in the same directory, but different extensions. Some of the more common extensions are:

- `.cpg` (code page): text file containing code page/character encoding
- `.dbf` (dBASE Table file): columnar text with properties for shapes
- `.prj` (projection information): text file with coordinate reference system (in our case it's "WGS 84 Antarctic Polar Stereographic" AKA EPSG:3031)
- `.shp` (shapefile): binary geometry file
- `.shx` (index file): binary index file

Like the GeoJSON format, shapefiles have an open specification, are well known, and are interoperable between systems.

To work with shapefiles, we'll be using an open-source library, compatible with Leaflet, called Shapefile.js from <https://github.com/calvinmetcalf/shapefile-js>. Shapefile.js takes shapefiles and makes them into GeoJSON. As a bonus, Shapefile.js is flexible in that we can load either a collection of files as described above, or a ZIP containing the files (which keeps the network traffic down).

After referencing Shapefile.js, here's the code to load and display shapefiles, in this case, latitude and longitude lines from Quantarctica:

```javascript
// ************************************************************************
// load shapefiles (collection of files with same name but different extensions)
// then add GeoJSON layers to map using shapefile-js from https://github.com/calvinmetcalf/shapefile-js
// leave off extension, shapefile-js will load shp, prj, dbf and cpg files
// with same name from same directory
// need full URL, not relative, so use somewhat hacky way to add to current path from
// document.baseURI
// ************************************************************************

// load graticule shapefiles part 1: longitude lines every 30 degrees
// shape files from Quantarctica
shp(new URL(document.baseURI) + '30dg_longitude/30dg_longitude')
  .then((data) => {
    // add GeoJSON layer, set style
    L.geoJson(data, {
      style: () => ({
        // light lines
        color: '#acacad',
        weight: 0.8,
        opacity: 0.5,
        // no fill
        fillColor: 'transparent'
      }),
      // CSS class for styling
      className: 'lat-long-lines-layer',
      // not interactive
      interactive: false
    }).addTo(map);
  });
// load graticule shapefiles part 2: latitude lines (projected as circles)
// in 10 degree increments, only to 40° south
// shape files from Quantarctica
shp(new URL(document.baseURI) + '10dg_latitude/10dg_latitude')
  .then((data) => {
    L.geoJson(data, {
      style: () => ({
        color: '#acacad',
        weight: 0.8,
        opacity: 0.5,
        fillColor: 'transparent'
      }),
      className: 'lat-long-lines-layer',
      interactive: false
    }).addTo(map);
  });
```

The same method could be used to load other shapefiles from Quantarctica or elsewhere.

That's all for part 2. In a future part 3, I'll describe how I'd "productionise" the code to get better performance and a (hopefully) more problem-free experience for people who use the map.