---
layout: post
title:  "Displaying text labels instead of markers from GeoJSON on a Leaflet Antarctic map (part 3)"
date:   2022-06-02 12:00:00 +1000
categories: development
---

Continuing my Leaflet series, in this post I'll be looking at loading labels from a GeoJSON file.

In [part 1a]({% post_url 2022-05-12-leaflet-antarctica-demo-1a %}) I covered loading a GeoJSON file and displaying custom icon markers. This post follows a similar process with a couple of feature names & coordinates from GeoNames, instead of markers showing text labels:

- download GeoNames file (CSV format)
  - country "AQ" from <https://download.geonames.org/export/dump/>
  - see field names at <https://download.geonames.org/export/dump/readme.txt>
- the CSV file has lots of features (around 13,000); for this demo, I got rid of unneeded features
  - I did this in Excel using filters, leaving about 4 features
- create a GeoJSON file from the CSV
  - once again, I did this in Excel using my favorite function, `SUBSTITUTE`
  - e.g. have GeoJSON text with placeholders in a cell in the top row, for instance cell G1 `{ "type": "Feature", "geometry": {"type": "Point", "coordinates": [{1}, {2}] },  "properties": { "name": "{3}", "description": "{4}" },`
  - replace the placeholders in curly braces with values using `SUBSTITUTE`, multiple times e.g `=SUBSTITUTE($G$1, "{1}", $A2)` _(this says, replace just the {1} part, with the contents of cell A2)_
    - watch out for embedded double quotes
  - copy/paste the resulting substituted text to a text file, format to be GeoJSON, save

The updated map is at <https://thomasswilliams.github.io/leaflet-antarctic-demo/>.

Here's the code to load the GeoJSON file and display each point as a Leaflet `DivIcon`:

```javascript
// ************************************************************************
// load small selection of feature names from GeoJSON file and add as a layer
// each point in the GeoJSON file will be a label (text) with no marker
// feature names should not be interactive
// ************************************************************************
fetch('./geonames-selected-feature-names.json')
  // convert the response to JSON object
  .then(response => response.json())
  .then(data => {
    // create new Leaflet layer from JSON object
    L.geoJSON(data, {
      pointToLayer: (feature, latlng) => {
        // create a DivIcon at the lat/long
        // see docs at https://leafletjs.com/reference.html#divicon
        return L.marker(latlng, {
          icon: new L.DivIcon({
            className: 'feature-name-label',
            // the text of the DivIcon will be "name" property
            html: feature.properties.name
          })
        });
      },
      className: 'feature-names-layer',
      interactive: false
    }).addTo(map);
  });
```

To prevent clicks on the text labels, I disabled interactivity using CSS:

```css
/* feature name label */
.feature-name-label {
  color: #99999a;
  font-style: italic;
  font-size: 10px;
  /* disable interactivity */
  pointer-events: none !important;
  user-select: none;
}
```

This code, and the GeoJSON file, can be found at the [GitHub repo](https://github.com/thomasswilliams/leaflet-antarctic-demo).