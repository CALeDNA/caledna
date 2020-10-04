// import { ecotopesJson } from "./data/ecotopes.js";
import { riversJson } from "../data/rivers.js";
import { watershedJson } from "../data/watershed.js";
import { LARWMP2018Json } from "../data/sites_2018.js";
import { ckmeans } from 'simple-statistics'

import base_map from "./base_map";

import L from "leaflet";
import "leaflet-svg-shape-markers";

export function initMap() {
  var map = L.map("map", {
    zoomControl: true,
    maxZoom: 28,
    minZoom: 6,
    layers: [base_map.tileLayers.Minimal],
  }).fitBounds([
    [33.679246670913905, -118.6974911092205],
    [34.45898102165338, -117.94488821092733],
  ]);

  let tiles = base_map.tileLayers;
  tiles["None"] = L.tileLayer("");

  L.control.layers(base_map.tileLayers).addTo(map);

  return map;
}

export function createImageLayer(rasterFile) {
  var imgBounds = [
    [33.75434896789, -118.72052904751999],
    [34.400436624200005, -117.94987526768],
  ];
  return new L.imageOverlay(rasterFile, imgBounds);
}

// function style_ecotopes() {
//   return {
//     opacity: 1,
//     color: "rgba(35,35,35,1.0)",
//     dashArray: "",
//     lineCap: "butt",
//     lineJoin: "miter",
//     weight: 1.0,
//     fill: true,
//     fillOpacity: 1,
//     fillColor: "rgba(243,166,178,1.0)",
//     interactive: false,
//   };
// }

export function pourLocationsLayer(places) {
  var pointStyle = {
    shape: "triangle",
    radius: 6,
    color: "#222",
    fillColor: "#5aa172",
    fillOpacity: 0.7,
    weight: 2,
  };

  let markers = places.map((place) => {
    let popup = `
      <p>Protecting Our River</p>

      <table class="map-popup">
        <tr>
          <th scope="row">Name</th>
          <td><a href="/places/${place.id}">${place.name}</a></td>
        </tr>
        <tr>
          <th scope="row">Latitude</th>
          <td>${place.latitude}</td>
        </tr>
        <tr>
          <th scope="row">Longitude</th>
          <td>${place.longitude}</td>
        </tr>
      </table>
    `;
    let marker = L.shapeMarker([place.latitude, place.longitude], pointStyle);
    marker.bindPopup(popup);
    return marker;
  });
  return L.layerGroup(markers);
}

export function pourEdnaLayer(samples, color, taxonName) {
  let markers = samples.map((sample) => {
    let popup = `
      <p>eDNA Site for ${taxonName}</p>

      <table class="map-popup">
        <tr>
          <th scope="row">Name</th>
          <td><a href="/samples/${sample.id}">${sample.barcode}</a></td>
        </tr>
        <tr>
          <th scope="row">Latitude</th>
          <td>${sample.latitude}</td>
        </tr>
        <tr>
          <th scope="row">Longitude</th>
          <td>${sample.longitude}</td>
        </tr>
      </table>
    `;
    sample["body"] = popup;

    return base_map.createCircleMarker(sample, { fillColor: color, weight: 1 });
  });
  return L.layerGroup(markers);
}

function calculateGraduatedColor(sample, samples, colors) {
  let counts = samples.map(s => (s.count))
  let clusters = ckmeans(counts, 5);

  var stops = [clusters[1][0], clusters[2][0], clusters[3][0], clusters[4][0]];
  if (sample.count < stops[0]) {
    // console.log("0, ", sample.count);
    return colors[0];
  } else if (sample.count < stops[1]) {
    // console.log("1 ", sample.count);
    return colors[1];
  } else if (sample.count < stops[2]) {
    // console.log("2", sample.count);
    return colors[2];
  } else if (sample.count < stops[3]) {
    // console.log("3 ", sample.count);
    return colors[3];
  } else {
    // console.log("4 ", sample.count);
    return colors[4];
  }
}

export function pourGbifLayer(samples, colors, taxonName) {
  let markers = samples.map((sample) => {
    function createPopup(feature, layer) {
      let popup = `
      <p>iNaturalist Observations for ${taxonName}</p>

      <table class="map-popup">
        <tr>
          <th scope="row">Count</th>
          <td>${sample.count} observations</td>
        </tr>
        <tr>
          <th scope="row">Latitude</th>
          <td>${sample.latitude}</td>
        </tr>
        <tr>
          <th scope="row">Longitude</th>
          <td>${sample.longitude}</td>
        </tr>
      </table>
    `;

      layer.bindPopup(popup, { maxHeight: 400 });
    }

    let color = calculateGraduatedColor(sample, samples, colors);

    var myStyle = {
      color: colors[2],
      fillColor: color,
      fillOpacity: 0.9,
      weight: 1,
      opacity: 0.9,
    };

    return L.geoJSON(JSON.parse(sample.geom), {
      onEachFeature: createPopup,
      style: myStyle,
    });
  });
  return L.layerGroup(markers);
}

