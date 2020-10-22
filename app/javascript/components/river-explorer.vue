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
              <div class="input-group">
                <input
                  type="checkbox"
                  :id="layer"
                  :name="layer"
                  :checked="isTaxaLayerSelected(layer)"
                  @click="toggleTaxaLayerVisibility(layer, $event)"
                />
                <label :for="layer"> {{ displayTaxonName(layer) }} </label>
              </div>
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
            </div>
            <div class="data-footer" v-show="showTaxonBody(layer)">
              <span v-html="taxonLink(layer)"></span>
              <span @click="removeTaxonLayer(layer)">
                <i class="far fa-times-circle"></i> Remove
              </span>
            </div>
          </div>
        </section>

        <h2>Environmental Factors</h2>
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
            <div class="data-footer">
              <span @click="showModal(layer)">
                <i class="far fa-question-circle"></i> Info
              </span>
              <span @click="removeDataLayer(layer)">
                <i class="far fa-times-circle"></i> Remove
              </span>
            </div>

            <Modal v-if="layer == currentModal" @close="currentModal = null">
              <h3 slot="header">{{ layer }}</h3>
              <div slot="body" v-html="modalBody(layer)"></div>
            </Modal>
          </div>
        </section>
      </div>

      <div id="explorer-content">
        <!-- mapTab -->
        <section v-show="activeTab === 'mapTab'">
          <div id="map" class="map-container">
            <spinner v-if="loading" />
          </div>
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
                {{ BenthicMacroinvertebrates }}
                <span @click="showModal(BenthicMacroinvertebrates)">
                  <i class="far fa-question-circle"></i>
                </span>
              </h3>
              <AnalyteList
                :list="benthicMacroinvertebratesAnalytes"
                @addSelectedLayer="appendTempSelectedLayers"
              />
              <Modal
                v-if="currentModal === BenthicMacroinvertebrates"
                @close="currentModal = null"
              >
                <h3 slot="header">{{ BenthicMacroinvertebrates }}</h3>
                <div
                  slot="body"
                  v-html="modalBody(BenthicMacroinvertebrates)"
                ></div>
              </Modal>
            </div>
            <div>
              <h3>
                {{ AttachedAlgae }}
                <span @click="showModal(AttachedAlgae)">
                  <i class="far fa-question-circle"></i>
                </span>
              </h3>
              <AnalyteList
                :list="attachedAlgaeAnalytes"
                @addSelectedLayer="appendTempSelectedLayers"
              />
              <Modal
                v-if="currentModal === AttachedAlgae"
                @close="currentModal = null"
              >
                <h3 slot="header">{{ AttachedAlgae }}</h3>
                <div slot="body" v-html="modalBody(AttachedAlgae)"></div>
              </Modal>
            </div>
            <div>
              <h3>
                {{ RiparianHabitatScore }}
                <span @click="showModal(RiparianHabitatScore)">
                  <i class="far fa-question-circle"></i>
                </span>
              </h3>
              <AnalyteList
                :list="riparianHabitatScoreAnalytes"
                @addSelectedLayer="appendTempSelectedLayers"
              />
              <Modal
                v-if="currentModal === RiparianHabitatScore"
                @close="currentModal = null"
              >
                <h3 slot="header">{{ RiparianHabitatScore }}</h3>
                <div slot="body" v-html="modalBody(RiparianHabitatScore)"></div>
              </Modal>
            </div>
            <div>
              <h3>
                {{ AlgalBiomass }}
                <span @click="showModal(AlgalBiomass)">
                  <i class="far fa-question-circle"></i>
                </span>
              </h3>
              <AnalyteList
                :list="algalBiomassAnalytes"
                @addSelectedLayer="appendTempSelectedLayers"
              />
              <Modal
                v-if="currentModal === AlgalBiomass"
                @close="currentModal = null"
              >
                <h3 slot="header">{{ AlgalBiomass }}</h3>
                <div slot="body" v-html="modalBody(AlgalBiomass)"></div>
              </Modal>
            </div>

            <h2>Abiotic Factors</h2>
            <div>
              <h3>
                {{ InSituMeasurements }}
                <span @click="showModal(InSituMeasurements)">
                  <i class="far fa-question-circle"></i>
                </span>
              </h3>
              <AnalyteList
                :list="inSituMeasurementsAnalytes"
                @addSelectedLayer="appendTempSelectedLayers"
              />
              <Modal
                v-if="currentModal === InSituMeasurements"
                @close="currentModal = null"
              >
                <h3 slot="header">{{ InSituMeasurements }}</h3>
                <div slot="body" v-html="modalBody(InSituMeasurements)"></div>
              </Modal>
            </div>
            <div>
              <h3>
                {{ GeneralChemistry }}
                <span @click="showModal(GeneralChemistry)">
                  <i class="far fa-question-circle"></i>
                </span>
              </h3>
              <AnalyteList
                :list="generalChemistryAnalytes"
                @addSelectedLayer="appendTempSelectedLayers"
              />
              <Modal
                v-if="currentModal === GeneralChemistry"
                @close="currentModal = null"
              >
                <h3 slot="header">{{ GeneralChemistry }}</h3>
                <div slot="body" v-html="modalBody(GeneralChemistry)"></div>
              </Modal>
            </div>
            <div>
              <h3>
                {{ Nutrients }}
                <span @click="showModal(Nutrients)">
                  <i class="far fa-question-circle"></i>
                </span>
              </h3>
              <AnalyteList
                :list="nutrientsAnalytes"
                @addSelectedLayer="appendTempSelectedLayers"
              />
              <Modal
                v-if="currentModal === Nutrients"
                @close="currentModal = null"
              >
                <h3 slot="header">{{ Nutrients }}</h3>
                <div slot="body" v-html="modalBody(Nutrients)"></div>
              </Modal>
            </div>

            <div>
              <h3>
                {{ DissolvedMetals }}
                <span @click="showModal(DissolvedMetals)">
                  <i class="far fa-question-circle"></i>
                </span>
              </h3>
              <AnalyteList
                :list="dissolvedMetalsAnalytes"
                @addSelectedLayer="appendTempSelectedLayers"
              />
              <Modal
                v-if="currentModal === DissolvedMetals"
                @close="currentModal = null"
              >
                <h3 slot="header">{{ DissolvedMetals }}</h3>
                <div slot="body" v-html="modalBody(DissolvedMetals)"></div>
              </Modal>
            </div>

            <div>
              <h3>
                {{ PhysicalHabitatAssessments }}
                <span @click="showModal(PhysicalHabitatAssessments)">
                  <i class="far fa-question-circle"></i>
                </span>
              </h3>
              <AnalyteList
                :list="physicalHabitatAssessmentsAnalytes"
                @addSelectedLayer="appendTempSelectedLayers"
              />
              <Modal
                v-if="currentModal === PhysicalHabitatAssessments"
                @close="currentModal = null"
              >
                <h3 slot="header">{{ PhysicalHabitatAssessments }}</h3>
                <div
                  slot="body"
                  v-html="modalBody(PhysicalHabitatAssessments)"
                ></div>
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

        <RiverInat v-show="activeTab === 'mapTab'" />
      </div>
    </div>
  </div>
