<template>
  <div>
    <h1>LA River Explorer</h1>
    <div class="my-container">
      <div id="controls">
        <h2 class="m-t-zero">Monitoring Locations</h2>
        <AnalyteList
          :list="locations"
          @addSelectedLayer="appendTempSelectedLayers"
        />

        <h2>Biodiversity</h2>
        <button
          class="btn btn-primary"
          @click="setActiveTab('biodiversityTab')"
        >
          Add Species
        </button>
        <section class="data-layers">
          <div
            v-for="layer in Object.keys(selectedTaxa)"
            v-bind:key="layer"
            class="data-layer"
          >
            <div>
              <input
                type="checkbox"
                :id="layer"
                :name="layer"
                :checked="isTaxaLayerSelected(layer)"
                @click="toggleTaxaLayerVisibility(layer, $event)"
              />
              <label :for="layer">
                {{ layer }}
                <span :key="newestTaxa" v-html="ednaDataCount(layer)"></span
              ></label>
            </div>
            <div>
              <span @click="removeTaxonLayer(layer)">
                <i class="far fa-times-circle"></i>
              </span>
            </div>
          </div>
        </section>

        <h2>Enviromental Conditions</h2>
        <button
          class="btn btn-primary"
          @click="setActiveTab('environmentalTab')"
        >
          Add Data
        </button>
        <section class="data-layers">
          <div
            v-for="layer in Object.keys(selectedData)"
            v-bind:key="layer"
            class="data-layer"
          >
            <div>
              <input
                type="checkbox"
                :id="`${layer}_m`"
                :name="`${layer}_m`"
                :checked="isDataLayerSelected(layer)"
                @click="toggleDataLayerVisibility(layer, $event)"
              />
              <label :for="`${layer}_m`">{{ layer }}</label>
            </div>
            <div>
              <span @click="showInfo(layer)">
                <i class="far fa-question-circle"></i>
              </span>
              <span @click="removeDataLayer(layer)">
                <i class="far fa-times-circle"></i>
              </span>
            </div>
          </div>
        </section>
      </div>

      <div id="explorer-content">
        <!-- mapTab -->
        <section v-show="activeTab == 'mapTab'">
          <div id="map"></div>
        </section>

        <section v-if="activeTab == 'biodiversityTab'" class="taxon-tab">
          <h2 class="m-t-zero">LA River Biodiversity</h2>
          <p>
            To learn more about the biodiversity of the LA River and its
            tributaries, search for a species to find out if there are any
            reported occurrences along the LA River.
          </p>
          <autocomplete
            :url="getTaxaRoute"
            param="query"
            anchor="canonical_name"
            label="rank"
            name="autocomplete"
            :classes="{ input: 'form-control', wrapper: 'input-wrapper' }"
            :process="fetchTaxaSuggestions"
            :onSelect="handleTaxaSelect"
          >
          </autocomplete>
          <div class="m-t-md" v-show="tempSelectedTaxon.canonical_name">
            <h2>{{ tempSelectedTaxon.canonical_name }}</h2>
            Rank: {{ tempSelectedTaxon.rank }}
          </div>

          <div class="m-t-md">
            <button
              class="btn btn-primary"
              @click="submitTaxa(tempSelectedTaxon)"
            >
              View on Map
            </button>
            <button class="btn btn-default" @click="setActiveTab('mapTab')">
              Cancel
            </button>
          </div>
        </section>

        <!-- environmentalTab -->
        <section v-if="activeTab == 'environmentalTab'" class="data-tab">
          <h2 class="m-t-zero">LA River Environmental Conditions</h2>
          <p>
            To learn more about the environmental conditions of the LA River and
            its tributaries, select one or more of these enviromental
            conditions.
          </p>
          <div class="data-list">
            <div>
              Benthic Macroinvertebrates
              <AnalyteList
                :list="benthicMacroinvertebrates"
                @addSelectedLayer="appendTempSelectedLayers"
              />
            </div>
            <div>
              Attached Algae
              <AnalyteList
                :list="attachedAlgae"
                @addSelectedLayer="appendTempSelectedLayers"
              />
            </div>
            <div>
              Riparian Habitat Score
              <AnalyteList
                :list="riparianHabitatScore"
                @addSelectedLayer="appendTempSelectedLayers"
              />
            </div>
            <div>
              InSitu Measurements
              <AnalyteList
                :list="inSituMeasurements"
                @addSelectedLayer="appendTempSelectedLayers"
              />
            </div>
            <div>
              General Chemistry
              <AnalyteList
                :list="generalChemistry"
                @addSelectedLayer="appendTempSelectedLayers"
              />
            </div>
            <div>
              Nutrients
              <AnalyteList
                :list="nutrients"
                @addSelectedLayer="appendTempSelectedLayers"
              />
            </div>
            <div>
              Algal Biomass
              <AnalyteList
                :list="algalBiomass"
                @addSelectedLayer="appendTempSelectedLayers"
              />
            </div>
            <div>
              Dissolved Metals
              <AnalyteList
                :list="dissolvedMetals"
                @addSelectedLayer="appendTempSelectedLayers"
              />
            </div>
          </div>
          <div class="m-t-md">
            <button class="btn btn-primary" @click="submitData('mapTab')">
              View on Map
            </button>
            <button class="btn btn-default" @click="setActiveTab('mapTab')">
              Cancel
            </button>
          </div>
        </section>
      </div>
    </div>
  </div>
