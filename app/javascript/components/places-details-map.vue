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
        {{ taxonSamplesCount }} {{ "site" | pluralize(taxonSamplesCount) }}
      </div>
      <div>
        <input
          type="checkbox"
          value="presence"
          v-model="showSecondaryLayer"
          @click="toggleSecondaryLayer"
        />
        <svg height="30" width="30" @click="toggleSecondaryLayer">
          <circle
            cx="15"
            cy="15"
            r="7"
            stroke="#222"
            stroke-width="2"
            fill="orange"
          />
        </svg>
        {{ secondarySamplesCount }}
        GBIF {{ "occurrence" | pluralize(secondarySamplesCount) }}
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

      <a
        class="btn btn-default"
        :class="{ active: activeTab === 'taxa' }"
        @click="$emit('active-tab-event', 'taxa')"
      >
        <i class="far fa-list-alt"></i> Taxa List
      </a>
      <select v-model="selectedRadius" @change="updateRadius">
        <option v-for="i in [0.5, 1, 2, 3]" :key="i"
          >{{ i }} kilometer</option
        ></select
      >
    </div>

    <div id="mapid" v-show="activeTab === 'map'"></div>

    <h2>eDNA Taxa</h2>
    <kingdom-bar-chart
      v-if="ednaTaxa.length > 0"
      :chart-data="ednaTaxa"
      selector="edna-taxa-chart"
    ></kingdom-bar-chart>

    <h2>eDNA Occurrences</h2>
    <kingdom-bar-chart
      v-if="ednaOccurrences.length > 0"
      :chart-data="ednaOccurrences"
      selector="edna-occurrences-chart"
    ></kingdom-bar-chart>

    <h2>GBIF Taxa</h2>
    <kingdom-bar-chart
      v-if="gbifTaxa.length > 0"
      :chart-data="gbifTaxa"
      selector="gbif-taxa-chart"
    ></kingdom-bar-chart>

    <h2>GBIF Occurrences</h2>
    <kingdom-bar-chart
      v-if="gbifOccurrences.length > 0"
      :chart-data="gbifOccurrences"
      selector="gbif-occurrences-chart"
    ></kingdom-bar-chart>

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

    <div v-show="activeTab === 'taxa'"></div>

    <map-layers-modal />
  </div>
</template>

