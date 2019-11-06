<template>
  <div>
    <spinner v-if="showSpinner" />
    <div id="mapid"></div>
    <map-layers-modal />
  </div>
</template>

<script>
import axios from "axios";

import Spinner from "./shared/components/spinner";
import MapLayersModal from "./shared/components/map-layers-modal";

import baseMap from "../packs/base_map.js";
import { mapMixins } from "./shared/mixins";

export default {
  name: "SamplesDetail-Map",
  components: {
    Spinner,
    MapLayersModal
  },
  data() {
    return {
      map: null,
      endpoint: `/api/v1${window.location.pathname}`,
      showSpinner: false
    };
  },
  created() {
    this.fetchSamples(this.endpoint);
  },
  mounted() {
    this.map = baseMap.createMap();
    this.addMapOverlays(this.map);
  },
  methods: {
    addMapOverlays: mapMixins.methods.addMapOverlays,

    //================
    // fetch samples
    //================
    fetchSamples(url) {
      this.showSpinner = true;
      axios
        .get(url)
        .then(response => {
          const data = baseMap.formatSamplesData(
            response.data.sample.data,
            response.data.asvs_count[0].count
          );

          baseMap.createCircleMarker(data).addTo(this.map);
          this.map.panTo(new L.LatLng(data.lat, data.lng));

          this.showSpinner = false;
        })
        .catch(e => {
          console.error(e);
        });
    }
  }
};
</script>
