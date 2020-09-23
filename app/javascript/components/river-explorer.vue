<template>
  <div>
    <h1>LA River Explorer</h1>
    <div class="my-container">
      <div id="controls">
        <h2>Monitoring Locations</h2>
        <div>
          <AnalyteList
            :list="locations"
            @addSelectedLayer="appendSelectedLayers"
          />
        </div>
      </div>

      <div id="explorer-content">
        <div v-show="activeTab == 'mapTab'">
          <div id="map"></div>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
  import axios from "axios";

  import {
  import AnalyteList from "./shared/components/analyte-list";
  import { createLARWMP2018 } from "../packs/river_explorer_map";
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
        pourLocationsLayer: null,
      };
    },
    methods: {
      toggleJsonLayer: function(layerName, json) {
        if (this.selectedLayers[layerName]) {
          this.map.removeLayer(this.selectedLayers[layerName]);
          this.selectedLayers[layerName] = null;
        } else {
          this.selectedLayers[layerName] = json;
          this.map.addLayer(this.selectedLayers[layerName]);
        }
      },
      toggleMapMarkerLayer(layerName, mapLayer) {
        if (this.selectedLayers[layerName]) {
          this.map.removeLayer(mapLayer);
          this.selectedLayers[layerName] = null;
        } else {
          this.selectedLayers[layerName] = mapLayer;
          this.map.addLayer(mapLayer);
        }
      },
      appendSelectedLayers: function(layer) {
        if (layer == "LARWMP (2018)" || layer == "PouR") {
        } else {
          this.selectedLayers[layer] = true;
        }

        if (layer == "LARWMP (2018)") {
          this.toggleJsonLayer(layer, createLARWMP2018());
        } else if (layer == "PouR") {
          this.toggleMapMarkerLayer(layer, this.pourLocationsLayer);
        }
      },
      showInfo: function(layer) {
        alert(`Info about ${layer}`);
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
