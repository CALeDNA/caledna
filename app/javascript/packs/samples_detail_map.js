import baseMap from "./base_map.js";

var apiEndpoint = `/api/v1${window.location.pathname}`;
var map = baseMap.createMap();
baseMap.fetchSamples(apiEndpoint, map, function(data) {
  var sample = data.samplesData[0];

  var marker = baseMap.createCircleMarker(sample);
  marker.addTo(map);
  map.panTo(new L.LatLng(sample.lat, sample.lng));
});

baseMap.createOverlayEventListeners(map);
baseMap.createOverlays(map);
baseMap.addMapLayerModal(map);
