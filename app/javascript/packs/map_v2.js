import baseMap from './base_map.js';

var apiEndpoint = `/api/v1/samples`;
var map = baseMap.createMap()

baseMap.fetchSamples(apiEndpoint, map, function(data) {
  var markerClusterLayer =
    baseMap.createMarkerCluster(data.samplesData, baseMap.createCircleMarker)
  map.addLayer(markerClusterLayer);
  baseMap.createOverlayEventListeners(map);
  baseMap.createOverlays(map);
  baseMap.addEventListener(map, data.samplesData);
  baseMap.addMapLayerModal(map);
})
