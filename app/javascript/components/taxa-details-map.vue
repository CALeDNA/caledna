<template>
  <div>
    <spinner v-if="showSpinner" />

    <div class="taxa-markers">
      <div>
        <input
          type="checkbox"
          value="taxa-sites"
          v-model="showTaxonLayer"
          @click="toggleTaxonLayer"
        />
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
        {{ taxonSamplesCount }} {{ "site" | pluralize(taxonSamplesCount) }} with
        {{ taxonDisplayName }}
      </div>
      <div>
        <input
          type="checkbox"
          value="presence"
          v-model="showBaseLayer"
          @click="toggleBaseLayer"
        />
        <svg height="30" width="30" @click="toggleBaseLayer">
          <circle
            cx="15"
            cy="15"
            r="7"
            stroke="#777"
            stroke-width="2"
            fill="#ddd"
          />
        </svg>
        {{ baseSamplesCount }} {{ "site" | pluralize(baseSamplesCount) }} with
        eDNA results
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
          dropdownAllowAll: false
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
          <span
            v-html="processLocationTD(props.row)"
            v-else-if="props.column.field == 'location'"
          ></span>
          <span
            v-html="processTaxaTD(props.row.taxa)"
            v-else-if="props.column.field == 'taxa'"
          ></span>
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
import FiltersLayout from "./shared/components/filters/completed-samples";
import MapLayersModal from "./shared/components/map-layers-modal";

import { formatQuerystring } from "../utils/data_viz_filters";
import baseMap from "../packs/base_map.js";
import { taxaTableColumns, taxaDefaultFilters } from "./shared/constants";
import {
  mapMixins,
  searchMixins,
  taxonLayerMixins,
  baseLayerMixins
} from "./shared/mixins";
import { completedSamplesStore } from "./shared/stores";

export default {
  name: "TaxaMapTable",
  components: {
    VueGoodTable,
    MapTableToggle,
    FiltersLayout,
    Spinner,
    MapLayersModal
  },
  mixins: [mapMixins, searchMixins, taxonLayerMixins, baseLayerMixins],
  filters: {
    pluralize
  },
  data() {
    return {
      activeTab: "map",
      columns: taxaTableColumns,
      rows: [],
      map: null,
      endpoint: `/api/v1${window.location.pathname}`,
      store: completedSamplesStore,
      taxon: "",
      currentFiltersDisplay: null,
      showSpinner: false,

      baseSamplesCount: null,
      baseLayer: null,
      showBaseLayer: false,
      baseSamplesData: [],

      taxonSamplesCount: null,
      taxonLayer: null,
      showTaxonLayer: true,
      taxonSamplesData: []
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

    //================
    // handle filters
    //================
    resetFilters() {
      this.showBaseLayer = false;
      this.showTaxonLayer = true;
      this.store.state.currentFilters = { ...taxaDefaultFilters };
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
          substrate,
          taxa
        } = sample.attributes;

        const asvs_count = asvs_counts.find(
          asvs_count => asvs_count.sample_id === id
        );

        return {
          id,
          barcode,
          coordinates: `${latitude}, ${longitude}`,
          location: location,
          status: status.replace("_", " "),
          primers: primers.join(", "),
          substrate,
          taxa,
          asv_count: asvs_count ? asvs_count.count : 0
        };
      });
    },

    processTaxaTD(taxa) {
      let limit = 20;
      let body = `${taxa.length} matching taxa<br>`;
      body += taxa
        .slice(0, limit)
        .map(t => {
          let parts = t.split("|");
          return `<a href="/taxa/${parts[1].trim()}">${parts[0]}</a>`;
        })
        .join(", ");
      return body;
    },

    processLocationTD(row) {
      let limit = 20;
      let body = "";
      if (row.location) {
        body += `${row.location}<br>`;
      }
      body += row.coordinates;
      return body;
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
          const baseSamples = response.data.base_samples.data;
          this.taxon = response.data.taxon.data.attributes;
          this.taxonSamplesCount = taxonSamples.length;
          this.baseSamplesCount = baseSamples.length;

          this.formatTableData(taxonSamples, asvs_counts);

          const mapData = baseMap.formatMapData(response.data);
          this.taxonSamplesData = mapData.taxonSamplesData;
          this.baseSamplesData = mapData.baseSamplesData;

          this.removeBaseLayer();
          if (this.showBaseLayer) {
            this.addBaseLayer();
          }

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
  },
  computed: {
    taxonDisplayName() {
      let name = this.taxon.canonicalName;
      if (this.taxon.common_names) {
        name += ` (${this.taxon.common_names.split("|").join(", ")})`;
      }
      return name;
    }
  }
};
</script>