export function createRiverLayer() {
  var style = {
    opacity: 1,
    color: "rgba(19,133,255,1.0)",
    dashArray: "",
    lineCap: "square",
    lineJoin: "bevel",
    weight: 2.0,
    fillOpacity: 0,
    interactive: true,
  };

  function createPopup(feature, layer) {
    let popup = `
      <p>LA River Watershed</p>
      <table class="map-popup">
        <tr>
          <th scope="row">Name</th>
          <td>${feature.properties["GNIS_NAME"]}</td>
        </tr>
      </table>
    `;

    layer.bindPopup(popup, { maxHeight: 400 });
  }

  return new L.geoJson(riversJson, {
    style: style,
    onEachFeature: createPopup,
    interactive: true,
  });
}

export function createWatershedLayer() {
  var style = {
    opacity: 1,
    color: "rgba(35,35,35,0.7)",
    dashArray: "",
    lineCap: "butt",
    lineJoin: "miter",
    weight: 2.0,
    fill: true,
    fillOpacity: 0.2,
    fillColor: "rgba(190,190,190,0.9)",
    interactive: false,
  };

  return new L.geoJson(watershedJson, {
    style: style,
  });
}

export function createLARWMP2018() {
  var pointStyle = {
    shape: "triangle",
    radius: 6,
    color: "#222",
    fillColor: "orange",
    fillOpacity: 0.7,
    weight: 2,
  };

  function createPopup(feature, layer) {
    let popup = `
      <p>Los Angeles River Watershed Monitoring Program</p>

      <table class="map-popup">
        <tr>
          <th scope="row">Name</th>
          <td>${feature.properties["FieldSampleID"]}</td>
        </tr>
        <tr>
          <th scope="row">Station Type</th>
          <td>${feature.properties["StationType"]}</td>
        </tr>
        <tr>
          <th scope="row">Latitude</th>
          <td>${feature.properties["NominalLatitude"]}</td>
        </tr>
        <tr>
          <th scope="row">Longitude</th>
          <td>${feature.properties["NominalLongitude"]}</td>
        </tr>
      </table>
    `;

    layer.bindPopup(popup, { maxHeight: 400 });
  }

  return new L.geoJson(LARWMP2018Json, {
    onEachFeature: createPopup,
    pointToLayer: function (_feature, latlng) {
      return L.shapeMarker(latlng, pointStyle);
    },
  });
}

let markerSettings = {
  shape: "square",
  radius: 7,
  opacity: 0.7,
  dashArray: "",
  lineCap: "butt",
  lineJoin: "miter",
  weight: 1,
  fill: true,
  fillOpacity: 0.7,
  interactive: true,
  color: "#222",
};

function sites_2018_popup(feature, analyte) {
  let value = feature.properties[analyte];
  return `
    <p>${analyte}</p>
    <table class="map-popup">
      <tr>
        <th scope="row">Name</th>
        <td>${feature.properties["FieldSampleID"]}</td>
      </tr>
      <tr>
        <th scope="row">Latitude</th>
        <td>${feature.properties["NominalLatitude"]}</td>
      </tr>
      <tr>
        <th scope="row">Longitude</th>
        <td>${feature.properties["NominalLongitude"]}</td>
      </tr>
      <tr>
        <th scope="row">${analyte}</th>
        <td>${value}</td>
      </tr>
    </table>
  `;
}

function style_sites_2018_temperature(feature) {
  if (feature.properties["Temperature (C°)"] === null) {
    return {
      opacity: 0,
      fillOpacity: 0,
    };
  } else if (
    feature.properties["Temperature (C°)"] >= 14.1 &&
    feature.properties["Temperature (C°)"] <= 18.182
  ) {
    return {
      ...markerSettings,
      fillColor: "rgba(247,251,255,1.0)",
    };
  } else if (
    feature.properties["Temperature (C°)"] >= 18.182 &&
    feature.properties["Temperature (C°)"] <= 22.264
  ) {
    return {
      ...markerSettings,
      fillColor: "rgba(200,221,240,1.0)",
    };
  } else if (
    feature.properties["Temperature (C°)"] >= 22.264 &&
    feature.properties["Temperature (C°)"] <= 26.346
  ) {
    return {
      ...markerSettings,
      fillColor: "rgba(115,179,216,1.0)",
    };
  } else if (
    feature.properties["Temperature (C°)"] >= 26.346 &&
    feature.properties["Temperature (C°)"] <= 30.428
  ) {
    return {
      ...markerSettings,
      fillColor: "rgba(40,121,185,1.0)",
    };
  } else if (
    feature.properties["Temperature (C°)"] >= 30.428 &&
    feature.properties["Temperature (C°)"] <= 34.51
  ) {
    return {
      ...markerSettings,
      fillColor: "rgba(8,48,107,1.0)",
    };
  }
}

