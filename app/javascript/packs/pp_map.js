import baseMap from "./base_map.js";

var apiEndpoint = `/api/v1/research_projects/pillar_point/sites?include_research=true`;
var map = baseMap.createMap(L.latLng(37.49547, -122.496478), 15);

var sources = { cal: true, gbif: true };
var gbifMarkerLayer;
var calMarkerLayer;
var source;

var sourceEls = document.querySelectorAll(".js-source");
sourceEls.forEach(function(el) {
  el.addEventListener("click", chooseSourceHandler);
});

function chooseSourceHandler(e) {
  source = e.target.dataset.source;
  var isChecked = e.target.checked;

  if (source == "cal") {
    if (isChecked) {
      if (!sources.cal) {
        map.addLayer(calMarkerLayer);
        sources.cal = true;
      }
    } else {
      map.removeLayer(calMarkerLayer);
      sources.cal = false;
    }
  } else if (source == "gbif") {
    if (isChecked) {
      if (!sources.gbif) {
        map.addLayer(gbifMarkerLayer);
        sources.gbif = true;
      }
    } else {
      map.removeLayer(gbifMarkerLayer);
      sources.gbif = false;
    }
  }
}

baseMap.fetchSamples(apiEndpoint, map, function(data) {
  if (data.researchProjectData) {
    var gbifOccurrences = data.researchProjectData.gbif_occurrences.data.map(
      baseMap.formatGBIFData
    );

    gbifMarkerLayer = baseMap.renderIndividualMarkers(gbifOccurrences, map);
    map.addLayer(gbifMarkerLayer);
  }

  calMarkerLayer = baseMap.createMarkerCluster(
    data.samplesData,
    baseMap.createIconMarker
  );
  map.addLayer(calMarkerLayer);
});

var MONTARA_SMCA = [
  [37.50072, -122.49766],
  [37.50374, -122.49937],
  [37.50537, -122.50076],
  [37.50667, -122.50269],
  [37.50786, -122.50567],
  [37.51279, -122.51087],
  [37.51429, -122.51206],
  [37.51683, -122.51284],
  [37.52038, -122.51422],
  [37.52353, -122.51716],
  [37.52459, -122.51681],
  [37.52764, -122.51674],
  [37.531, -122.51715],
  [37.53366, -122.51875],
  [37.53653, -122.51935],
  [37.53754, -122.51821],
  [37.54058, -122.51727],
  [37.54294, -122.51712],
  [37.54439, -122.51627],
  [37.54494, -122.51649],
  [37.54492, -122.56328],
  [37.50145, -122.56356],
  [37.50145, -122.56356],
  [37.5009, -122.56356],
  [37.50072, -122.51328],
  [37.50072, -122.49766]
];

var PP_SMCA = [
  [37.49581, -122.49943],
  [37.49592, -122.49924],
  [37.49603, -122.49905],
  [37.49692, -122.49923],
  [37.49758, -122.4998],
  [37.49805, -122.49989],
  [37.49883, -122.49935],
  [37.49949, -122.49811],
  [37.50058, -122.49762],
  [37.50058, -122.49836],
  [37.5007, -122.52601],
  [37.47545, -122.52702],
  [37.47545, -122.52702],
  [37.47576, -122.51167],
  [37.48032, -122.50888],
  [37.48392, -122.50669],
  [37.48472, -122.50616],
  [37.48853, -122.5037],
  [37.48938, -122.50315],
  [37.49021, -122.50266],
  [37.49581, -122.49943]
];

var PP_non_protected_exposed = [
  [37.49603, -122.49531],
  [37.49584, -122.49793],
  [37.496, -122.49898],
  [37.4957, -122.49945],
  [37.48992, -122.50275],
  [37.48495, -122.50592],
  [37.48268, -122.50737],
  [37.47653, -122.51103],
  [37.47573, -122.51144],
  [37.47573, -122.51144],
  [37.4758, -122.48295],
  [37.49286, -122.49345],
  [37.49603, -122.49531]
];

var PP_non_protected_embayment = [
  [37.50194, -122.49346],
  [37.50199, -122.49489],
  [37.4999, -122.49625],
  [37.49818, -122.4968],
  [37.49683, -122.49627],
  [37.49647, -122.49558],
  [37.49635, -122.49536],
  [37.49582, -122.49506],
  [37.49303, -122.49348],
  [37.49698, -122.48019],
  [37.49725, -122.47927],
  [37.49928, -122.4756],
  [37.50057, -122.474],
  [37.50225, -122.47534],
  [37.50284, -122.47766],
  [37.5034, -122.4796],
  [37.50366, -122.48122],
  [37.50285, -122.48165],
  [37.50305, -122.48465],
  [37.50367, -122.4856],
  [37.50368, -122.48846],
  [37.50194, -122.49346]
];

L.polygon(PP_SMCA, { color: "red" }).addTo(map);
L.polygon(PP_non_protected_exposed, { color: "blue" }).addTo(map);
L.polygon(PP_non_protected_embayment, { color: "orange" }).addTo(map);
