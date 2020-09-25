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
                :checked="isLayerSelected(layer)"
                @click="toggleLayerOpacity(layer, $event)"
              />
              <label :for="`${layer}_m`">{{ layer }}</label>
            </div>
            <div>
              <span @click="showInfo(layer)">
                <i class="far fa-question-circle"></i>
              </span>
              <span @click="removeLayer(layer)">
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
        <!-- environmentalTab -->
        <section v-if="activeTab == 'environmentalTab'" class="data-tab">
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
          <button class="btn btn-primary" @click="submitData('mapTab')">
            Add to Map
          </button>
          <button class="btn btn-default" @click="setActiveTab('mapTab')">
            Cancel
          </button>
        </section>
      </div>
    </div>
  </div>
</template>

<script>
  import axios from "axios";

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
  } from "./shared/constants/dataLayers";
  import AnalyteList from "./shared/components/analyte-list";

  import {
    initMap,
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

  export default {
    name: "RiverExplorer",
    components: {
      AnalyteList,
    },
    data: function() {
      return {
        activeTab: "mapTab",
        taxaKeyword: null,
        map: null,
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
        activeTab: "mapTab",
        map: null,
        selectedData: {},
        dataMapLayers: {},
        tempSelectedData: {},
        pourLocationsLayer: null,
      };
    },
    methods: {
      // =============
      // mapTab
      // =============

      // =============
      // taxaTab
      // =============

      // =============
      // dataTab
      // =============
      submitData: function(activeTab) {
        for (const layer in this.tempSelectedData) {
          if (this.tempSelectedData[layer]) {
            this.selectedData[layer] = true;
            this.addLayersToMap(layer);
          }
        }
        this.tempSelectedData = {};

        this.setActiveTab(activeTab);
      },
      addLayersToMap: function(layer) {
        if (layer == LARWMP) {
          this.toggleMapLayer(layer, createLARWMP2018());
        } else if (layer == PouR) {
          this.toggleMapLayer(layer, this.pourLocationsLayer);
        } else if (layer == Temperature) {
          this.toggleMapLayer(layer, sites_2018_temperature);
        } else if (layer == Oxygen) {
          this.toggleMapLayer(layer, sites_2018_oxygen);
        } else if (layer == pH) {
          this.toggleMapLayer(layer, sites_2018_ph);
        } else if (layer == Salinity) {
          this.toggleMapLayer(layer, sites_2018_salinity);
        } else if (layer == SpecificConductivity) {
          this.toggleMapLayer(layer, sites_2018_conductivity);
        }
      },
      // =============
      // analyte-list
      // =============
      appendTempSelectedLayers: function(layer, checked) {
        if (layer == LARWMP || layer == PouR) {
          this.addLayersToMap(layer);
        } else {
          this.tempSelectedData[layer] = checked;
        }
      },
      // =============
      // common
      // =============
      toggleMapLayer: function(layerName, objectLayer) {
        if (this.dataMapLayers[layerName]) {
          this.map.removeLayer(this.dataMapLayers[layerName]);
          this.dataMapLayers[layerName] = null;
        } else if (objectLayer) {
          this.dataMapLayers[layerName] = objectLayer;
          this.map.addLayer(this.dataMapLayers[layerName]);
        }
      },
      setActiveTab: function(tab) {
        this.activeTab = tab;
      },
      showInfo: function(layer) {
        alert(`Info about ${layer}`);
      },
      // =============
      // current list of layers
      // =============
      isLayerSelected: function(layer) {
        return this.selectedData[layer];
      },
      removeLayer: function(layer) {
        delete this.selectedData[layer];
        this.selectedData = { ...this.selectedData };
        this.toggleMapLayer(layer);
      },
      toggleLayerOpacity: function(layer, event) {
        var mapObj = this.dataMapLayers[layer];
        if (mapObj) {
          Object.values(mapObj._layers).forEach((objLayer) => {
            toggleFeatureOpacity(layer, objLayer);
          });
        }
        this.selectedData[layer] = event.target.checked;
      },

      // =============
      // fetch data
      // =============
      fetchPourLocations: function() {
        axios
          .get("/api/v1/places_basic?place_type=pour_location")
          .then((response) => {
            this.pourLocationsLayer = base_map.createMarkerLayer(
              response.data.places,
              base_map.createCircleMarker
            );
          })
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
</script>