function sites_2018_temperature_popup(feature, layer) {
  let analyte = "Temperature (C°)";
  let popup = sites_2018_popup(feature, analyte);
  layer.bindPopup(popup);
}

export const sites_2018_temperature = new L.geoJson(LARWMP2018Json, {
  onEachFeature: sites_2018_temperature_popup,
  pointToLayer: function (feature, latlng) {
    return L.shapeMarker(latlng, style_sites_2018_temperature(feature));
  },
});

function style_sites_2018_oxygen(feature) {
  if (feature.properties["Dissolved Oxygen (mg/L)"] === null) {
    return {
      opacity: 0,
      fillOpacity: 0,
    };
  } else if (
    feature.properties["Dissolved Oxygen (mg/L)"] >= 3.06 &&
    feature.properties["Dissolved Oxygen (mg/L)"] <= 5.008
  ) {
    return {
      ...markerSettings,
      fillColor: "rgba(247,251,255,1.0)",
    };
  } else if (
    feature.properties["Dissolved Oxygen (mg/L)"] >= 5.008 &&
    feature.properties["Dissolved Oxygen (mg/L)"] <= 6.956
  ) {
    return {
      ...markerSettings,
      fillColor: "rgba(200,221,240,1.0)",
    };
  } else if (
    feature.properties["Dissolved Oxygen (mg/L)"] >= 6.956 &&
    feature.properties["Dissolved Oxygen (mg/L)"] <= 8.904
  ) {
    return {
      ...markerSettings,
      fillColor: "rgba(115,179,216,1.0)",
    };
  } else if (
    feature.properties["Dissolved Oxygen (mg/L)"] >= 8.904 &&
    feature.properties["Dissolved Oxygen (mg/L)"] <= 10.852
  ) {
    return {
      ...markerSettings,
      fillColor: "rgba(40,121,185,1.0)",
    };
  } else if (
    feature.properties["Dissolved Oxygen (mg/L)"] >= 10.852 &&
    feature.properties["Dissolved Oxygen (mg/L)"] <= 12.8
  ) {
    return {
      ...markerSettings,
      fillColor: "rgba(8,48,107,1.0)",
    };
  }
}

function sites_2018_oxygen_popup(feature, layer) {
  let analyte = "Dissolved Oxygen (mg/L)";
  let popup = sites_2018_popup(feature, analyte);
  layer.bindPopup(popup);
}

export const sites_2018_oxygen = new L.geoJson(LARWMP2018Json, {
  onEachFeature: sites_2018_oxygen_popup,
  pointToLayer: function (feature, latlng) {
    return L.shapeMarker(latlng, style_sites_2018_oxygen(feature));
  },
});

function style_sites_2018_ph(feature) {
  if (feature.properties["pH"] === null) {
    return {
      opacity: 0,
      fillOpacity: 0,
    };
  } else if (
    feature.properties["pH"] >= 7.42 &&
    feature.properties["pH"] <= 7.888
  ) {
    return {
      ...markerSettings,
      fillColor: "rgba(247,251,255,1.0)",
    };
  } else if (
    feature.properties["pH"] >= 7.888 &&
    feature.properties["pH"] <= 8.356
  ) {
    return {
      ...markerSettings,
      fillColor: "rgba(200,221,240,1.0)",
    };
  } else if (
    feature.properties["pH"] >= 8.356 &&
    feature.properties["pH"] <= 8.824
  ) {
    return {
      ...markerSettings,
      fillColor: "rgba(115,179,216,1.0)",
    };
  } else if (
    feature.properties["pH"] >= 8.824 &&
    feature.properties["pH"] <= 9.292
  ) {
    return {
      ...markerSettings,
      fillColor: "rgba(40,121,185,1.0)",
    };
  } else if (
    feature.properties["pH"] >= 9.292 &&
    feature.properties["pH"] <= 9.76
  ) {
    return {
      ...markerSettings,
      fillColor: "rgba(8,48,107,1.0)",
    };
  }
}

function sites_2018_ph_popup(feature, layer) {
  let analyte = "pH";
  let popup = sites_2018_popup(feature, analyte);
  layer.bindPopup(popup);
}

