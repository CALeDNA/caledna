<template>
  <div>
    <spinner v-if="showSpinner" />
    <div class="taxa-markers">
      <div>
        <svg height="30" width="30" @click="toggleTaxonLayer">
          <circle
            cx="15"
            cy="15"
            r="7"
            stroke="#222"
            stroke-width="2"
            fill="#5aa172"
          />
        </svg>
        {{ taxonSamplesCount }} {{ "site" | pluralize(taxonSamplesCount) }}
      </div>
      <div class="filters-list" v-show="currentFiltersDisplay">
        filters: {{ currentFiltersDisplay }}
        <a class="btn btn-default reset-search" @click="resetFilters">
          Reset search
        </a>
      </div>
    </div>
    <div class="samples-menu">
      <map-table-toggle
        :active-tab="activeTab"
        @active-tab-event="setActiveTab"
      />
      <filters-layout
        :store="store"
        @reset-filters="resetFilters"
        @submit-filters="submitFilters"
      />
    </div>

    <div id="mapid" v-show="activeTab === 'map'"></div>

    <div v-show="activeTab === 'table'">
      <vue-good-table
        :pagination-options="{
          enabled: true,
          mode: 'records',
          perPage: 25,
          position: 'bottom',
          perPageDropdown: [25, 50],
          dropdownAllowAll: false,
        }"
        :columns="columns"
        :rows="rows"
      >
        <template slot="table-row" slot-scope="props">
          <span v-if="props.column.field == 'barcode'">
            <a v-bind:href="`/samples/${props.row.id}`">{{
              props.row.barcode
            }}</a>
          </span>
          <span v-else-if="props.column.field == 'location'">
            {{ props.row.location }}
            <br />
            <br />
            {{ props.row.coordinates }}
          </span>
          <span v-else>{{ props.formattedRow[props.column.field] }}</span>
        </template>
      </vue-good-table>
    </div>
    <map-layers-modal />
  </div>
</template>

<script>
import { VueGoodTable } from "vue-good-table";
import "vue-good-table/dist/vue-good-table.css";
import axios from "axios";
import pluralize from "pluralize";

import Spinner from "./shared/components/spinner";
import MapTableToggle from "./shared/components/map-table-toggle";
import FiltersLayout from "./shared/components/filters/all-samples";
import MapLayersModal from "./shared/components/map-layers-modal";

import { formatQuerystring } from "../utils/data_viz_filters";
import baseMap from "../packs/base_map.js";
import { samplesTableColumns, samplesDefaultFilters } from "./shared/constants";
import { mapMixins, searchMixins, taxonLayerMixins } from "./shared/mixins";
import { allSamplesStore } from "./shared/stores";
var resource_and_id = window.location.pathname.replace(/pages\/.*?$/, "");
// var endpoint = `/api/v1${resource_and_id}`;
export default {
  name: "SamplesMapTable",
  components: {
    VueGoodTable,
    MapTableToggle,
    FiltersLayout,
    Spinner,
    MapLayersModal,
  },
  mixins: [mapMixins, searchMixins, taxonLayerMixins],
  filters: {
    pluralize,
  },
  data() {
    return {
      activeTab: "map",
      columns: samplesTableColumns,
      rows: [],
      map: null,
      endpoint: `/api/v1${resource_and_id}`,
      store: allSamplesStore,
      currentFiltersDisplay: null,
      showSpinner: false,

      taxonSamplesCount: null,
      taxonLayer: null,
      showTaxonLayer: true,
      taxonSamplesData: [],
      initialTaxonSamplesData: [],
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
    setActiveTab(event) {
      this.activeTab = event;
    },

    addTaxonLayer() {
      const samples = this.taxonSamplesData.filter(function (sample) {
        return sample.latitude && sample.longitude;
      });

      this.taxonLayer = baseMap.renderClusterLayer(samples, this.map);
    },

    //================
    // handle filters
    //================
    resetFilters() {
      this.showTaxonLayer = true;
      this.store.state.currentFilters.keyword = null;
      this.taxonSamplesCount = null;
      this.store.state.currentFilters = { ...samplesDefaultFilters };
      this.fetchSamples(this.endpoint);
      this.currentFiltersDisplay = null;
    },
    submitFilters() {
      this.filterSamplesFrontend();
      this.currentFiltersDisplay = this.formatCurrentFiltersDisplay(
        this.store.state.currentFilters
      );
    },
    filterSamplesFrontend() {
      let filters = this.store.state.currentFilters;
      let samples = this.initialTaxonSamplesData;
      this.taxonSamplesData = this.filterSamples(filters, samples);

      this.prepareSamplesDisplay();
    },

    //================
    // config table
    //================
    formatTableData(samples) {
      this.rows = samples.map((sample) => {
        const {
          id,
          barcode,
          latitude,
          longitude,
          location,
          status_cd,
          primer_names,
          substrate_cd,
          collection_date,
          taxa_count,
        } = sample;

        const formatDateString = (dateString) => {
          let date = new Date(dateString);
          return date.toLocaleDateString();
        };

        return {
          id,
          barcode,
          coordinates: `${latitude}, ${longitude}`,
          location,
          status: status_cd.replace("_", " "),
          primers: primer_names ? primer_names.join(", ") : "",
          substrate: substrate_cd,
          taxa_count: taxa_count ? taxa_count : 0,
          collection_date: formatDateString(collection_date),
        };
      });
    },

    //================
    // fetch samples
    //================
    fetchSamples(url) {
      console.log("fetchSamples", url);
      this.showSpinner = true;
      axios
        .get(url)
        .then((response) => {
          const mapData = baseMap.formatMapData(response.data);
          if (this.initialTaxonSamplesData.length == 0) {
            this.initialTaxonSamplesData = mapData.taxonSamplesData;
          }
          this.taxonSamplesData = mapData.taxonSamplesData;

          this.prepareSamplesDisplay();

          this.showSpinner = false;
        })
        .catch((e) => {
          console.error(e);
        });
    },
    prepareSamplesDisplay() {
      this.formatTableData(this.taxonSamplesData);
      this.taxonSamplesCount = this.taxonSamplesData.length;

      this.removeTaxonLayer();
      if (this.showTaxonLayer) {
        this.addTaxonLayer();
      }
    },
  },
};
</script>
