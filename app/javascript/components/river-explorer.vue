<template>
  <div>
    <h1>LA River Explorer</h1>
    <div class="my-container">
      <div id="controls"></div>

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
    initMap,
    createRiverLayer,
    createWatershedLayer,
  } from "../packs/river_explorer_map";
  export default {
    name: "RiverExplorer",
    data: function() {
      return {
        activeTab: "mapTab",
        map: null,
    mounted: function() {
      this.$nextTick(function() {
        this.map = initMap();
        this.map.addLayer(createWatershedLayer());
        this.map.addLayer(createRiverLayer());
      });
    },
  };
</script>
