import baseMap from './base_map.js';

var path = window.location.pathname.replace(/pages\/.*?$/, '');
var apiEndpoint = `/api/v1${path}${window.location.search}`;

var map = baseMap.createMap()
baseMap.fetchSamples(apiEndpoint, map, function(data) {
  var markerClusterLayer =
    baseMap.createMarkerCluster(data.samplesData, baseMap.createCircleMarker)
  map.addLayer(markerClusterLayer);
})

baseMap.createOverlayEventListeners(map);
baseMap.createOverlays(map);
baseMap.addMapLayerModal(map);
