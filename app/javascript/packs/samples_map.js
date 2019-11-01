import baseMap from "./base_map.js";
import {
  addSubmitHandler,
  addResetHandler,
  addOptionsHander,
  addSubmitSearchHandler
} from "../utils/data_viz_filters";

const baseFilters = { status: [], substrate: [], primer: [], keyword: [] };
let currentFilters = { status: [], substrate: [], primer: [], keyword: [] };
let endpoint = "/api/v1/samples";
let map = baseMap.createMap();
let markerClusterLayer = null;

function initApp(url) {
  baseMap.fetchSamples(url, map, function(data) {
    if (markerClusterLayer) {
      markerClusterLayer.clearLayers();
    }
    markerClusterLayer = baseMap.createMarkerCluster(
      data.samplesData,
      baseMap.createCircleMarker
    );
    map.addLayer(markerClusterLayer);
  });
}

baseMap.createOverlayEventListeners(map);
baseMap.createOverlays(map);
baseMap.addMapLayerModal(map);

// =============
// event listeners
// =============

const optionEls = document.querySelectorAll(".filter-option");

function setFilters(newFilters) {
  currentFilters = newFilters;
  // console.log('currentFilters', currentFilters)
}

function resetFilters() {
  currentFilters = JSON.parse(JSON.stringify(baseFilters));
  // console.log('currentFilters', currentFilters)
}

function fetchFilters() {
  return currentFilters;
}

addOptionsHander(optionEls, fetchFilters, setFilters);
addSubmitHandler(initApp, endpoint, fetchFilters);
addResetHandler(initApp, endpoint, resetFilters);
addSubmitSearchHandler(initApp, endpoint, fetchFilters, setFilters);

// =============
// init
// =============

initApp(endpoint);
