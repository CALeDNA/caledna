<template>
  <div class="row">
    <div class="col col-md-4">
      <ol>
        <li v-for="place in places" v-bind:key="place.id">
          <a :href="'/places/' + place.id">{{ place.name }}</a>
          ({{ place.site_count }} {{ "site" | pluralize(place.site_count) }})
          <span @click="openMapPopup(place)" v-html="placeLink(place)"></span>
        </li>
      </ol>
    </div>

    <div class="col col-md-8">
      <spinner v-if="showSpinner" />
      <div id="mapid"></div>
    </div>
  </div>
</template>

<script>
import axios from "axios";
import pluralize from "pluralize";

import Spinner from "./shared/spinner";
import baseMap from "../packs/base_map.js";
import LaRiverBaseMap from "../packs/la_river_base_map.js";

const placesEndpoint = `/api/v1/places_pour`;

export default {
  name: "PlacesIndex",
  components: {
    Spinner,
  },
  filters: {
    pluralize,
  },
  data() {
    return {
      showSpinner: false,
      places: [],
    };
  },
  created() {
    this.fetchPlaces();
  },

  mounted() {
    this.map = LaRiverBaseMap.createMap(false);
    baseMap.createOverlayEventListeners(this.map);
  },
  methods: {
    placeLink: function (place) {
      return `<a><i class="fas fa-map-marker-alt"></i> map</a>`;
    },
    openMapPopup: function (place) {
      this.map.eachLayer(function (layer) {
        if (layer.recordId === place.id) {
          layer.openPopup();
        }
      });
    },
    //================
    // fetch places
    //================
    fetchPlaces() {
      this.showSpinner = true;
      axios
        .get(placesEndpoint)
        .then((response) => {
          this.places = response.data.places;
          this.places.forEach((place) => {
            let data = LaRiverBaseMap.formatPlaceData(place);
            baseMap.createTriangleMarker(data).addTo(this.map);
          });

          this.showSpinner = false;
        })
        .catch((e) => {
          console.error(e);
        });
    },
  },
};
</script>
