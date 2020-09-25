// import { ecotopesJson } from "./data/ecotopes.js";
import { riversJson } from "../data/rivers.js";
import { watershedJson } from "../data/watershed.js";
import { LARWMP2018Json } from "../data/sites_2018.js";
import base_map from "./base_map";

import L from "leaflet";
import "leaflet-svg-shape-markers";

export function initMap() {
  var map = L.map("map", {
    zoomControl: true,
    maxZoom: 28,
    minZoom: 1,
    initialZoom: 7,
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

export function createPourLayer(places) {
  var pointStyle = {
    shape: "triangle",
    radius: 6,
    color: "#222",
    fillColor: "#5aa172",
    fillOpacity: 0.7,
    weight: 2,
  };

  let markers = places.map((place) => {
    return L.shapeMarker([place.latitude, place.longitude], pointStyle);
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
    weight: 1.0,
    fillOpacity: 0,
    interactive: false,
  };

  return new L.geoJson(riversJson, {
    style: style,
  });
}

export function createWatershedLayer() {
  var style = {
    opacity: 1,
    color: "rgba(35,35,35,0.7)",
    dashArray: "",
    lineCap: "butt",
    lineJoin: "miter",
    weight: 1.0,
    fill: true,
    fillOpacity: 0.2,
    fillColor: "rgba(255,231,199,0.9)",
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
  return new L.geoJson(LARWMP2018Json, {
    pointToLayer: function(_feature, latlng) {
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

export const sites_2018_temperature = new L.geoJson(LARWMP2018Json, {
  pointToLayer: function(feature, latlng) {
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

export const sites_2018_oxygen = new L.geoJson(LARWMP2018Json, {
  pointToLayer: function(feature, latlng) {
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

export const sites_2018_ph = new L.geoJson(LARWMP2018Json, {
  pointToLayer: function(feature, latlng) {
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

export const sites_2018_salinity = new L.geoJson(LARWMP2018Json, {
  pointToLayer: function(feature, latlng) {
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

export const sites_2018_conductivity = new L.geoJson(LARWMP2018Json, {
  pointToLayer: function(feature, latlng) {
    return L.shapeMarker(latlng, style_sites_2018_conductivity(feature));
  },
});
