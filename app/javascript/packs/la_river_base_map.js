import "leaflet-easybutton";

import baseMap from "./base_map.js";
import { riversJson } from "../data/rivers";
import { watershedJson } from "../data/watershed";
// =============
// config map
// =============

var minZoom = 6;
var maxZoom = 25;

// =============
// create map
// =============

function createMap(preferCanvas = true) {
  let tileLayer = baseMap.tileLayersFactory();
  tileLayer["None"] = L.tileLayer('');
  let watershedLayer = createWatershedLayer();
  let riverLayer = createRiverLayer();

  let map = L.map("mapid", {
    preferCanvas: preferCanvas,
    maxZoom: maxZoom,
    minZoom: minZoom,
    layers: [tileLayer.Streets, watershedLayer, riverLayer],
  }).fitBounds([
    [33.75, -118.72],
    [34.40, -117.95],
  ]);

  var overlayMaps = {
    "LA River Watershed": watershedLayer,
    "Rivers": riverLayer,
  };

  // var polygon = L.polygon([
  //   [33.75, -118.72],
  //   [33.75, -117.95],
  //   [34.40, -117.95],
  //   [34.40, -118.72],
  // ]).addTo(map);

  L.control.layers(tileLayer, overlayMaps).addTo(map);

  return map;
}

// =============
// format data
// =============

function formatPlaceData(place) {
  return {
    id: place.id,
    latitude: place.latitude,
    longitude: place.longitude,
    body: `
    <table class="map-popup">
      <tbody>
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
        <tr>
          <th scope="row">Sites</th>
          <td>${place.site_count}</td>
        </tr>
      </tbody>
    </table>
    `,
  };
}

// =============
// overlays
// =============

function createRiverLayer() {
  var style = {
    opacity: .8,
    color: "rgba(19,133,255,1.0)",
    weight: 1.75,
  };

  function createPopup(feature, layer) {
    let popup = `
      <table class="map-popup">
        <tr>
          <td> ${feature.properties["GNIS_NAME"]}</td>
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

function createWatershedLayer() {
  var style = {
    opacity: 1,
    color: "rgba(100,100,100,1)",
    weight: 2.0,
    fillOpacity: 0.3,
    fillColor: "rgba(190,190,190,0.9)",
    interactive: false,
  };

  return new L.geoJson(watershedJson, {
    style: style,
    interactive: false,
  });
}

export default {
  formatPlaceData,
  createMap,
  createWatershedLayer,
  createRiverLayer
};
