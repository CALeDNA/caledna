<template>
  <div>
    <spinner v-if="showSpinner" />
    <div class="taxa-markers">
      <div>
        <svg height="30" width="30" @click="toggleTaxonLayer">
          <circle cx="15" cy="15" r="7" stroke="#222" stroke-width="2" fill="#5aa172" />
        </svg>
        {{taxonSamplesCount}} sites
      </div>
      <div v-show="currentFiltersDisplay">filters: {{currentFiltersDisplay}}</div>
    </div>
    <div class="samples-menu">
      <map-table-toggle :active-tab="activeTab" @active-tab-event="setActiveTab" />
      <filters-layout :store="store" @reset-filters="resetFilters" @submit-filters="submitFilters" />
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
            <a v-bind:href="`/samples/${props.row.id}`">{{props.row.barcode}}</a>
          </span>
          <span v-else-if="props.column.field == 'location'">
            {{props.row.location}}
            <br />
            <br />
            {{props.row.coordinates}}
          </span>
          <span v-else>{{props.formattedRow[props.column.field]}}</span>
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

import Spinner from "./shared/components/spinner";
import MapTableToggle from "./shared/components/map-table-toggle";
import FiltersLayout from "./shared/components/filters/completed-samples";
import MapLayersModal from "./shared/components/map-layers-modal";

import { formatQuerystring } from "../utils/data_viz_filters";
import baseMap from "../packs/base_map.js";
import { samplesTableColumns, samplesDefaultFilters } from "./shared/constants";
import { mapMixins, searchMixins, taxonLayerMixins } from "./shared/mixins";
import { completedSamplesStore } from "./shared/stores";

var resource_and_id = window.location.pathname.replace(/pages\/.*?$/, "");
// var endpoint = `/api/v1${resource_and_id}`;
export default {
  name: "SamplesMapTable",
  components: {
    VueGoodTable,
    MapTableToggle,
    FiltersLayout,
    Spinner,
    MapLayersModal
  },
  mixins: [mapMixins, searchMixins, taxonLayerMixins],
  data() {
    return {
      activeTab: "map",
      columns: samplesTableColumns,
      rows: [],
      map: null,
      endpoint: `/api/v1${resource_and_id}`,
      store: completedSamplesStore,
      currentFiltersDisplay: null,
      showSpinner: false,

      taxonSamplesCount: null,
      taxonLayer: null,
      showTaxonLayer: true,
      taxonSamplesMapData: []
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
      this.taxonLayer = baseMap.renderClusterLayer(
        this.taxonSamplesMapData,
        this.map
      );
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
      let queryString = formatQuerystring(this.store.state.currentFilters);
      let url = queryString ? `${this.endpoint}?${queryString}` : this.endpoint;
      this.fetchSamples(url);
      this.currentFiltersDisplay = this.formatCurrentFiltersDisplay(
        this.store.state.currentFilters
      );
    },

    //================
    // config table
    //================
    formatTableData(samples, asvs_counts) {
      this.rows = samples.map(sample => {
        const {
          id,
          barcode,
          latitude,
          longitude,
          location,
          status,
          gps_precision,
          primers,
          substrate
        } = sample.attributes;

        const asvs_count = asvs_counts.find(
          asvs_count => asvs_count.sample_id === id
        );

        return {
          id,
          barcode,
          coordinates: `${latitude}, ${longitude}`,
          location,
          status: status.replace("_", " "),
          primers: primers.join(", "),
          substrate,
          asv_count: asvs_count ? asvs_count.count : 0
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
        .then(response => {
          const asvs_counts = response.data.asvs_count;
          const taxonSamples = response.data.samples.data;
          this.taxonSamplesCount = taxonSamples.length;

          this.formatTableData(taxonSamples, asvs_counts);

          const mapData = baseMap.formatMapData(response.data);
          this.taxonSamplesMapData = mapData.taxonSamplesMapData;

          this.removeTaxonLayer();
          if (this.showTaxonLayer) {
            this.addTaxonLayer();
          }
          this.showSpinner = false;
        })
        .catch(e => {
          console.error(e);
        });
    }
  }
};
</script>