</template>

<script>
  import axios from "axios";
  import Autocomplete from "vue2-autocomplete-js";
  require("vue2-autocomplete-js/dist/style/vue2-autocomplete.css");

  import {
    biodiversity,
    locations,
    benthicMacroinvertebrates,
    attachedAlgae,
    riparianHabitatScore,
    inSituMeasurements,
    generalChemistry,
    nutrients,
    algalBiomass,
    dissolvedMetals,
    Temperature,
    Oxygen,
    pH,
    Salinity,
    SpecificConductivity,
    PouR,
    LARWMP,
    legends,
  } from "./shared/constants/dataLayers";
  import AnalyteList from "./shared/components/analyte-list";

  import {
    initMap,
    pourLocationsLayer,
    pourEdnaLayer,
    createLARWMP2018,
    createRiverLayer,
    createImageLayer,
    createWatershedLayer,
    sites_2018_temperature,
    sites_2018_oxygen,
    sites_2018_ph,
    sites_2018_salinity,
    sites_2018_conductivity,
  } from "../packs/river_explorer_map";
  import base_map from "../packs/base_map";
  import api from "../utils/api_routes";

  export default {
    name: "RiverExplorer",
    components: {
      AnalyteList,
      Autocomplete,
    },
    data: function() {
      return {
        // constants
        legends: { ...legends },
        biodiversity,
        locations,
        benthicMacroinvertebrates,
        attachedAlgae,
        riparianHabitatScore,
        inSituMeasurements,
        generalChemistry,
        nutrients,
        algalBiomass,
        dissolvedMetals,
        // misc
        activeTab: "mapTab",
        map: null,
        loading: false,
        // data
        selectedData: {},
        dataMapLayers: {},
        tempSelectedData: {},
        dataLayerHistory: [],
        activeMapLayer: null,
        pourLocationsLayer: null,
        // taxa
        getTaxaRoute: api.routes.taxa,
        selectedTaxa: {},
        taxaMapLayers: {},
        tempSelectedTaxon: {},
        newestTaxa: null,
        ednaData: {},
        gbifData: {},
      };
    },
    methods: {
      // =============
      // autosuggest
      // =============
      fetchTaxaSuggestions: function(json) {
        return json.data.map((record) => record.attributes);
      },
      handleTaxaSelect: function(taxon) {
        this.tempSelectedTaxon = taxon;
        // this.fetchEol(taxon.canonical_name);
      },
      // =============
      // mapTab
      // =============
      getActiveMapLayer: function() {
        let history = {};
        this.activeMapLayer = null;
        for (let i = this.dataLayerHistory.length - 1; i >= 0; --i) {
          let item = this.dataLayerHistory[i];
          let layer = Object.keys(item)[0];
          let value = Object.values(item)[0];
          if (value && this.selectedData[layer]) {
            this.activeMapLayer = layer;
            break;
          }
        }
      },
      toggleMapLayer: function(layerName, objectLayer) {
        if (this.dataMapLayers[layerName]) {
          this.map.removeLayer(this.dataMapLayers[layerName]);
          this.dataMapLayers[layerName] = null;
        } else {
          this.dataMapLayers[layerName] = objectLayer;
          this.map.addLayer(this.dataMapLayers[layerName]);
        }
      },
      updateLegend: function() {
        if (this.legend) {
          this.map.removeControl(this.legend);
        }
        let ctx = this;

        this.legend = L.control({ position: "bottomleft" });
        this.legend.onAdd = function(map) {
          var div = L.DomUtil.create("div", "info legend");
          if (ctx.activeMapLayer) {
            div.innerHTML = `<img class="legend-img" src="${
              ctx.legends[ctx.activeMapLayer]
            }">`;
          }
          return div;
        };
        this.legend.addTo(this.map);
      },

      // =============
      // taxaTab
      // =============
      fetchTaxaSuggestions: function(json) {
        return json.data.map((record) => record.attributes);
      },
      handleTaxaSelect: function(taxon) {
        this.tempSelectedTaxon = taxon;
        // this.fetchEol(taxon.canonical_name);
      },
      submitTaxa: function() {
        if (this.tempSelectedTaxon.canonical_name) {
          this.selectedTaxa[this.tempSelectedTaxon.canonical_name] = true;
          this.fetchOccurences(this.tempSelectedTaxon.canonical_name);
        }
        this.setActiveTab("mapTab");
        this.tempSelectedTaxon = {};
      },
      isTaxaLayerSelected: function(layer) {
        return this.selectedTaxa[layer];
      },
      toggleTaxaLayerVisibility: function(layer, event) {
        var mapObj = this.ednaData[layer]["layer"];
        if (mapObj) {
          Object.values(mapObj._layers).forEach((objLayer) => {
            if (event.target.checked === false) {
              objLayer.bringToBack();
            } else {
              objLayer.bringToFront();
            }
            let value = objLayer.options.opacity === 0 ? 0.7 : 0;
            objLayer.setStyle({ opacity: value, fillOpacity: value });
          });
        }
        this.selectedTaxa[layer] = event.target.checked;
      },
      removeTaxonLayer: function(layer) {
        delete this.selectedTaxa[layer];
        this.selectedTaxa = { ...this.selectedTaxa };

        if (this.ednaData[layer]) {
          this.map.removeLayer(this.ednaData[layer]["layer"]);
          this.ednaData[layer] = null;
        }
      },
      ednaDataCount: function(layer) {
        if (this.ednaData[layer]) {
          if (this.ednaData[layer].count > 0) {
            let marker = `<svg height="30" width="30">
                          <circle cx="15" cy="22" r="7" stroke="#222" stroke-width="2"
                            fill="${this.ednaDataColor(layer)}"/>
                          </svg>`;
            return ` (${marker}${this.ednaData[layer].count} eDNA sites)`;
          } else {
            return ` (${this.ednaData[layer].count} eDNA sites)`;
          }
        }
      },
      ednaDataColor: function(layer) {
        if (this.ednaData[layer] && this.ednaData[layer].color) {
          return this.ednaData[layer].color;
        }
      },
      // =============
      // dataTab
      // =============
      submitData: function(activeTab) {
        for (const layer in this.tempSelectedData) {
          if (this.tempSelectedData[layer]) {
            this.selectedData[layer] = true;
            this.addDataLayersToMap(layer);
          }
        }
        this.tempSelectedData = {};

        this.setActiveTab(activeTab);
      },
      addDataLayersToMap: function(layer) {
        if (layer == LARWMP) {
          this.toggleDataMapLayer(layer, createLARWMP2018());
        } else if (layer == PouR) {
          this.toggleDataMapLayer(layer, this.pourLocationsLayer);
        } else if (layer == Temperature) {
          this.toggleDataMapLayer(layer, sites_2018_temperature);
        } else if (layer == Oxygen) {
          this.toggleDataMapLayer(layer, sites_2018_oxygen);
        } else if (layer == pH) {
          this.toggleDataMapLayer(layer, sites_2018_ph);
        } else if (layer == Salinity) {
          this.toggleDataMapLayer(layer, sites_2018_salinity);
        } else if (layer == SpecificConductivity) {
          this.toggleDataMapLayer(layer, sites_2018_conductivity);
        }
      },
      toggleDataMapLayer: function(layerName, objectLayer) {
        if (this.dataMapLayers[layerName]) {
          this.map.removeLayer(this.dataMapLayers[layerName]);
          this.dataMapLayers[layerName] = null;
          this.dataLayerHistory.push({ [layerName]: false });
        } else if (objectLayer) {
          this.dataMapLayers[layerName] = objectLayer;
          this.map.addLayer(this.dataMapLayers[layerName]);
          this.dataLayerHistory.push({ [layerName]: true });
        }
        this.getActiveMapLayer();
        this.updateLegend();
      },
      isDataLayerSelected: function(layer) {
        return this.selectedData[layer];
      },
      toggleDataLayerVisibility: function(layer, event) {
        var mapObj = this.dataMapLayers[layer];
        if (mapObj) {
          // https://stackoverflow.com/a/41780929
          Object.values(mapObj._layers).forEach((objLayer) => {
            // https://stackoverflow.com/a/12862922
            if (event.target.checked === false) {
              objLayer.bringToBack();
            } else {
              objLayer.bringToFront();
            }
            toggleFeatureOpacity(layer, objLayer);
          });
        }
        this.selectedData[layer] = event.target.checked;
        this.dataLayerHistory.push({ [layer]: event.target.checked });
        this.getActiveMapLayer();
        this.updateLegend();
      },
      removeDataLayer: function(layer) {
        delete this.selectedData[layer];
        this.selectedData = { ...this.selectedData };
        this.toggleDataMapLayer(layer);
        this.dataLayerHistory.push({ [layer]: false });
        this.getActiveMapLayer();
        this.updateLegend();
      },
      // =============
      // analyte-list
      // =============
      appendTempSelectedLayers: function(layer, checked) {
        if (layer == LARWMP || layer == PouR) {
          this.addDataLayersToMap(layer);
        } else {
          this.tempSelectedData[layer] = checked;
        }
      },
      // =============
      // common
      // =============
      setActiveTab: function(tab) {
        this.activeTab = tab;
      },
      showInfo: function(layer) {
        alert(`Info about ${layer}`);
      },
      // =============
      // fetch data
      // =============
      fetchPourLocations: function() {
        axios
          .get("/api/v1/places_basic?place_type=pour_location")
          .then((response) => {
            this.pourLocationsLayer = pourLocationsLayer(response.data.places);
          })
          .catch((e) => {
            console.error(e);
          });
      },
      fetchOccurences: function(taxonName, radius) {
        let ctx = this;
        axios
          .get(`/api/v1/occurrences?taxon=${taxonName}&radius=${radius}`)
          .then((response) => {
            // let reducer = (accumulator, item) => {
            //   return accumulator + item.count;
            // };
            // let gbifCount = response.data.gbif.reduce(reducer, 0);
            // ctx.gbifData[taxonName] = { count: gbifCount };
            // let gbifLayer = base_map.createMarkerLayer(
            //   response.data.gbif,
            //   base_map.createCircleMarker
            // );
            // ctx.gbifData[taxonName]["layer"] = gbifLayer;
            // ctx.map.addLayer(gbifLayer);

            ctx.ednaData[taxonName] = { count: response.data.edna.length };

            let color = randomHsl();
            let ednaLayer = pourEdnaLayer(response.data.edna, color, taxonName);
            ctx.ednaData[taxonName]["layer"] = ednaLayer;
            ctx.ednaData[taxonName]["color"] = color;
            ctx.map.addLayer(ednaLayer);
            ctx.newestTaxa = taxonName;
          })
          .catch((e) => {
            console.error(e);
          })
          .finally(() => (this.loading = false));
      },
      fetchEol: function(taxonName) {
        axios
          .get(`https://eol.org/api/search/1.0.json?q=${taxonName}`)
          .then((results) => {
            let eolTaxon = results.data.results[0];
            if (eolTaxon) {
              return eolTaxon.id;
            }
          })
          .then((eolPageId) => {
            if (eolPageId) {
              return axios.get(
                `https://eol.org/api/pages/1.0/${eolPageId}.json?details=true&images_per_page=1`
              );
            }
          })
          .then((results) => {})
          .catch((e) => {
            console.error(e);
          });
      },
    },
    mounted: function() {
      this.$nextTick(function() {
        this.map = initMap();
        this.map.addLayer(createWatershedLayer());
        this.map.addLayer(createRiverLayer());

        this.fetchPourLocations();
      });
    },
  };

  function toggleFeatureOpacity(layer, objLayer) {
    if (!objLayer.feature.properties[layer]) {
      return;
    }

    let value =
      objLayer.options.opacity == 0 ? objLayer.defaultOptions.opacity : 0;
    objLayer.setStyle({ opacity: value, fillOpacity: value });
  }

  function randomHsl() {
    return `hsla(${Math.floor(Math.random() * 360)}, 90%, 50%, 1)`;
  }
</script>
