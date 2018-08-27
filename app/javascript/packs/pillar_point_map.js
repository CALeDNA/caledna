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
  if (data.researchProjectData) {
    var gbifOccurrences = data.researchProjectData
      .gbif_occurrences.data.map(baseMap.formatGBIFData)

    gbifMarkerLayer = baseMap.renderIndividualMarkers(gbifOccurrences, map)
    map.addLayer(gbifMarkerLayer);
  }


  calMarkerLayer =
    baseMap.createMarkerCluster(data.samplesData, baseMap.createIconMarker)
  map.addLayer(calMarkerLayer);
})

var PP_SMCA = [
  [37.49505, -122.49725],[37.49968, -122.49853],[37.50014, -122.56366],
  [37.48228, -122.56452],[37.48281, -122.50927],[37.49505, -122.49725]
]

var PP_non_protected_exposed = [
  [37.49589, -122.49949],[37.48, -122.50989],[37.46919, -122.5163],
  [37.46892, -122.49787],[37.46904, -122.48725],[37.46932, -122.48153],
  [37.46931, -122.48026],[37.47909, -122.48171],[37.49355, -122.48493],
  [37.49415, -122.48799],[37.49249, -122.49342],[37.49565, -122.49499],
  [37.49617, -122.49598],[37.49605, -122.49774],[37.49589, -122.49949]
]

var PP_non_protected_embankment = [
  [37.49731, -122.49666],[37.49629, -122.49596],[37.49556, -122.49508],
  [37.49296, -122.49348],[37.49513, -122.48583],[37.4972, -122.47904],
  [37.50022, -122.47429],[37.50107, -122.47402],[37.50354, -122.47859],
  [37.5036, -122.48487],[37.50394, -122.4883],[37.50239, -122.49246],
  [37.50187, -122.49482],[37.50043, -122.49639],[37.4987, -122.49661],
  [37.49731, -122.49666]
]


L.polygon(PP_SMCA, {color: 'red'}).addTo(map);
L.polygon(PP_non_protected_exposed, {color: 'blue'}).addTo(map);
L.polygon(PP_non_protected_embankment, {color: 'orange'}).addTo(map);
