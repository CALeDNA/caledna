<template>
  <div>
    <h1>LA River Explorer: BETA</h1>
    <p class="font-md m-b-md">
      The public's interest in the ecology and environment of the LA River is
      one of the main inspirations for this project. One of our goals is raise
      appreciation of the biodiversity of the LA River by creating a website
      where people can learn more about the ecology of the LA River by browsing
      through existing biodiversity and environmental data.
    </p>
    <div class="my-container">
      <div id="controls">
        <h2 class="m-t-zero">Monitoring Locations</h2>
        <AnalyteList
          :list="locations"
          @addSelectedLayer="appendTempSelectedLayers"
        />

        <h2>Taxon Search</h2>
        <button
          class="btn btn-primary"
          @click="setActiveTab('biodiversityTab')"
        >
          Add Taxon
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
                ><span
                  :key="`${newestTaxa}-b`"
                  v-html="gbifDataCount(layer)"
                ></span
              ></label>
            </div>
            <div>
              <span @click="removeTaxonLayer(layer)">
                <i class="far fa-times-circle"></i>
              </span>
            </div>
          </div>
        </section>

        <h2>Enviromental Factors</h2>
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
            tributaries, search for a taxon to find out if there are any
            reported occurrences along the LA River.
          </p>
          <p>
            The biodiversity data consists of Protecting our River eDNA data and
            <a href="https://www.inaturalist.org/">iNaturalist</a>
            research grade photographic observations via
            <a href="https://www.gbif.org/">GBIF</a>.
          </p>

          <div class="form-inline">
            <vue-autosuggest
              v-model="searchKeyword"
              :suggestions="suggestions"
              @input="fetchSuggestions"
              @selected="onSelected"
              :get-suggestion-value="getSuggestionValue"
              :input-props="inputProps"
            >
              <template slot="after-input">
                <button class="btn btn-default" @click="submitSearch">
                  <i class="fas fa-search"></i>
                </button>
              </template>

              <div
                slot-scope="{ suggestion }"
                style="display: flex; align-items: center"
              >
                <img
                  :style="{
                    maxWidth: '25px',
                    maxHeight: '25px',
                    marginRight: '5px',
                  }"
                  :src="kingdomIcon(suggestion.item)"
                />
                <div>
                  {{ taxonName(suggestion.item) }}
                </div>
              </div>
            </vue-autosuggest>
          </div>

          <div
            class="m-t-md"
            v-if="tempSelectedTaxon && tempSelectedTaxon.canonical_name"
          >
            <h2>{{ taxonName(tempSelectedTaxon) }}</h2>
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
          <h2 class="m-t-zero">LA River Environmental Factors</h2>
          <p>
            To learn more about the environment of the LA River and its
            tributaries, select one or more of these enviromental factors.
          </p>
          <p>
            The data comes from the 2018
            <a href="https://www.watershedhealth.org/larwmp"
              >Los Angeles River Watershed Monitoring Program</a
            >.
          </p>
          <div class="data-list">
            <h2>Biotic Factors</h2>
            <div>
              <h3>
                Benthic Macroinvertebrates
                <span @click="showModal('Benthic Macroinvertebrates')">
                  <i class="far fa-question-circle"></i>
                </span>
              </h3>
              <AnalyteList
                :list="benthicMacroinvertebrates"
                @addSelectedLayer="appendTempSelectedLayers"
              />
              <Modal
                v-if="currentModal == 'Benthic Macroinvertebrates'"
                @close="currentModal = null"
              >
                <h3 slot="header">Benthic Macroinvertebrates</h3>
                <div slot="body">
                  TODO: Add info about Benthic Macroinvertebrates
                </div>
              </Modal>
            </div>
            <div>
              <h3>
                Attached Algae
                <span @click="showModal('Attached Algae')">
                  <i class="far fa-question-circle"></i>
                </span>
              </h3>
              <AnalyteList
                :list="attachedAlgae"
                @addSelectedLayer="appendTempSelectedLayers"
              />
              <Modal
                v-if="currentModal == 'Attached Algae'"
                @close="currentModal = null"
              >
                <h3 slot="header">Attached Algae</h3>
                <div slot="body">TODO: Add info about Attached Algae</div>
              </Modal>
            </div>
            <div>
              <h3>
                Riparian Habitat Score
                <span @click="showModal('Riparian Habitat Scores')">
                  <i class="far fa-question-circle"></i>
                </span>
              </h3>
              <AnalyteList
                :list="riparianHabitatScore"
                @addSelectedLayer="appendTempSelectedLayers"
              />
              <Modal
                v-if="currentModal == 'Riparian Habitat Scores'"
                @close="currentModal = null"
              >
                <h3 slot="header">Riparian Habitat Scores</h3>
                <div slot="body">
                  TODO: Add info about Riparian Habitat Scores
                </div>
              </Modal>
            </div>
            <div>
              <h3>
                Algal Biomass
                <span @click="showModal('Algal Biomass')">
                  <i class="far fa-question-circle"></i>
                </span>
              </h3>
              <AnalyteList
                :list="algalBiomass"
                @addSelectedLayer="appendTempSelectedLayers"
              />
              <Modal
                v-if="currentModal == 'Algal Biomass'"
                @close="currentModal = null"
              >
                <h3 slot="header">Algal Biomass</h3>
                <div slot="body">TODO: Add info about Algal Biomass</div>
              </Modal>
            </div>

            <h2>Abiotic Factors</h2>
            <div>
              <h3>
                InSitu Measurements
                <span @click="showModal('InSitu Measurements')">
                  <i class="far fa-question-circle"></i>
                </span>
              </h3>
              <AnalyteList
                :list="inSituMeasurements"
                @addSelectedLayer="appendTempSelectedLayers"
              />
              <Modal
                v-if="currentModal == 'InSitu Measurements'"
                @close="currentModal = null"
              >
                <h3 slot="header">InSitu Measurements</h3>
                <div slot="body">TODO: Add info about InSitu Measurements</div>
              </Modal>
            </div>
            <div>
              <h3>
                General Chemistry
                <span @click="showModal('General Chemistry')">
                  <i class="far fa-question-circle"></i>
                </span>
              </h3>
              <AnalyteList
                :list="generalChemistry"
                @addSelectedLayer="appendTempSelectedLayers"
              />
              <Modal
                v-if="currentModal == 'General Chemistry'"
                @close="currentModal = null"
              >
                <h3 slot="header">General Chemistry</h3>
                <div slot="body">TODO: Add info about General Chemistry</div>
              </Modal>
            </div>
            <div>
              <h3>
                Nutrients
                <span @click="showModal('Nutrients')">
                  <i class="far fa-question-circle"></i>
                </span>
              </h3>
              <AnalyteList
                :list="nutrients"
                @addSelectedLayer="appendTempSelectedLayers"
              />
              <Modal
                v-if="currentModal == 'Nutrients'"
                @close="currentModal = null"
              >
                <h3 slot="header">Nutrients</h3>
                <div slot="body">TODO: Add info about Nutrients</div>
              </Modal>
            </div>

            <div>
              <h3>
                Dissolved Metals
                <span @click="showModal('Dissolved Metals')">
                  <i class="far fa-question-circle"></i>
                </span>
              </h3>
              <AnalyteList
                :list="dissolvedMetals"
                @addSelectedLayer="appendTempSelectedLayers"
              />
              <Modal
                v-if="currentModal == 'Dissolved Metals'"
                @close="currentModal = null"
              >
                <h3 slot="header">Dissolved Metals</h3>
                <div slot="body">TODO: Add info about Dissolved Metals</div>
              </Modal>
            </div>

            <div>
              <h3>
                Physical Habitat Assessments
                <span @click="showModal('Physical Habitat Assessments')">
                  <i class="far fa-question-circle"></i>
                </span>
              </h3>
              <AnalyteList
                :list="physicalHabitatAssessments"
                @addSelectedLayer="appendTempSelectedLayers"
              />
              <Modal
                v-if="currentModal == 'Physical Habitat Assessments'"
                @close="currentModal = null"
              >
                <h3 slot="header">Physical Habitat Assessments</h3>
                <div slot="body">
                  TODO: Add info about Physical Habitat Assessments
                </div>
              </Modal>
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
import { VueAutosuggest } from "vue-autosuggest";

