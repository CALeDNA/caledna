<template>
  <div class="row">
    <div class="col col-md-4">
      <div class="taxa-markers">
        <div>
          <input
            type="checkbox"
            value="taxa-sites"
            v-model="showPlacesLayer"
            @click="togglePlacesLayer"
          />
          <svg height="30" width="30" @click="togglePlacesLayer">
            <polygon
              points="15 9, 22 22, 8 22"
              stroke="#222"
              stroke-width="2"
              fill="#5aa172"
            />
          </svg>
          {{ placesCount }} {{ "location" | pluralize(placesCount) }}
        </div>
        <div>
          <input
            type="checkbox"
            value="presence"
            v-model="showSamplesLayer"
            @click="toggleSamplesLayer"
          />
          <svg height="30" width="30" @click="toggleSamplesLayer">
            <circle
              cx="15"
              cy="15"
              r="7"
              stroke="#222"
              stroke-width="2"
              fill="#5aa172"
            />
          </svg>
          {{ samplesCount }} {{ "site" | pluralize(samplesCount) }}
        </div>
      </div>
      <hr />
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

const placesEndpoint = "/api/v1/places_pour";
const samplesEndpoint = "/api/v1/basic_samples";

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
      placesData: [],
      showPlacesLayer: true,
      placesLayer: null,
      placesCount: 0,
      samples: [],
      samplesData: [],
      showSamplesLayer: false,
      samplesLayer: null,
      samplesCount: 0,
    };
  },
  created() {
    this.fetchPlaces();
    this.fetchSamples();
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
    togglePlacesLayer: function () {
      if (this.showPlacesLayer) {
        this.removePlacesLayer();
        this.showPlacesLayer = false;
      } else {
        this.addPlacesLayer();
        this.showPlacesLayer = true;
      }
    },
    addPlacesLayer: function () {
      let layer = baseMap.createMarkerLayer(
        this.placesData,
        baseMap.createTriangleMarker
      );
      this.placesLayer = layer.addTo(this.map);
    },
    removePlacesLayer: function () {
      if (this.showPlacesLayer) {
        this.placesLayer.clearLayers();
      }
    },

    toggleSamplesLayer: function () {
      if (this.showSamplesLayer) {
        this.removeSamplesLayer();
        this.showSamplesLayer = false;
      } else {
        this.addSamplesLayer();
        this.showSamplesLayer = true;
      }
    },
    addSamplesLayer: function () {
      let layer = baseMap.createMarkerLayer(
        this.samplesData,
        baseMap.createCircleMarker
      );
      this.samplesLayer = layer.addTo(this.map);
    },
    removeSamplesLayer: function () {
      if (this.showSamplesLayer) {
        this.samplesLayer.clearLayers();
      }
    },

    //================
    // fetch data
    //================
    fetchPlaces: function () {
      this.showSpinner = true;
      axios
        .get(placesEndpoint)
        .then((response) => {
          this.places = response.data.places;
          this.placesCount = this.places.length;

          this.placesData = this.places.map((place) => {
            return LaRiverBaseMap.formatPlaceData(place);
          });
          this.addPlacesLayer();

          this.showSpinner = false;
        })
        .catch((e) => {
          console.error(e);
        });
    },
    fetchSamples: function () {
      this.showSpinner = true;
      axios
        .get(samplesEndpoint)
        .then((response) => {
          this.samples = response.data.samples;
          this.samplesCount = this.samples.length;

          this.samplesData = this.samples.map((place) => {
            return baseMap.formatSamplesData(place);
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
