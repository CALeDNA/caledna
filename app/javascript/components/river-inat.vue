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
  createMapgridLayer,
  createTaxonClassifications,
  createMapLegend,
  openPopupForMap,
  closePopupForMap,
  getHexagonData,
} from "../packs/river_explorer_map";
import LaRiverBaseMap from "../packs/la_river_base_map";
import api from "../utils/api_routes";
import { targetColorRange } from "../utils/map_colors";
import { inatStore } from "../stores/stores";

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
      occurrencesRiverLayer: null,
      occurrencesWatershedLayer: null,
      speciesRiverLayer: null,
      speciesWatershedLayer: null,
      store: inatStore,
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
            "Species Count",
            "hexagon"
          );
          speciesLegend.addTo(ctx.speciesMap);
          ctx.speciesMap.addLayer(ctx.speciesLayer);

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
            "observations"
          );
          let occurrencesLegend = createMapLegend(
            occurrencesClassifications,
            colors,
            "Observations Count",
            "hexagon"
          );
          occurrencesLegend.addTo(ctx.occurrencesMap);
          ctx.occurrencesMap.addLayer(ctx.occurrencesLayer);
          this.speciesRiverLayer.bringToFront();
          this.occurrencesRiverLayer.bringToFront();
        })
        .catch((e) => {
          console.error(e);
        })
        .finally(() => (this.loading = false));
    },
  },

  watch: {
    "store.hexagonIdExplorer": function (hexagonId) {
      this.store.logger("inat watch", hexagonId);

      if (hexagonId) {
        if (this.store.openInatWatchMap()) {
          openPopupForMap(this.speciesMap, hexagonId);
        }
      } else {
        if (this.store.popupsExist()) {
          closePopupForMap(this.speciesMap);
        }
        if (this.store.popupsExist()) {
          closePopupForMap(this.occurrencesMap);
        }
      }
    },
  },

  mounted: function () {
    this.$nextTick(function () {
      let ctx = this;

      // =============
      // create maps
      // =============
      this.speciesWatershedLayer = LaRiverBaseMap.createWatershedLayer();
      this.speciesRiverLayer = LaRiverBaseMap.createRiverLayer();

      this.speciesMap = initMap({
        watershedLayer: this.speciesWatershedLayer,
        riverLayer: this.speciesRiverLayer,
        selector: "map-species",
        initialTile: "None",
      });

      this.occurrencesWatershedLayer = LaRiverBaseMap.createWatershedLayer();
      this.occurrencesRiverLayer = LaRiverBaseMap.createRiverLayer();

      this.occurrencesMap = initMap({
        watershedLayer: this.occurrencesWatershedLayer,
        riverLayer: this.occurrencesRiverLayer,
        selector: "map-occurrences",
        initialTile: "None",
      });

      this.fetchAllOccurences();

      // =============
      // setup event listeners
      // =============
      this.speciesMap.on("overlayadd", function (e) {
        if (e.name == "LA River Watershed") {
          ctx.speciesWatershedLayer.bringToBack();
        }
      });
      this.occurrencesMap.on("overlayadd", function (e) {
        if (e.name == "LA River Watershed") {
          ctx.occurrencesWatershedLayer.bringToBack();
        }
      });

      this.speciesMap.on("popupopen", function (e) {
        var hexagonData = getHexagonData(e);
        if (hexagonData) {
          ctx.store.openCount += 1;
          ctx.store.hexagonIdInat = +hexagonData[1];
          ctx.store.logger("inat species popupopen", +hexagonData[1]);

          if (ctx.store.openInatMap()) {
            openPopupForMap(ctx.occurrencesMap, ctx.store.hexagonIdInat);
          }
        }
      });
      this.occurrencesMap.on("popupopen", function (e) {
        var hexagonData = getHexagonData(e);
        if (hexagonData) {
          ctx.store.openCount += 1;
          ctx.store.hexagonIdInat = +hexagonData[1];
          ctx.store.logger("inat occurrences popupopen", +hexagonData[1]);

          if (ctx.store.openInatMap()) {
            openPopupForMap(ctx.speciesMap, ctx.store.hexagonIdInat);
          }
        }
      });

      this.speciesMap.on("popupclose", function (e) {
        var hexagonData = getHexagonData(e);
        if (hexagonData) {
          ctx.store.openCount -= 1;
          ctx.store.hexagonIdInat = null;
          ctx.store.logger("inat species popupclose", +hexagonData[1]);

          if (ctx.store.popupsExist()) {
            closePopupForMap(ctx.occurrencesMap);
          }
        }
      });
      this.occurrencesMap.on("popupclose", function (e) {
        var hexagonData = getHexagonData(e);
        if (hexagonData) {
          ctx.store.openCount -= 1;
          ctx.store.hexagonIdInat = null;
          ctx.store.logger("inat occurrences popupclose", +hexagonData[1]);

          if (ctx.store.popupsExist()) {
            closePopupForMap(ctx.speciesMap);
          }
        }
      });
    });
  },
};
</script>