import AnalyteList from "./shared/analyte-list";
import Modal from "./shared/modal";

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
  physicalHabitatAssessments,
  Temperature,
  Oxygen,
  pH,
  Salinity,
  SpecificConductivity,
  PouR,
  LARWMP,
  legends,
} from "../data/dataLayers";
import {
  initMap,
  pourLocationsLayer,
  pourEdnaLayer,
  pourGbifLayer,
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
import { randomColorRange, randomColor } from "../utils/map_colors";
import { formatTaxonName, formatKingdomIcon } from "../utils/taxon_utils";

export default {
  name: "RiverExplorer",
  components: {
    AnalyteList,
    VueAutosuggest,
    Modal,
  },
  data: function () {
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
      physicalHabitatAssessments,
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
      getTaxaRoute: api.taxa_search,
      selectedTaxa: {},
      taxaMapLayers: {},
      tempSelectedTaxon: {},
      newestTaxa: null,
      ednaData: {},
      gbifData: {},
      currentModal: null,
      // search
      searchKeyword: null,
      selectedSuggestion: null,
      suggestions: [{ data: [] }],
      inputProps: {
        id: "autosuggest",
        class: "form-control",
        placeholder:
          "Search for a taxon by Latin or English names (e.g., Canis lupus, wolf)",
      },
    };
  },

  methods: {
    // =============
    // mapTab

    // =============
    getActiveMapLayer: function () {
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
    toggleMapLayer: function (layerName, objectLayer) {
      if (this.dataMapLayers[layerName]) {
        this.map.removeLayer(this.dataMapLayers[layerName]);
        this.dataMapLayers[layerName] = null;
      } else {
        this.dataMapLayers[layerName] = objectLayer;
        this.map.addLayer(this.dataMapLayers[layerName]);
      }
    },
    updateLegend: function () {
      if (this.legend) {
        this.map.removeControl(this.legend);
      }
      let ctx = this;

      this.legend = L.control({ position: "bottomleft" });
      this.legend.onAdd = function (map) {
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
    // search
    // =============
    submitSearch: function () {
      this.fetchSimpleSearch(this.searchKeyword);
      this.suggestions = [{ data: [] }];
    },
    onSelected: function (item) {
      this.tempSelectedTaxon = item && item.item;
      // this.fetchEol(taxon.canonical_name);
    },
    getSuggestionValue: function (suggestion) {
      // the <input/> value when you select a suggestion.
      return suggestion.item.canonical_name;
    },

    // =============
    // taxaTab
    // =============

    submitTaxa: function () {
      if (this.tempSelectedTaxon.canonical_name) {
        this.selectedTaxa[this.tempSelectedTaxon.canonical_name] = true;
        this.fetchOccurences(this.tempSelectedTaxon.canonical_name);
      }
      this.setActiveTab("mapTab");
      this.tempSelectedTaxon = {};
    },
    isTaxaLayerSelected: function (layer) {
      return this.selectedTaxa[layer];
    },
    toggleTaxaLayerVisibility: function (layer, event) {
      var mapObj = this.ednaData[layer]["layer"];
      if (mapObj) {
        Object.values(mapObj._layers).forEach((objLayer) => {
          if (event.target.checked === false) {
            objLayer.bringToBack();
          } else {
            objLayer.bringToFront();
          }
          let value = event.target.checked == true ? 0.7 : 0;
          objLayer.setStyle({ opacity: value, fillOpacity: value });
        });
      }

      var mapObj2 = this.gbifData[layer]["layer"];
      if (mapObj2) {
        Object.values(mapObj2._layers).forEach((objLayer) => {
          if (event.target.checked === false) {
            objLayer.bringToBack();
          } else {
            objLayer.bringToFront();
          }
          let value = event.target.checked == true ? 0.7 : 0;
          objLayer.setStyle({ opacity: value, fillOpacity: value });
        });
      }
      this.selectedTaxa[layer] = event.target.checked;
    },
    removeTaxonLayer: function (layer) {
      delete this.selectedTaxa[layer];
      this.selectedTaxa = { ...this.selectedTaxa };

      if (this.ednaData[layer]) {
        this.map.removeLayer(this.ednaData[layer]["layer"]);
        this.ednaData[layer] = null;
      }

      if (this.gbifData[layer]) {
        this.map.removeLayer(this.gbifData[layer]["layer"]);
        this.gbifData[layer] = null;
      }
    },
    ednaDataCount: function (layer) {
      if (this.ednaData[layer]) {
        if (this.ednaData[layer].count > 0) {
          let marker = `<svg height="30" width="30">
                            <circle cx="15" cy="22" r="7" stroke="#222" stroke-width="2"
                              fill="${this.ednaDataColor(layer)}"/>
                            </svg>`;
          return `<br>${marker}${this.ednaData[layer].count} eDNA sites`;
        } else {
          let blank = '<svg height="30" width="30"></svg>';
          return `<br>${blank}0 eDNA sites`;
        }
      }
    },
    gbifDataCount: function (layer) {
      if (this.gbifData[layer]) {
        if (this.gbifData[layer].count > 0) {
          let marker = `<svg height="30" width="30">
                            <circle cx="15" cy="22" r="7" stroke="#222" stroke-width="2"
                              fill="${this.gbifDataColor(layer)}"/>
                            </svg>`;
          return `<br>${marker}${this.gbifData[layer].count} iNaturalist observations`;
        } else {
          let blank = '<svg height="30" width="30"></svg>';
          return `<br>${blank}0 iNaturalist observations<br>`;
        }
      }
    },
    ednaDataColor: function (layer) {
      if (this.ednaData[layer] && this.ednaData[layer].color) {
        return this.ednaData[layer].color;
      }
    },
    gbifDataColor: function (layer) {
      if (this.gbifData[layer] && this.gbifData[layer].color) {
        return this.gbifData[layer].color;
      }
    },
    // =============
    // dataTab
    // =============
    showModal: function (layer) {
      this.currentModal = layer;
    },
    submitData: function (activeTab) {
      for (const layer in this.tempSelectedData) {
        if (this.tempSelectedData[layer]) {
          this.selectedData[layer] = true;
          this.addDataLayersToMap(layer);
        }
      }
      this.tempSelectedData = {};

      this.setActiveTab(activeTab);
    },
    addDataLayersToMap: function (layer) {
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
    toggleDataMapLayer: function (layerName, objectLayer) {
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
    isDataLayerSelected: function (layer) {
      return this.selectedData[layer];
    },
    toggleDataLayerVisibility: function (layer, event) {
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
    removeDataLayer: function (layer) {
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
    appendTempSelectedLayers: function (layer, checked) {
      if (layer == LARWMP || layer == PouR) {
        this.addDataLayersToMap(layer);
      } else {
        this.tempSelectedData[layer] = checked;
      }
    },
    // =============
    // common
    // =============
    taxonName: function (taxon) {
      return formatTaxonName(taxon);
    },
    kingdomIcon: function (taxon) {
      return formatKingdomIcon(taxon);
    },
    setActiveTab: function (tab) {
      this.activeTab = tab;
    },
    showInfo: function (layer) {
      alert(`TODO: Add info about ${layer}`);
    },
    // =============
    // fetch data
    // =============
    fetchSuggestions: function () {
      let ctx = this;

      if (ctx.searchKeyword.length <= 2) {
        return;
      }
      axios
        .get(`${ctx.getTaxaRoute}?query=${ctx.searchKeyword}`)
        .then((results) => {
          // HACK: Ignore slow queries that don't match the current
          // searchKeyword. Ideally there would be a debounce function or
          // a faster sql query.
          if (results.data.query === ctx.searchKeyword) {
            ctx.suggestions[0].data = results.data.data;
          }
        })
        .catch((e) => console.warn(e));
    },

    fetchSimpleSearch: function (taxon) {
      axios
        .get(`${api.taxa_search}?query=${taxon}&type=simple`)
        .then((results) => {
          this.tempSelectedTaxon = results.data.data[0];
        });
    },

    fetchPourLocations: function () {
      axios
        .get(`${api.placesBasic}?place_type=pour_location`)
        .then((response) => {
          this.pourLocationsLayer = pourLocationsLayer(response.data.places);
        })
        .catch((e) => {
          console.error(e);
        });
    },
    fetchOccurences: function (taxonName, radius) {
      let ctx = this;
      axios
        .get(`${api.pourOccurrences}?taxon=${taxonName}`)
        .then((response) => {
          let reducer = (accumulator, item) => {
            return accumulator + item.count;
          };
          let gbifCount = response.data.gbif.reduce(reducer, 0);
          ctx.gbifData[taxonName] = { count: gbifCount };
          let colors = randomColorRange();
          console.log("colors", colors);
          let gbifLayer = pourGbifLayer(response.data.gbif, colors, taxonName);
          ctx.gbifData[taxonName]["layer"] = gbifLayer;
          ctx.gbifData[taxonName]["color"] = colors[2];
          ctx.map.addLayer(gbifLayer);

          ctx.ednaData[taxonName] = { count: response.data.edna.length };
          let ednaColor = randomColor();
          let ednaLayer = pourEdnaLayer(
            response.data.edna,
            ednaColor,
            taxonName
          );
          ctx.ednaData[taxonName]["layer"] = ednaLayer;
          ctx.ednaData[taxonName]["color"] = ednaColor;
          ctx.map.addLayer(ednaLayer);
          ctx.newestTaxa = `${taxonName}-${new Date().getTime()}`;
        })
        .catch((e) => {
          console.error(e);
        })
        .finally(() => (this.loading = false));
    },
    fetchEol: function (taxonName) {
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
  mounted: function () {
    this.$nextTick(function () {
      this.map = initMap();
      let watershedLayer = createWatershedLayer();
      let riverLayer = createRiverLayer();
      this.map.addLayer(createWatershedLayer());
      this.map.addLayer(createRiverLayer());

      var ctx = this;
      this.map.on("zoomend", function () {
        var zoomlevel = ctx.map.getZoom();
        console.log("zoom", zoomlevel);
      });

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
</script>
