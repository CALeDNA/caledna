<template>
  <div>
    <div class="inat-watershed-container">
      <section>
        <div class="p-all-sm">
          <h2>iNaturalist Observations</h2>
          <p>
            This maps shows the research-grade iNaturalist observations for the
            LA River Watershed.
          </p>
          <input
            type="checkbox"
            id="occurrences"
            name="occurrences"
            checked
            @click="toggleOccurrences"
          />
          <label for="occurrences">occurrences</label>
        </div>
        <div id="map-occurrences" class="map-container">
          <spinner v-if="loading" />
        </div>
      </section>
      <section>
        <div class="p-all-sm">
          <h2>iNaturalist Species</h2>
          <p>
            This maps shows the species from research-grade iNaturalist
            observations for the LA River Watershed.
          </p>
          <input
            type="checkbox"
            id="species"
            name="species"
            checked
            @click="toggleSpecies"
          />
          <label for="species">Species</label>
        </div>
        <div id="map-species" class="map-container">
          <spinner v-if="loading" />
        </div>
      </section>
    </div>
  </div>
</template>

<script>
import axios from "axios";

import Spinner from "./shared/spinner";

import {
  initMap,
  pourLocationsLayer,
  LARWMPLocationsLayer,
  createRiverLayer,
  createWatershedLayer,
  createMapgridLayer,
  createTaxonClassifications,
  createMapLegend,
} from "../packs/river_explorer_map";
import base_map from "../packs/base_map";
import api from "../utils/api_routes";
import { targetColorRange } from "../utils/map_colors";

export default {
  name: "RiverExplorer",
  components: {
    Spinner,
  },
  data: function () {
    return {
      // misc
      speciesMap: null,
      occurrencesMap: null,
      loading: false,
      // data
      selectedData: {},
      dataMapLayers: {},
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
    },

    toggleSpecies: function (e) {
      let checked = e.target.checked;
      let opacity = checked ? 0.9 : 0;

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
      this.loading = true;

      let ctx = this;
      axios
        .get(api.inatOccurrences)
        .then((response) => {
          let reducer = (accumulator, item) => {
            return accumulator + item.count;
          };
          let colors = targetColorRange(1);

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
          let speciesLegend = createMapLegend(
            speciesClassifications,
            colors,
            "Species Count"
          );
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
            colors,
            "Observations Count"
          );
          occurrencesLegend.addTo(ctx.occurrencesMap);
          ctx.occurrencesMap.addLayer(ctx.occurrencesLayer);
          ctx.occurrencesMap.addLayer(createRiverLayer());
        })
        .catch((e) => {
          console.error(e);
        })
        .finally(() => (this.loading = false));
    },
  },
  mounted: function () {
    this.$nextTick(function () {
      let ctx = this;
      this.speciesMap = initMap("map-species", L.tileLayer(""));
      this.speciesMap.addLayer(createWatershedLayer());

      this.occurrencesMap = initMap("map-occurrences", L.tileLayer(""));
      this.occurrencesMap.addLayer(createWatershedLayer());

      this.fetchPourLocations();
      this.fetchAllOccurences();
    });
  },
};
</script>
