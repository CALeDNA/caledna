import baseMap from "./base_map.js";

const apiEndpoint = "/api/v1/research_projects/la_river/sites";

const map1 = createMap(
  "map_hahamongna",
  L.latLng(34.2037721328895, -118.166393190622)
);
const map2 = createMap(
  "map_maywood",
  L.latLng(33.9869566476661, -118.171871602535)
);

baseMap.fetchSamples(apiEndpoint, map1, function(data) {
  createMarkerLayer(data.samplesData, map1);
  createMarkerLayer(data.samplesData, map2);
});

function createMarkerLayer(data, map) {
  var markers = data.map(record => {
    return baseMap.createCircleMarker(record);
  });

  L.layerGroup(markers).addTo(map);
}

function createMap(selector, latLng) {
  const map = L.map(selector, {
    center: latLng,
    zoom: 17,
    maxZoom: 18
  });

  L.tileLayer(baseMap.tileLayerOptions.cartoPositron.tile, {
    attribution: baseMap.tileLayerOptions.cartoPositron.attribution
  }).addTo(map);
  return map;
}