</template>

<script>
import axios from "axios";
import { VueAutosuggest } from "vue-autosuggest";

import AnalyteList from "./shared/analyte-list";
import Modal from "./shared/modal";
import RiverInat from "./river-inat";
import Spinner from "./shared/spinner";

import {
  biodiversity,
  locations,
  benthicMacroinvertebratesAnalytes,
  attachedAlgaeAnalytes,
  riparianHabitatScoreAnalytes,
  inSituMeasurementsAnalytes,
  generalChemistryAnalytes,
  nutrientsAnalytes,
  algalBiomassAnalytes,
  dissolvedMetalsAnalytes,
  physicalHabitatAssessmentsAnalytes,
  allAnalytes,
  PouR,
  LARWMP,
  BenthicMacroinvertebrates,
  AttachedAlgae,
  RiparianHabitatScore,
  AlgalBiomass,
  InSituMeasurements,
  GeneralChemistry,
  Nutrients,
  DissolvedMetals,
  PhysicalHabitatAssessments,
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
import {
  targetColorRange,
  randomColor,
  targetColor,
} from "../utils/map_colors";
import { formatTaxonName, formatKingdomIcon } from "../utils/taxon_utils";

export default {
  name: "RiverExplorer",
  components: {
    AnalyteList,
    VueAutosuggest,
    Modal,
    RiverInat,
    Spinner,
  },
  data: function () {
    return {
      // constants
      biodiversity,
      locations,
      benthicMacroinvertebratesAnalytes,
      attachedAlgaeAnalytes,
      riparianHabitatScoreAnalytes,
      inSituMeasurementsAnalytes,
      generalChemistryAnalytes,
      nutrientsAnalytes,
      algalBiomassAnalytes,
      dissolvedMetalsAnalytes,
      physicalHabitatAssessmentsAnalytes,
      BenthicMacroinvertebrates,
      AttachedAlgae,
      RiparianHabitatScore,
      AlgalBiomass,
      InSituMeasurements,
      GeneralChemistry,
      Nutrients,
      DissolvedMetals,
      PhysicalHabitatAssessments,
      // misc
      activeTab: "mapTab",
      map: null,
      loading: false,
      riverLayer: null,
      watershedLayer: null,
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
      // modal
      currentModal: null,
    };
  },

  methods: {
    // =============
    // modal menu
    // =============
    modalBody: function (layer) {
      if (allAnalytes[layer]) {
        return allAnalytes[layer];
      } else {
        return `TODO: Add info about ${layer}`;
      }
    },
    showModal: function (layer) {
      this.currentModal = layer;
    },
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
      this.tempSelectedTaxon = {
        canonical_name: this.searchKeyword,
        rank: null,
      };
      this.suggestions = [{ data: [] }];
    },
    onSelected: function (item) {
      this.tempSelectedTaxon = item && item.item;
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
        this.selectedTaxa = {
          ...this.selectedTaxa,
          [this.tempSelectedTaxon.canonical_name]: true,
        };
        this.fetchOccurences(this.tempSelectedTaxon.canonical_name);
      }
      this.setActiveTab("mapTab");
    },
    isTaxaLayerSelected: function (layer) {
      return this.selectedTaxa[layer];
    },
    toggleTaxaLayerVisibility: function (layer, event) {
      let value = event.target.checked ? 0.9 : 0;

      var gbifLayer = this.gbifData[layer]["layer"];
      if (gbifLayer) {
        if (event.target.checked) {
          gbifLayer.bringToFront();
        } else {
          gbifLayer.bringToBack();
        }
        gbifLayer.setStyle({ opacity: value, fillOpacity: value });
      }
      var ednaLayer = this.ednaData[layer]["layer"];
      if (ednaLayer) {
        if (event.target.checked) {
          ednaLayer.bringToFront();
        } else {
          ednaLayer.bringToBack();
        }
        ednaLayer.setStyle({ opacity: value, fillOpacity: value });
      }

      this.riverLayer.bringToFront();
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
      let data = this.ednaData[layer];
      let legend = "";
      if (data) {
        legend += `<b>${data.count} eDNA sites</b>`;
        legend += "<ul class='menu-legend'>";

        data.legend.forEach((group) => {
          let marker = `<svg height="20" width="25">
                        <circle cx="10" cy="10" r="7" stroke="#222"
                        stroke-width="1" fill="${group.color}"/>
                        </svg>`;
          legend += `<li>${marker}${group.label}, ${group.count} sites</li>`;
        });
      } else {
        legend = "<li>0 eDNA sites</li>";
      }
      legend += "</ul>";
      return legend;
    },
    gbifDataCount: function (layer) {
      if (this.gbifData[layer]) {
        return `<b>${this.gbifData[layer].count} iNaturalist observations</b>`;
      }
    },
    createDataLegend: function (classifications, colors) {
      if (classifications.length === 0) {
        return;
      }

      let legend = "<ul class='menu-legend'>";
      classifications.forEach((classification, index) => {
        legend += `
        <li>
          <svg width="25" height="22">
            <polygon points="18.75,9.4 14,17.5 4.7,17.5 0,9.4 4.7,1.3 14,1.3"
              style="fill:${colors[index]};stroke-width:1;stroke:${colors[3]}" />
          </svg>
          <span>${classification.begin} - ${classification.end} observations</span>
        </li>
        `;
      });
      return legend;
    },
    taxaLegend: function (layer) {
      if (this.gbifData[layer] && this.gbifData[layer].legend) {
        return this.gbifData[layer].legend;
      }
    },
    // =============
    // dataTab
    // =============

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
        let layers = Object.values(this.dataMapLayers).filter((i) => i);
        let colors = targetColorRange(layers.length);
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
      this.riverLayer.bringToFront();
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
      this.riverLayer.bringToFront();
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
    displayTaxonName: function (layer) {
      // TODO: searchTaxon is a mix of both NCBI and GBIF taxonomy.
      // taxon is just NCBI taxonomy. This means the common names are different.
      // Need to add GBIF commom names to NCBI taxonomy.
      if (
        this.ednaData[layer] &&
        Object.keys(this.ednaData[layer].searchTaxon).length > 0
      ) {
        return this.taxonName(this.ednaData[layer].searchTaxon);
      } else if (this.ednaData[layer] && this.ednaData[layer].taxon) {
        return this.taxonName(this.ednaData[layer].taxon);
      } else {
        return layer;
      }
    },
    taxonLink: function (layer) {
      if (this.ednaData[layer] && this.ednaData[layer].taxon) {
        return `
        <svg height="15" viewBox="0 0 426.667 426.667" style="vertical-align: -.125em;">
          <g>
          	<rect x="192" y="192" width="42.667" height="128"/>
          	<path d="M213.333,0C95.467,0,0,95.467,0,213.333s95.467,213.333,213.333,213.333S426.667,331.2,426.667,213.333
          		S331.2,0,213.333,0z M213.333,384c-94.08,0-170.667-76.587-170.667-170.667S119.253,42.667,213.333,42.667
          		S384,119.253,384,213.333S307.413,384,213.333,384z"/>
          	<rect x="192" y="106.667" width="42.667" height="42.667"/>
          </g>
        </svg>
        <a href="/taxa/${this.ednaData[layer].taxon.taxon_id}">Taxon Info</a>`;
      }
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
    fetchOccurences: function (taxonName) {
      this.loading = true;
      let ctx = this;
      axios
        .get(`${api.pourOccurrences}?taxon=${taxonName}`)
        .then((response) => {
          // =============
          // GBIF
          // =============
          let reducer = (accumulator, item) => {
            return accumulator + item.count;
          };

          let gbifCount = response.data.gbif.reduce(reducer, 0);
          let layers = Object.values(this.gbifData).filter((i) => i);
          let colors = targetColorRange(layers.length);
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

          // =============
          // eDNA
          // =============
          let groupedEdnaSamples = {};

          response.data.edna.forEach((s) => {
            let period = s.metadata.collection_period;
            if (groupedEdnaSamples[period]) {
              groupedEdnaSamples[period]["count"] += 1;
              groupedEdnaSamples[period]["samples"].push(s);
            } else {
              groupedEdnaSamples[period] = {};
              groupedEdnaSamples[period]["count"] = 1;
              groupedEdnaSamples[period]["samples"] = [];
              groupedEdnaSamples[period]["samples"].push(s);
              groupedEdnaSamples[period]["order"] = s.metadata.order;
            }
          });

          Object.keys(groupedEdnaSamples).forEach((cp, idx) => {
            groupedEdnaSamples[cp]["color"] = targetColor(idx);
          });

          let ednaLegend = [];
          for (const period in groupedEdnaSamples) {
            let group = groupedEdnaSamples[period];
            ednaLegend.push({
              label: period,
              color: group.color,
              count: group.count,
              order: group.order,
            });
          }
          ednaLegend = ednaLegend.sort((a, b) => {
            return a.order - b.order;
          });

          let ednaLayer = taxonEdnaLayer(groupedEdnaSamples, taxonName);

          ctx.ednaData = {
            ...ctx.ednaData,
            [taxonName]: {
              count: response.data.edna.length,
              layer: ednaLayer,
              legend: ednaLegend,
              taxon: response.data.taxon,
              searchTaxon: this.tempSelectedTaxon,
            },
          };

          ctx.map.addLayer(ednaLayer);
          ctx.riverLayer.bringToFront();
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
      this.watershedLayer = createWatershedLayer();
      this.riverLayer = createRiverLayer();
      this.map.addLayer(this.watershedLayer);
      this.map.addLayer(this.riverLayer);

      // var ctx = this;
      // this.map.on("zoomend", function () {
      //   var zoomlevel = ctx.map.getZoom();
      //   console.log("zoom", zoomlevel);
      // });

      this.fetchPourLocations();
    });
  },
};
</script>
