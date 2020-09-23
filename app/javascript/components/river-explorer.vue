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
  import {
  import AnalyteList from "./shared/components/analyte-list";
  import { createLARWMP2018 } from "../packs/river_explorer_map";
  import {
    initMap,
    createRiverLayer,
    createWatershedLayer,
  } from "../packs/river_explorer_map";
  export default {
    name: "RiverExplorer",
    components: {
      AnalyteList,
    },
    data: function() {
      return {
        activeTab: "mapTab",
        map: null,
        selectedLayers: {},
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
      appendSelectedLayers: function(layer) {
        if (layer !== "LARWMP (2018)") {
          this.selectedLayers[layer] = true;
        }

        if (layer == "LARWMP (2018)") {
          this.toggleJsonLayer("LARWMP2018Layer", createLARWMP2018());
        }
      },
    },
    mounted: function() {
      this.$nextTick(function() {
        this.map = initMap();
        this.map.addLayer(createWatershedLayer());
        this.map.addLayer(createRiverLayer());
      });
    },
  };
</script>
