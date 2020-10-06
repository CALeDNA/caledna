<template>
  <div>
    <input
      type="checkbox"
      id="occurrences"
      name="occurrences"
      checked
      @click="toggleOccurrences"
    />
    <label for="occurrences">iNaturalist</label>

    <div class="my-container">
      <section>
        <h1>LA River Watershed: iNaturalist Observations</h1>
        <div id="map-occurrences" class="map-container"></div>
      </section>
      <section>
        <h1>LA River Watershed: iNaturalist Species</h1>
        <div id="map-species" class="map-container"></div>
      </section>
    </div>
  </div>
</template>

<script>
import axios from "axios";

import AnalyteList from "./shared/analyte-list";

import {
  initMap,
  pourLocationsLayer,
  taxonEdnaLayer,
  taxonGbifLayer,
  LARWMPLocationsLayer,
  createRiverLayer,
  createWatershedLayer,
  createMapgridLayer,
  createTaxonClassifications,
  createMapLegend,
} from "../packs/river_explorer_map";
import base_map from "../packs/base_map";
import api from "../utils/api_routes";
import { randomColorRange, randomColor } from "../utils/misc_util";

export default {
  name: "RiverExplorer",
  components: {
    AnalyteList,
  },
  data: function () {
    return {
      // misc
      activeTab: "mapTab",
      speciesMap: null,
      occurrencesMap: null,
      loading: false,
      // data
      selectedData: {},
      dataMapLayers: {},
      tempSelectedData: {},
      dataLayerHistory: [],
      activeMapLayer: null,
      pourLocationsLayer: null,
      speciesCount: null,
      occurrencesCount: null,
      speciesLayer: null,
      occurrencesLayer: null,
    };
  },

  methods: {
    // =============
    // mapTab
    // =============

    // =============
    // misc
    // =============

    toggleOccurrences: function (e) {
      let checked = e.target.checked;
      let opacity = checked ? 0.9 : 0;

      this.occurrencesLayer.setStyle({
        fillOpacity: opacity,
        opacity: opacity,
      });
      this.speciesLayer.setStyle({ fillOpacity: opacity, opacity: opacity });
    },

    // =============
    // fetch data
    // =============

    fetchPourLocations: function () {
      axios
        .get("/api/v1/places_basic?place_type=pour_location")
        .then((response) => {
          this.pourLocationsLayer = pourLocationsLayer(response.data.places);
        })
        .catch((e) => {
          console.error(e);
        });
    },
    fetchAllOccurences: function () {
      let ctx = this;
      axios
        .get(api.inatOccurrences)
        .then((response) => {
          let reducer = (accumulator, item) => {
            return accumulator + item.count;
          };
          let colors = randomColorRange();

          ctx.speciesCount = response.data.total_species.reduce(reducer, 0);
          let speciesClassifications = createTaxonClassifications(
            response.data.total_species
          );
          ctx.speciesLayer = createMapgridLayer(
            response.data.total_species,
            speciesClassifications,
            colors,
            "species"
          );
          let speciesLegend = createMapLegend(speciesClassifications, colors);
          speciesLegend.addTo(ctx.speciesMap);
          ctx.speciesMap.addLayer(ctx.speciesLayer);
          ctx.speciesMap.addLayer(createRiverLayer());

          ctx.occurrencesCount = response.data.total_occurrences.reduce(
            reducer,
            0
          );
          let occurrencesClassifications = createTaxonClassifications(
            response.data.total_occurrences
          );
          ctx.occurrencesLayer = createMapgridLayer(
            response.data.total_occurrences,
            occurrencesClassifications,
            colors,
            "occurrences"
          );
          let occurrencesLegend = createMapLegend(
            occurrencesClassifications,
            colors
          );
          occurrencesLegend.addTo(ctx.occurrencesMap);
          ctx.occurrencesMap.addLayer(ctx.occurrencesLayer);
          ctx.occurrencesMap.addLayer(createRiverLayer());
          // occurrencesLayer.setStyle({ fillOpacity: 0, opacity: 0 });
          // occurrencesLayer.bringToBack();
        })
        .catch((e) => {
          console.error(e);
        })
        .finally(() => (this.loading = false));
    },
  },
  mounted: function () {
    this.$nextTick(function () {
      this.speciesMap = initMap("map-species");
      this.speciesMap.addLayer(createWatershedLayer());

      this.occurrencesMap = initMap("map-occurrences");
      this.occurrencesMap.addLayer(createWatershedLayer());

      this.fetchPourLocations();
      this.fetchAllOccurences();
    });
  },
};
</script>