<script>
  import { VueGoodTable } from "vue-good-table";
  import "vue-good-table/dist/vue-good-table.css";
  import axios from "axios";
  import pluralize from "pluralize";
  var wkx = require("wkx");

  import Spinner from "./shared/components/spinner";
  import MapTableToggle from "./shared/components/map-table-toggle";
  import FiltersLayout from "./shared/components/filters/completed-samples";
  import MapLayersModal from "./shared/components/map-layers-modal";
  import KingdomBarChart from "./shared/components/kingdom-bar-chart";

  import { formatQuerystring } from "../utils/data_viz_filters";
  import baseMap from "../packs/base_map.js";
  import {
    samplesTableColumns,
    samplesDefaultFilters,
  } from "./shared/constants";
  import {
    mapMixins,
    searchMixins,
    taxonLayerMixins,
    secondaryLayerMixins,
  } from "./shared/mixins";
  import { completedSamplesStore } from "./shared/stores";

  var resource_and_id = window.location.pathname.replace(/pages\/.*?$/, "");
  var endpoint = `/api/v1${resource_and_id}`;
  var gbifEndpoint = `/api/v1${resource_and_id}/gbif_occurrences`;
  var kingdomCountsEndpoint = `/api/v1${resource_and_id}/kingdom_counts`;

  export default {
    name: "SamplesMapTable",
    components: {
      VueGoodTable,
      MapTableToggle,
      FiltersLayout,
      Spinner,
      MapLayersModal,
      KingdomBarChart,
    },
    mixins: [mapMixins, searchMixins, taxonLayerMixins, secondaryLayerMixins],
    filters: {
      pluralize,
    },
    data() {
      return {
        activeTab: "map",
        columns: samplesTableColumns,
        rows: [],
        map: null,
        store: completedSamplesStore,
        currentFiltersDisplay: null,
        showSpinner: false,

        selectedRadius: "1 kilometer",
        radius: 1000,
        bufferLayer: null,

        secondarySamplesCount: null,
        secondaryLayer: null,
        showSecondaryLayer: false,
        secondarySamplesData: [],
        initialSecondarySamplesData: [],

        taxonSamplesCount: null,
        taxonLayer: null,
        showTaxonLayer: true,
        taxonSamplesData: [],
        initialTaxonSamplesData: [],

        ednaTaxa: [],
        ednaOccurrences: [],
        gbifTaxa: [],
        gbifOccurrences: [],
      };
    },
    created() {
      this.fetchSamples(endpoint);
      this.fetchKingdomChart(kingdomCountsEndpoint);
    },

    mounted() {
      // let lat = window.caledna.mapLatitude || baseMap.initialLat;
      // let lng = window.caledna.mapLongitude || baseMap.initialLng;
      // let zoom = window.caledna.mapZoom || baseMap.initialZoom;
      // this.map = baseMap.createMap(L.latLng(lat, lng), zoom);
      this.map = baseMap.createMap();

      this.addMapOverlays(this.map);
    },
    methods: {
      updateRadius(e) {
        this.radius = Number(this.selectedRadius.split(" ")[0]) * 1000;
        var url = `${endpoint}?radius=${this.radius}`;
        this.fetchSamples(url);
        var url = `${kingdomCountsEndpoint}?radius=${this.radius}`;
        this.fetchKingdomChart(url);
      },

      setActiveTab(event) {
        this.activeTab = event;
      },

      addTaxonLayer() {
        const samples = this.taxonSamplesData.filter(function(sample) {
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
        this.fetchSamples(endpoint);
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
            status,
            primer_names,
            substrate,
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
            status: status && status.replace("_", " "),
            primers: primer_names ? primer_names.join(", ") : "",
            substrate,
            taxa_count: taxa_count ? taxa_count : 0,
            collection_date: formatDateString(collection_date),
          };
        });
      },

      //================
      // fetch samples
      //================
      fetchSamples(url) {
        this.showSpinner = true;
        axios
          .get(url)
          .then((response) => {
            let place = response.data.place;
            let zoom = this.radius > 1000 ? 15 - this.radius / 2000 : 15;
            this.map.setView([place.latitude, place.longitude], zoom);

            // add boundaries for any geometry other points
            if (!/^POINT/.test("POINT")) {
              L.geoJSON(wkx.Geometry.parse(place.geom).toGeoJSON()).addTo(
                this.map
              );
            }

            if (this.bufferLayer) {
              this.bufferLayer.clearLayers();
            }

            this.bufferLayer = L.geoJSON(
              wkx.Geometry.parse(place.buffer).toGeoJSON()
            ).addTo(this.map);

            const mapData = baseMap.formatMapData(response.data);
            if (this.initialTaxonSamplesData.length == 0) {
              this.initialTaxonSamplesData = mapData.taxonSamplesData;
            }
            this.taxonSamplesData = mapData.taxonSamplesData;

            this.prepareSamplesDisplay();
          })
          .then(() => {
            return axios.get(`${gbifEndpoint}?radius=${this.radius}`);
          })
          .then((response) => {
            var gbifOccurrences = response.data.gbif_occurrences.data.map(
              (sample) =>
                baseMap.formatGBIFData(sample, { fillColor: "orange" })
            );

            if (this.initialSecondarySamplesData.length == 0) {
              this.initialSecondarySamplesData = gbifOccurrences;
            }
            this.secondarySamplesData = gbifOccurrences;

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
        this.secondarySamplesCount = this.secondarySamplesData.length;

        this.removeSecondaryLayer();
        if (this.showSecondaryLayer) {
          this.addSecondaryLayer();
        }

        this.removeTaxonLayer();
        if (this.showTaxonLayer) {
          this.addTaxonLayer();
        }
      },
      fetchKingdomChart(url) {
        axios
          .get(url)
          .then((response) => {
            this.ednaTaxa = response.data.edna_taxa;
            this.ednaOccurrences = response.data.edna_occurrences;
            this.gbifTaxa = response.data.gbif_taxa;
            this.gbifOccurrences = response.data.gbif_occurrences;
          })
          .catch((e) => {
            console.error(e);
          });
      },
    },
  };
</script>
