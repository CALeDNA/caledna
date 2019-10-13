import baseMap from "./base_map.js";

var asvsLayer;
var presenceLayer;
var samplesData;
var baseSamplesData;
var showAsvs = true;

var apiEndpoint = `/api/v1${window.location.pathname}`;
var map = baseMap.createMap();
baseMap.fetchSamples(apiEndpoint, map, function(data) {
  samplesData = data.samplesData;
  baseSamplesData = data.baseSamplesData;

  const totalEdnaCountEl = document.querySelector(".js-total-edna-sites-count");
  if (totalEdnaCountEl) {
    let str = baseSamplesData.length;
    str += baseSamplesData.length == 1 ? " site " : " sites ";
    str += "with eDNA results";
    totalEdnaCountEl.textContent = str;
  }

  asvsLayer = baseMap.renderIndividualMarkers(samplesData, map);
});

baseMap.createOverlayEventListeners(map);
baseMap.createOverlays(map);
baseMap.addMapLayerModal(map);

var taxaMarkerEls = document.querySelectorAll(".js-taxa-markers");
if (taxaMarkerEls) {
  taxaMarkerEls.forEach(function(el) {
    el.addEventListener("click", function(event) {
      var format = event.target.value;
      var checked = event.target.checked;

      if (format == "presence") {
        if (checked) {
          presenceLayer = baseMap.renderBasicIndividualMarkers(
            baseSamplesData,
            map
          );

          // rerender asvsLayer to ensure asvs markers are on top of presence markers
          if (showAsvs) {
            map.removeLayer(asvsLayer);
            asvsLayer = baseMap.renderIndividualMarkers(samplesData, map);
          }
        } else if (presenceLayer) {
          map.removeLayer(presenceLayer);
        }
      } else if (format == "asvs") {
        if (checked) {
          asvsLayer = baseMap.renderIndividualMarkers(samplesData, map);
          showAsvs = true;
        } else if (asvsLayer) {
          map.removeLayer(asvsLayer);
          showAsvs = false;
        }
      }
    });
  });
}
