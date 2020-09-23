// import { ecotopesJson } from "./data/ecotopes.js";
import { riversJson } from "../data/rivers.js";
import { watershedJson } from "../data/watershed.js";
import { LARWMP2018Json } from "../data/sites_2018.js";

import L from "leaflet";

export function initMap() {
  var map = L.map("map", {
    zoomControl: true,
    maxZoom: 28,
    minZoom: 1,
    initialZoom: 7,
  }).fitBounds([
    [33.679246670913905, -118.6974911092205],
    [34.45898102165338, -117.94488821092733],
  ]);
  map.attributionControl.setPrefix(
    '<a href="https://github.com/tomchadwin/qgis2web" target="_blank">qgis2web</a> &middot; <a href="https://leafletjs.com" title="A JS library for interactive maps">Leaflet</a> &middot; <a href="https://qgis.org">QGIS</a>'
  );

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
    color: "rgba(35,35,35,1.0)",
    dashArray: "",
    lineCap: "butt",
    lineJoin: "miter",
    weight: 1.0,
    fill: true,
    fillOpacity: 0.5,
    fillColor: "rgba(255,231,199,1.0)",
    interactive: false,
  };

  return new L.geoJson(watershedJson, {
    style: style,
  });
}

export function createLARWMP2018() {
  var pointStyle = {
    radius: 5,
    fillColor: "#ff7800",
    color: "#000",
    weight: 1,
    opacity: 1,
    fillOpacity: 0.8,
  };
  return new L.geoJson(LARWMP2018Json, {
    pointToLayer: function(_feature, latlng) {
      return L.circleMarker(latlng, pointStyle);
    },
  });
}
