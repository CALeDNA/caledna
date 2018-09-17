<template>
  <div>
    <h2>Search Existing Taxa</h2>

    <autocomplete
      :url='getTaxaRoute'
      param='query'
      anchor="canonicalName"
      label="taxonRank"
      name="autocomplete"
      :classes="{ input: 'form-control', wrapper: 'input-wrapper'}"
      :process="processJSON"
      :onSelect="handleSelect"
    >
    </autocomplete>
    <ul v-if="selectedTaxon">
      <li v-if="selectedTaxon.kingdom">kingdom: {{ selectedTaxon.kingdom }}</li>
      <li v-if="selectedTaxon.phylum">phylum: {{ selectedTaxon.phylum }}</li>
      <li v-if="selectedTaxon.className">class: {{ selectedTaxon.className }}</li>
      <li v-if="selectedTaxon.order">order: {{ selectedTaxon.order }}</li>
      <li v-if="selectedTaxon.family">family: {{ selectedTaxon.family }}</li>
      <li v-if="selectedTaxon.genus">genus: {{ selectedTaxon.genus }}</li>
      <li v-if="selectedTaxon.specificEpithet">species: {{ selectedTaxon.genus }} {{ selectedTaxon.specificEpithet }} </li>
      <li v-if="selectedTaxon.scientificName">scientific name: {{ selectedTaxon.scientificName }}</li>
      <li v-if="selectedTaxon.canonicalName">canonical name: {{ selectedTaxon.canonicalName }}</li>
      <li v-if="selectedTaxon.taxonomicStatus">taxonomic status: {{ selectedTaxon.taxonomicStatus }}</li>
      <li v-if="selectedTaxon.taxonRank">taxon rank: {{ selectedTaxon.taxonRank }}</li>
      <li v-if="selectedTaxon.taxa_dataset.name">source: {{ selectedTaxon.taxa_dataset.name }}</li>
    </ul>

    <h2>Create New Taxon</h2>

    <div>
      <ul class="form-errors">
        <li v-for="error in errors" v-bind:key="error">{{error}}</li>
      </ul>
    </div>

    <form  @submit="handleSubmit">
      <TextField
        v-bind:model="newTaxon"
        v-bind:disabled="isKingdom"
        label="Kingdom"
        field="kingdom"
      />
      <TextField
        v-bind:model="newTaxon"
        v-bind:disabled="isPhylum"
        label="Phylum"
        field="phylum"
      />
      <TextField
        v-bind:model="newTaxon"
        v-bind:disabled="isClass"
        label="Class"
        field="className"
      />
      <TextField
        v-bind:model="newTaxon"
        v-bind:disabled="isOrder"
        label="Order"
        field="order"
      />
      <TextField
        v-bind:model="newTaxon"
        v-bind:disabled="isFamily"
        label="Family"
        field="family"
      />
      <TextField
        v-bind:model="newTaxon"
        v-bind:disabled="isGenus"
        label="Genus"
        field="genus"
      />
      <TextField
        v-bind:model="newTaxon"
        v-bind:disabled="isSpecies"
        label="Species"
        field="specificEpithet"
      />
      <TextField
        v-bind:model="newTaxon"
        label="Scientific Name"
        field="scientificName"
      />

      <div class="field-unit">
        <div class="field-unit__label">
          <label>taxonomy rank</label>
        </div>
        <div class="field-unit__field">
          <select v-model="newTaxon.taxonRank">
            <option disabled value="">Select Rank</option>
            <option
              v-bind:key="rank"
              v-for="rank in taxonRanks"
            >
              {{ rank }}
            </option>
          </select>
        </div>
      </div>

      <div class="field-unit">
        <div class="field-unit__label">
          <label>taxonomic status</label>
        </div>
        <div class="field-unit__field">
          <select v-model="newTaxon.taxonomicStatus">
            <option disabled value="">Select Status</option>
            <option v-bind:key="status" v-for="status in taxonomicStatuses">
              {{ status }}
            </option>
          </select>
        </div>
      </div>

      <div class="field-unit">
        <div class="field-unit__label">
          <label>taxonomy source</label>
        </div>
        <div class="field-unit__field">
          <select v-model="newTaxon.datasetID">
            <option disabled value="">Select Source</option>
            <option
              v-bind:key="dataset.name"
              v-for="dataset in taxaDatasets"
              v-bind:value="dataset.datasetID"
            >
              {{ dataset.name }}
            </option>
          </select>
        </div>
      </div>

      <div class="field-unit">
        <div class="field-unit__label">
        </div>
        <div class="field-unit__field">
          <input type="submit" value="Submit">
        </div>
      </div>
    </form>

  </div>

</template>