export const sites_2018_ph = new L.geoJson(LARWMP2018Json, {
  onEachFeature: sites_2018_ph_popup,
  pointToLayer: function (feature, latlng) {
    return L.shapeMarker(latlng, style_sites_2018_ph(feature));
  },
});

function style_sites_2018_salinity(feature) {
  if (feature.properties["Salinity (ppt)"] === null) {
    return {
      opacity: 0,
      fillOpacity: 0,
    };
  } else if (
    feature.properties["Salinity (ppt)"] >= 0.0 &&
    feature.properties["Salinity (ppt)"] <= 0.0
  ) {
    return {
      ...markerSettings,
      fillColor: "rgba(247,251,255,1.0)",
    };
  } else if (
    feature.properties["Salinity (ppt)"] >= 0.0 &&
    feature.properties["Salinity (ppt)"] <= 0.236
  ) {
    return {
      ...markerSettings,
      fillColor: "rgba(200,221,240,1.0)",
    };
  } else if (
    feature.properties["Salinity (ppt)"] >= 0.236 &&
    feature.properties["Salinity (ppt)"] <= 0.368
  ) {
    return {
      ...markerSettings,
      fillColor: "rgba(115,179,216,1.0)",
    };
  } else if (
    feature.properties["Salinity (ppt)"] >= 0.368 &&
    feature.properties["Salinity (ppt)"] <= 0.482
  ) {
    return {
      ...markerSettings,
      fillColor: "rgba(40,121,185,1.0)",
    };
  } else if (
    feature.properties["Salinity (ppt)"] >= 0.482 &&
    feature.properties["Salinity (ppt)"] <= 1.78
  ) {
    return {
      ...markerSettings,
      fillColor: "rgba(8,48,107,1.0)",
    };
  }
}

function sites_2018_salinity_popup(feature, layer) {
  let analyte = "Salinity (ppt)";
  let popup = sites_2018_popup(feature, analyte);
  layer.bindPopup(popup);
}

export const sites_2018_salinity = new L.geoJson(LARWMP2018Json, {
  onEachFeature: sites_2018_salinity_popup,
  pointToLayer: function (feature, latlng) {
    return L.shapeMarker(latlng, style_sites_2018_salinity(feature));
  },
});

function style_sites_2018_conductivity(feature) {
  if (feature.properties["Specific Conductivity (us/cm)"] === null) {
    return {
      opacity: 0,
      fillOpacity: 0,
    };
  } else if (
    feature.properties["Specific Conductivity (us/cm)"] >= 0.0 &&
    feature.properties["Specific Conductivity (us/cm)"] <= 0.0
  ) {
    return {
      ...markerSettings,
      fillColor: "rgba(247,251,255,1.0)",
    };
  } else if (
    feature.properties["Specific Conductivity (us/cm)"] >= 0.0 &&
    feature.properties["Specific Conductivity (us/cm)"] <= 497.64
  ) {
    return {
      ...markerSettings,
      fillColor: "rgba(200,221,240,1.0)",
    };
  } else if (
    feature.properties["Specific Conductivity (us/cm)"] >= 497.64 &&
    feature.properties["Specific Conductivity (us/cm)"] <= 690.0
  ) {
    return {
      ...markerSettings,
      fillColor: "rgba(115,179,216,1.0)",
    };
  } else if (
    feature.properties["Specific Conductivity (us/cm)"] >= 690.0 &&
    feature.properties["Specific Conductivity (us/cm)"] <= 978.4
  ) {
    return {
      ...markerSettings,
      fillColor: "rgba(40,121,185,1.0)",
    };
  } else if (
    feature.properties["Specific Conductivity (us/cm)"] >= 978.4 &&
    feature.properties["Specific Conductivity (us/cm)"] <= 3371.0
  ) {
    return {
      ...markerSettings,
      fillColor: "rgba(8,48,107,1.0)",
    };
  }
}

function sites_2018_conductivity_popup(feature, layer) {
  let analyte = "Specific Conductivity (us/cm)";
  let popup = sites_2018_popup(feature, analyte);
  layer.bindPopup(popup);
}

export const sites_2018_conductivity = new L.geoJson(LARWMP2018Json, {
  onEachFeature: sites_2018_conductivity_popup,
  pointToLayer: function (feature, latlng) {
    return L.shapeMarker(latlng, style_sites_2018_conductivity(feature));
  },
});

function randomHslRange() {
  let rand = Math.floor(Math.random() * 360);
  return [
    `hsla(${rand}, 10%, 50%, 1)`,
    `hsla(${rand}, 30%, 50%, 1)`,
    `hsla(${rand}, 50%, 50%, 1)`,
    `hsla(${rand}, 70%, 50%, 1)`,
    `hsla(${rand}, 90%, 50%, 1)`,
  ];
}
