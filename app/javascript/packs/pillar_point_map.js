import baseMap from './base_map.js';

var apiEndpoint = `/api/v1/research_projects/pillar-point?include_research=true`;
var map = baseMap.createMap(L.latLng(37.49547, -122.496478), 15)

var sources = { cal: true, gbif: true }
var gbifMarkerLayer;
var calMarkerLayer;
var source;

var sourceEls = document.querySelectorAll('.js-source')
sourceEls.forEach(function(el){
  el.addEventListener('click', chooseSourceHandler)
})

function chooseSourceHandler(e) {
  source = e.target.dataset.source
  var isChecked = e.target.checked

  if (source == 'cal') {
    if(isChecked) {
      if (!sources.cal) {
        map.addLayer(calMarkerLayer);
        sources.cal = true
      }
    } else {
      map.removeLayer(calMarkerLayer);
      sources.cal = false
    }
  } else if (source == 'gbif') {
    if(isChecked) {
      if (!sources.gbif) {
        map.addLayer(gbifMarkerLayer);
        sources.gbif = true
      }
    } else {
      map.removeLayer(gbifMarkerLayer);
      sources.gbif = false
    }
  }
}

baseMap.fetchSamples(apiEndpoint, map, function(data) {
  var gbifOccurrences = data.researchProjectData
    .gbif_occurrences.data.map(baseMap.formatGBIFData)

  gbifMarkerLayer = baseMap.renderIndividualMarkers(gbifOccurrences, map)
  map.addLayer(gbifMarkerLayer);

  calMarkerLayer =
    baseMap.createMarkerCluster(data.samplesData, baseMap.createIconMarker)
  map.addLayer(calMarkerLayer);
})