<script>
  import Autocomplete from 'vue2-autocomplete-js';
  require('vue2-autocomplete-js/dist/style/vue2-autocomplete.css')
  import api from '../utils/api_routes';
  import TextField from './form/text_field';

  export default {
    components: { Autocomplete, TextField },
    data () {
      return  {
        selectedTaxon: {
          taxa_dataset: {}
        },
        newTaxon: {},
        taxaDatasets: [
          {
            name: 'GBIF',
            datasetID: 'd7dddbf4-2cf0-4f39-9b2a-bb099caae36c'
          },
          {
            name: 'Catalogue of Life',
            datasetID: '7ddf754f-d193-4cc9-b351-99906754a03b'
          },
          {
            name: 'Encyclopedia of Life',
            datasetID: 'e632b198-5b2f-47ee-b7a6-6531ea435fa3'
          },
          {
            name: 'NCBI',
            datasetID: 'fab88965-e69d-4491-a04d-e3198b626e52'
          },
        ],
        taxonomicStatuses: [
          'accepted', 'doubtful', 'heterotypic synonym', 'homotypic synonym',
          'synonym'
        ],
        taxonRanks: [
          'kingdom', 'phylum', 'class', 'order', 'family', 'genus',
          'species'
        ],
        getTaxaRoute: api.routes.taxa,
        errors: [],
      }
    },
    methods: {
      processJSON(json) {
        const res = json.data.map((record) => record.attributes);
        return res
      },

      handleSelect(data) {
        this.selectedTaxon = data
        this.newTaxon.kingdom = data.kingdom
        this.newTaxon.phylum = data.phylum
        this.newTaxon.className = data.className
        this.newTaxon.order = data.order
        this.newTaxon.family = data.family
        this.newTaxon.genus = data.genus
        this.newTaxon.selectedTaxon = data.selectedTaxon
        this.newTaxon.parentNameUsageID = data.taxonID
      },

      processSpecies(newTaxon) {
        if (newTaxon.specificEpithet === undefined) { return; }
        let species = newTaxon.specificEpithet.trim();
        let parts = species.match(/^[A-Z]\w+ (.*?$)/);

        if (parts) {
          species = parts[1];
        }
        return species;
      },

      processCanonicalName(newTaxon) {
        let canonicalName;

        if (newTaxon.taxonRank === 'species') {
          if (!newTaxon.specificEpithet) { return; }
          if (!newTaxon.genus) { return; }

          const species = this.processSpecies(newTaxon);
          canonicalName = `${newTaxon.genus.trim()} ${species}`
        } else if (newTaxon.taxonRank === 'class') {
          if (!newTaxon.className) { return; }

          canonicalName = newTaxon.className.trim();
        } else {
          if (!newTaxon[newTaxon.taxonRank]) { return; }

          canonicalName = newTaxon[newTaxon.taxonRank].trim();
        }
        return canonicalName;
      },

      handleFormSuccess(res) {
        if(res.errors) {
          this.errors = res.errors
        } else {
          window.location = "/admin/labwork";
        }
      },

      handleFormError(res) {
        console.log(res)
      },

      trimObject(object) {
        const newObject = {...object};
        Object.keys(newObject).forEach((field) => {
          if(newObject[field] && typeof newObject[field] === 'string') {
            newObject[field] = newObject[field].trim();
          }
        });
        return newObject;
      },

      handleSubmit(e) {
        e.preventDefault();

        const species = this.processSpecies(this.newTaxon);
        const canonicalName = this.processCanonicalName(this.newTaxon);
        const id = Number(window.location.pathname.split('normalize_taxa/')[1]);

        const body = {
          kingdom: this.newTaxon.kingdom,
          phylum: this.newTaxon.phylum,
          className: this.newTaxon.className,
          order: this.newTaxon.order,
          family: this.newTaxon.family,
          genus: this.newTaxon.genus,
          specificEpithet: species,
          datasetID: this.newTaxon.datasetID,
          taxonomicStatus: this.newTaxon.taxonomicStatus,
          taxonRank: this.newTaxon.taxonRank,
          parentNameUsageID: this.newTaxon.parentNameUsageID,
          hierarchy: { ...this.selectedTaxon.hierarchy, [this.newTaxon.taxonRank]: id},
          scientificName: this.newTaxon.scientificName,
          canonicalName,
          taxonID: id,
          genericName: this.newTaxon.genus
        }

        api.createUpdateTaxa(id, this.trimObject(body))
          .then(this.handleFormSuccess)
          .catch(this.handleFormError);
      },

      calculateRank(num) {
        if (!this.selectedTaxon.taxonRank) { return; }
        return this.taxonRanks.indexOf(this.selectedTaxon.taxonRank) >= num
      }
    },
    computed: {
      isKingdom() {
        return this.calculateRank(0)
      },
      isPhylum() {
        return this.calculateRank(1)
      },
      isClass() {
        return this.calculateRank(2)
      },
      isOrder() {
        return this.calculateRank(3)
      },
      isFamily() {
        return this.calculateRank(4)
      },
      isGenus() {
        return this.calculateRank(5)
      },
      isSpecies() {
        return this.calculateRank(6)
      },
    }
  };
</script>
