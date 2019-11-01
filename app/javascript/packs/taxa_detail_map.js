import baseMap from "./base_map.js";
import {
  addSubmitHandler,
  addResetHandler,
  addOptionsHander
} from "../utils/data_viz_filters";
import { pluralize } from "../utils/misc_util";

var taxaSitesLayer;
var showTaxaSites = true;
var samplesData;
const ednaEl = document.querySelector(".js-edna-sites");
const ednaCountEl = document.querySelector(".js-edna-sites-count");

var presenceLayer;
var showPresence = false;
var baseSamplesData;
const totalEdnaEl = document.querySelector(".js-total-edna-sites");
const totalEdnaCountEl = document.querySelector(".js-total-edna-sites-count");

const baseFilters = { substrate: [], primer: [] };
let currentFilters = { substrate: [], primer: [] };
var endpoint = `/api/v1${window.location.pathname}`;
var map = baseMap.createMap();

function initApp(url) {
  baseMap.fetchSamples(url, map, function(data) {
    samplesData = data.samplesData;
    baseSamplesData = data.baseSamplesData;

    if (showPresence) {
      if (presenceLayer) {
        map.removeLayer(presenceLayer);
      }
      presenceLayer = baseMap.renderBasicIndividualMarkers(
        baseSamplesData,
        map
      );
    }

    if (showTaxaSites) {
      if (taxaSitesLayer) {
        map.removeLayer(taxaSitesLayer);
      }
      taxaSitesLayer = baseMap.renderIndividualMarkers(samplesData, map);
    }

    if (ednaCountEl) {
      ednaCountEl.textContent = `${pluralize(
        samplesData.length,
        " site"
      )} with ${ednaCountEl.dataset.taxon}`;
    }

    if (totalEdnaCountEl) {
      totalEdnaCountEl.textContent = `${pluralize(
        baseSamplesData.length,
        " site"
      )} with eDNA results`;
    }
  });
}

baseMap.createOverlayEventListeners(map);
baseMap.createOverlays(map);
baseMap.addMapLayerModal(map);

// =============
// event listeners
// =============

const optionEls = document.querySelectorAll(".filter-option");
var taxaMarkerEls = document.querySelectorAll(".js-taxa-markers");

function setFilters(newFilters) {
  currentFilters = newFilters;
  // console.log("currentFilters", currentFilters);
}

function resetFilters() {
  currentFilters = JSON.parse(JSON.stringify(baseFilters));

  showTaxaSites = true;
  if (ednaEl) {
    ednaEl.checked = true;
  }

  showPresence = false;
  if (totalEdnaEl) {
    totalEdnaEl.checked = false;
  }
  if (presenceLayer) {
    map.removeLayer(presenceLayer);
  }

  // console.log('currentFilters', currentFilters)
}

function fetchFilters() {
  return currentFilters;
}

const toggleMapMarkerHandler = taxaMarkerEls => {
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
            showPresence = true;

            // rerender taxaSitesLayer to ensure asvs markers are on top of presence markers
            if (showTaxaSites) {
              map.removeLayer(taxaSitesLayer);
              taxaSitesLayer = baseMap.renderIndividualMarkers(
                samplesData,
                map
              );
            }
          } else {
            if (presenceLayer) {
              map.removeLayer(presenceLayer);
            }
            showPresence = false;
          }
        } else if (format == "taxa-sites") {
          if (checked) {
            taxaSitesLayer = baseMap.renderIndividualMarkers(samplesData, map);
            showTaxaSites = true;
          } else {
            if (taxaSitesLayer) {
              map.removeLayer(taxaSitesLayer);
            }
            showTaxaSites = false;
          }
        }
      });
    });
  }
};

addOptionsHander(optionEls, fetchFilters, setFilters);
addSubmitHandler(initApp, endpoint, fetchFilters);
addResetHandler(initApp, endpoint, resetFilters);
toggleMapMarkerHandler(taxaMarkerEls);

// =============
// init
// =============

initApp(endpoint);
