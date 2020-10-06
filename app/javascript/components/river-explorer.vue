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
            <div class="data-header">
              <input
                type="checkbox"
                :id="layer"
                :name="layer"
                :checked="isTaxaLayerSelected(layer)"
                @click="toggleTaxaLayerVisibility(layer, $event)"
              />
              <label :for="layer"> {{ layer }} </label>
              <span @click="toggleTaxonBody(layer)">
                <svg height="13" width="16" v-if="showTaxonBody(layer)">
                  <path
                    d="M 1 2 l 7 8 l 7 -8 l -16 0"
                    stroke="#333"
                    stroke-width="1"
                    fill="none"
                  />
                </svg>
                <svg height="13" width="16" v-else>
                  <path
                    d="M 1 12 l 7 -8 l 7 8 l -16 0"
                    stroke="#333"
                    stroke-width="1"
                    fill="none"
                  />
                </svg>
              </span>
            </div>
            <div class="data-body" v-show="showTaxonBody(layer)">
              <div v-html="ednaDataCount(layer)"></div>
              <div v-html="gbifDataCount(layer)"></div>
              <div class="data-legend" v-html="taxaLegend(layer)"></div>
              <div class="data-footer">
                <span @click="removeTaxonLayer(layer)">
                  <i class="far fa-times-circle"></i> Remove
                </span>
              </div>
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
            <div class="data-header">
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
        <section v-show="activeTab === 'mapTab'">
          <div id="map"></div>
        </section>

        <section v-if="activeTab === 'biodiversityTab'" class="taxon-tab">
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
        <section v-if="activeTab === 'environmentalTab'" class="data-tab">
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
                v-if="currentModal === 'Benthic Macroinvertebrates'"
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
                v-if="currentModal === 'Attached Algae'"
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
                v-if="currentModal === 'Riparian Habitat Scores'"
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
                v-if="currentModal === 'Algal Biomass'"
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
                v-if="currentModal === 'InSitu Measurements'"
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
                v-if="currentModal === 'General Chemistry'"
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
                v-if="currentModal === 'Nutrients'"
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
                v-if="currentModal === 'Dissolved Metals'"
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
                v-if="currentModal === 'Physical Habitat Assessments'"
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
  PouR,
  LARWMP,
} from "../data/dataLayers";
import {
  initMap,
  pourLocationsLayer,
  taxonEdnaLayer,
  taxonGbifLayer,
  LARWMPLocationsLayer,
  createRiverLayer,
  createWatershedLayer,
  createTaxonClassifications,
  createAnalyteLayer,
  createAnalyteClassifications,
  createMapLegend,
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
    // side menu
    // =============
    toggleTaxonBody: function (layer) {
      this.gbifData[layer]["showTaxonBody"] = !this.gbifData[layer][
        "showTaxonBody"
      ];
    },

    showTaxonBody: function (layer) {
      return this.gbifData[layer] && this.gbifData[layer].showTaxonBody;
    },

    // =============
    // mapTab
    // =============
    getActiveMapLayer: function () {
      this.activeMapLayer = null;
      // iterate backwards through this.dataLayerHistory to find the newest
      // layer that is selected
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
      let value = event.target.checked ? 0.9 : 0;

      var ednaLayer = this.ednaData[layer]["layer"];
      if (ednaLayer) {
        if (event.target.checked) {
          ednaLayer.bringToFront();
        } else {
          ednaLayer.bringToBack();
        }
        ednaLayer.setStyle({ opacity: value, fillOpacity: value });
      }
      var gbifLayer = this.gbifData[layer]["layer"];
      if (gbifLayer) {
        if (event.target.checked) {
          gbifLayer.bringToFront();
        } else {
          gbifLayer.bringToBack();
        }
        gbifLayer.setStyle({ opacity: value, fillOpacity: value });
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
          return `${marker}${this.ednaData[layer].count} eDNA sites`;
        } else {
          let blank = '<svg height="30" width="30"></svg>';
          return `${blank}0 eDNA sites`;
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
          return `${marker}${this.gbifData[layer].count} iNaturalist observations`;
        } else {
          let blank = '<svg height="30" width="30"></svg>';
          return `${blank}0 iNaturalist observations`;
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
    createDataLegend: function (classifications, colors) {
      if (classifications.length === 0) {
        return;
      }

      let html = "Observations Count";
      classifications.forEach((classification, index) => {
        html += `
        <div>
          <svg width="20" height="20">
            <rect width="18" height="18"
              style="fill:${colors[index]};stroke-width:1;stroke:${colors[3]}" />
          </svg>
          <span>${classification.begin} - ${classification.end}</span>
        </div>
        `;
      });
      return html;
    },
    taxaLegend: function (layer) {
      if (this.gbifData[layer] && this.gbifData[layer].legend) {
        return this.gbifData[layer].legend;
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
          this.processDataLayerForMap(layer);
        }
      }
      this.tempSelectedData = {};

      this.setActiveTab(activeTab);
    },
    removeDataLayerForMap: function (layerName) {
      this.map.removeLayer(this.dataMapLayers[layerName]["layer"]);
      this.dataMapLayers[layerName] = null;
      this.dataLayerHistory.push({ [layerName]: false });
    },
    addDataLayerForMap: function (layerName) {
      let mapLayer;
      let legend;

      if (layerName === LARWMP) {
        mapLayer = LARWMPLocationsLayer();
      } else if (layerName === PouR) {
        mapLayer = this.pourLocationsLayer;
      } else {
        let colors = randomColorRange();
        let classifications = createAnalyteClassifications(layerName);
        mapLayer = createAnalyteLayer(layerName, classifications, colors);
        legend = createMapLegend(classifications, colors, layerName);
      }

      this.dataMapLayers[layerName] = { layer: mapLayer, legend: legend };
      this.dataLayerHistory.push({ [layerName]: true });

      // We want to add every data layer to the map
      this.map.addLayer(this.dataMapLayers[layerName]["layer"]);
    },

    updateLegend: function () {
      // only add the
      if (this.legend) {
        this.map.removeControl(this.legend);
      }

      // We only want to add the legend for the active data layer to the map
      if (this.dataMapLayers[this.activeMapLayer]) {
        let legend = this.dataMapLayers[this.activeMapLayer]["legend"];
        if (legend) {
          this.legend = legend;
          this.legend.addTo(this.map);
        }
      }
    },

    // when people click "add to map" for LARWMP tab or
    // when people click PouR or LARWMP sites
    processDataLayerForMap: function (layerName) {
      if (this.dataMapLayers[layerName]) {
        this.removeDataLayerForMap(layerName);
      } else {
        this.addDataLayerForMap(layerName);
      }

      if (layerName === LARWMP || layerName === PouR) {
      } else {
        this.getActiveMapLayer();
        this.updateLegend();
      }
    },

    isDataLayerSelected: function (layer) {
      return !!this.selectedData[layer];
    },
    toggleDataLayerVisibility: function (layer, event) {
      let value = event.target.checked ? 0.9 : 0;

      var dataLayer = this.dataMapLayers[layer]["layer"];
      if (dataLayer) {
        if (event.target.checked) {
          dataLayer.bringToFront();
        } else {
          dataLayer.bringToBack();
        }
        dataLayer.setStyle({ opacity: value, fillOpacity: value });
      }

      this.selectedData[layer] = event.target.checked;
      this.dataLayerHistory.push({ [layer]: event.target.checked });
      this.getActiveMapLayer();
      this.updateLegend();
    },
    removeDataLayer: function (layer) {
      delete this.selectedData[layer];
      this.selectedData = { ...this.selectedData };
      this.removeDataLayerForMap(layer);
      this.dataLayerHistory.push({ [layer]: false });
      this.getActiveMapLayer();
      this.updateLegend();
    },
    // =============
    // analyte-list
    // =============
    appendTempSelectedLayers: function (layer, checked) {
      if (layer === LARWMP || layer === PouR) {
        this.processDataLayerForMap(layer);
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
          let colors = randomColorRange();
          let classifications = createTaxonClassifications(response.data.gbif);
          let gbifLayer = taxonGbifLayer(
            response.data.gbif,
            classifications,
            colors,
            taxonName
          );
          let legend = ctx.createDataLegend(classifications, colors);
          ctx.gbifData = {
            ...ctx.gbifData,
            [taxonName]: {
              count: gbifCount,
              legend: legend,
              layer: gbifLayer,
              color: colors[2],
              showTaxonBody: true,
            },
          };

          ctx.map.addLayer(gbifLayer);

          let ednaColor = randomColor();
          let ednaLayer = taxonEdnaLayer(
            response.data.edna,
            ednaColor,
            taxonName
          );

          ctx.ednaData = {
            ...ctx.ednaData,
            [taxonName]: {
              count: response.data.edna.length,
              layer: ednaLayer,
              color: ednaColor,
            },
          };

          ctx.map.addLayer(ednaLayer);
        })
        .catch((e) => {
          console.error(e);
        })
        .finally(() => (this.loading = false));
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
</script>
