<template>
  <div>
    <h1>LA River Explorer</h1>
    <div class="my-container">
      <div id="controls">
        <h2>Monitoring Locations</h2>
        <AnalyteList
          :list="locations"
          @addSelectedLayer="appendSelectedLayers"
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
            v-for="layer in Object.keys(selectedLayers)"
            v-bind:key="layer"
            class="data-layer"
          >
            <div>
              <input
                type="checkbox"
                :id="layer"
                :name="layer"
                :checked="isLayerSelected(layer)"
                @click="toggleLayerOpacity(layer)"
              />
              <label :for="layer">{{ layer }}</label>
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
                @addSelectedLayer="appendSelectedLayers"
              />
            </div>
            <div>
              Attached Algae
              <AnalyteList
                :list="attachedAlgae"
                @addSelectedLayer="appendSelectedLayers"
              />
            </div>
            <div>
              Riparian Habitat Score
              <AnalyteList
                :list="riparianHabitatScore"
                @addSelectedLayer="appendSelectedLayers"
              />
            </div>
            <div>
              InSitu Measurements
              <AnalyteList
                :list="inSituMeasurements"
                @addSelectedLayer="appendSelectedLayers"
              />
            </div>
            <div>
              General Chemistry
              <AnalyteList
                :list="generalChemistry"
                @addSelectedLayer="appendSelectedLayers"
              />
            </div>
            <div>
              Nutrients
              <AnalyteList
                :list="nutrients"
                @addSelectedLayer="appendSelectedLayers"
              />
            </div>
            <div>
              Algal Biomass
              <AnalyteList
                :list="algalBiomass"
                @addSelectedLayer="appendSelectedLayers"
              />
            </div>
            <div>
              Dissolved Metals
              <AnalyteList
                :list="dissolvedMetals"
                @addSelectedLayer="appendSelectedLayers"
              />
            </div>
          </div>
          <button class="btn btn-primary" @click="setActiveTab('mapTab')">
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
  } from "./shared/constants/dataLayers";
  import AnalyteList from "./shared/components/analyte-list";
  import {
    createLARWMP2018,
    createImageLayer,
  } from "../packs/river_explorer_map";
  import {
    initMap,
    createRiverLayer,
    createWatershedLayer,
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
        selectedLayers: {},
        mapLayers: {},
        species: {},
        pourLocationsLayer: null,
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
      };
    },
    methods: {
      toggleMapLayer: function(layerName, objectLayer) {
        if (this.mapLayers[layerName]) {
          this.map.removeLayer(this.mapLayers[layerName]);
          this.mapLayers[layerName] = null;
        } else {
          this.mapLayers[layerName] = objectLayer;
          this.map.addLayer(this.mapLayers[layerName]);
        }
      },

      appendSelectedLayers: function(layer) {
        if (layer == "LARWMP (2018)" || layer == "PouR") {
        } else {
          this.selectedLayers[layer] = true;
        }

        if (layer == "LARWMP (2018)") {
          this.toggleMapLayer(layer, createLARWMP2018());
        } else if (layer == "PouR") {
          this.toggleMapLayer(layer, this.pourLocationsLayer);
        } else if (layer == "Temperature (C°)") {
          let imageLayer = createImageLayer(
            "/data/river_explorer/temperature.png"
          );
          this.toggleMapLayer(layer, imageLayer);
        } else if (layer == "Dissolved Oxygen (mg/L)") {
          let imageLayer = createImageLayer("/data/river_explorer/oxygen.png");
          this.toggleMapLayer(layer, imageLayer);
        }
      },
      isLayerSelected: function(layer) {
        return this.selectedLayers[layer];
      },
      removeLayer: function(layer) {
        delete this.selectedLayers[layer];
        this.selectedLayers = { ...this.selectedLayers };
        this.toggleMapLayer(layer);
      },
      setActiveTab: function(tab) {
        this.activeTab = tab;
      },
      showInfo: function(layer) {
        alert(`Info about ${layer}`);
      },
      toggleLayerOpacity: function(layer) {
        var mapObj = this.mapLayers[layer];
        var image = document.querySelector(`img[src*="${mapObj._url}"]`);
        if (image) {
          image.style.opacity = image.style.opacity == "0" ? 100 : 0;
        }
      },
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
</script>
