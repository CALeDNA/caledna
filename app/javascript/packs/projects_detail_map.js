import baseMap from "./base_map.js";

var resource_and_id = window.location.pathname.replace(/pages\/.*?$/, "");
var query_string = window.location.search;
var apiEndpoint = `/api/v1${resource_and_id}${query_string}`;

var map = baseMap.createMap();
baseMap.fetchSamples(apiEndpoint, map, function(data) {
  var markerClusterLayer = baseMap.createMarkerCluster(
    data.samplesData,
    baseMap.createCircleMarker
  );
  map.addLayer(markerClusterLayer);
});

baseMap.createOverlayEventListeners(map);
baseMap.createOverlays(map);
baseMap.addMapLayerModal(map);
