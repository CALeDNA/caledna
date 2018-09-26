<template>
  <div>
    <h2>Search Existing Taxa</h2>

    <autocomplete
      :url='getTaxaRoute'
      param='query'
      anchor="canonical_name"
      label="rank"
      name="autocomplete"
      :classes="{ input: 'form-control', wrapper: 'input-wrapper'}"
      :process="processJSON"
      :onSelect="handleSelect"
    >
    </autocomplete>
    <ul v-if="selectedTaxon.hierarchy_names">
      <li v-if="selectedTaxon.hierarchy_names.superkingdom">superkingdom: {{ selectedTaxon.hierarchy_names.superkingdom }}</li>
      <li v-if="selectedTaxon.hierarchy_names.kingdom">kingdom: {{ selectedTaxon.hierarchy_names.kingdom }}</li>
      <li v-if="selectedTaxon.hierarchy_names.phylum">phylum: {{ selectedTaxon.hierarchy_names.phylum }}</li>
      <li v-if="selectedTaxon.hierarchy_names.class">class: {{ selectedTaxon.hierarchy_names.class }}</li>
      <li v-if="selectedTaxon.hierarchy_names.order">order: {{ selectedTaxon.hierarchy_names.order }}</li>
      <li v-if="selectedTaxon.hierarchy_names.family">family: {{ selectedTaxon.hierarchy_names.family }}</li>
      <li v-if="selectedTaxon.hierarchy_names.genus">genus: {{ selectedTaxon.hierarchy_names.genus }}</li>
      <li v-if="selectedTaxon.hierarchy_names.species">species: {{ selectedTaxon.hierarchy_names.genus }} {{ selectedTaxon.hierarchy_names.species }} </li>
      <li v-if="selectedTaxon.canonical_name">canonical name: {{ selectedTaxon.canonical_name }}</li>
      <li v-if="selectedTaxon.rank">taxon rank: {{ selectedTaxon.rank }}</li>
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
        v-bind:disabled="isSuperkingdom"
        label="Super kingdom"
        field="superkingdom"
      />
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
        field="class"
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
        field="species"
      />


      <div class="field-unit">
        <div class="field-unit__label">
          <label>taxonomy rank</label>
        </div>
        <div class="field-unit__field">
          <select v-model="newTaxon.rank">
            <option disabled value="">Select Rank</option>
            <option
              v-bind:key="rank"
              v-for="rank in ranks"
            >
              {{ rank }}
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
        ranks: [
          'superkingdom', 'kingdom', 'phylum', 'class', 'order', 'family', 'genus',
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
        this.newTaxon.superkingdom = data.hierarchy_names.superkingdom
        this.newTaxon.kingdom = data.hierarchy_names.kingdom
        this.newTaxon.phylum = data.hierarchy_names.phylum
        this.newTaxon.class = data.hierarchy_names.class
        this.newTaxon.order = data.hierarchy_names.order
        this.newTaxon.family = data.hierarchy_names.family
        this.newTaxon.genus = data.hierarchy_names.genus
        this.newTaxon.selectedTaxon = data.selectedTaxon
        this.newTaxon.parent_taxon_id = data.taxon_id
        this.newTaxon.division_id = data.division_id
        this.newTaxon.cal_division_id = data.cal_division_id
      },

      processSpecies(newTaxon) {
        if (newTaxon.species === undefined) { return; }
        let species = newTaxon.species.trim();
        let parts = species.match(/^[A-Z]\w+ (.*?$)/);

        if (parts) {
          species = parts[1];
        }
        return species;
      },

      processIds(selectedTaxon, id) {
        const ids = []
        const ranks = [
          'superkingdom', 'kingdom', 'phylum', 'class', 'order',
          'family', 'genus', 'species'
        ]

        ranks.forEach((rank) => {
           if (selectedTaxon.hierarchy[rank]) {
            ids.push(selectedTaxon.hierarchy[rank])
          }
        })
        ids.push(id)

        return ids
      },

      processCanonicalName(newTaxon) {
        let canonical_name;

        if (newTaxon.rank === 'species') {
          if (!newTaxon.species) { return; }
          if (!newTaxon.genus) { return; }

          const species = this.processSpecies(newTaxon);
          canonical_name = `${newTaxon.genus.trim()} ${species}`
        } else if (newTaxon.rank === 'class') {
          if (!newTaxon.class) { return; }

          canonical_name = newTaxon.class.trim();
        } else {
          if (!newTaxon[newTaxon.rank]) { return; }

          canonical_name = newTaxon[newTaxon.rank].trim();
        }
        return canonical_name;
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
        const canonical_name = this.processCanonicalName(this.newTaxon);
        const id = Number(window.location.pathname.split('normalize_ncbi_taxa/')[1])
        const taxon_id = id + 5000000;
        const hierarchy = { ...this.selectedTaxon.hierarchy, [this.newTaxon.rank]: taxon_id }
        const ids = this.processIds(this.selectedTaxon, taxon_id)

        const body = {
          rank: this.newTaxon.rank,
          parent_taxon_id: this.newTaxon.parent_taxon_id,
          hierarchy,
          hierarchy_names: {
            superkingdom: this.newTaxon.superkingdom,
            kingdom: this.newTaxon.kingdom,
            phylum: this.newTaxon.phylum,
            class: this.newTaxon.class,
            order: this.newTaxon.order,
            family: this.newTaxon.family,
            genus: this.newTaxon.genus,
            species: species,
          },
          canonical_name,
          taxon_id,
          ids,
          cal_taxon_id: id,
          division_id: this.newTaxon.division_id,
          cal_division_id: this.newTaxon.cal_division_id
        }
        console.log(body)

        api.createUpdateTaxa(id, this.trimObject(body))
          .then(this.handleFormSuccess)
          .catch(this.handleFormError);
      },

      calculateRank(num) {
        if (!this.selectedTaxon.rank) { return; }
        return this.ranks.indexOf(this.selectedTaxon.rank) >= num
      }
    },
    computed: {
      isSuperkingdom() {
        return this.calculateRank(0)
      },
      isKingdom() {
        return this.calculateRank(1)
      },
      isPhylum() {
        return this.calculateRank(2)
      },
      isClass() {
        return this.calculateRank(3)
      },
      isOrder() {
        return this.calculateRank(4)
      },
      isFamily() {
        return this.calculateRank(5)
      },
      isGenus() {
        return this.calculateRank(6)
      },
      isSpecies() {
        return this.calculateRank(7)
      },
    }
  };
</script>
