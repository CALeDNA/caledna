<template>
  <div>
    <h1>Search</h1>

    <autocomplete
      url="http://localhost:3000/api/v1/taxa"
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
      <li v-if="selectedTaxon.taxonomicStatus">taxonomic status: {{ selectedTaxon.taxonomicStatus }}</li>
      <li v-if="selectedTaxon.canonicalName">canonical name: {{ selectedTaxon.canonicalName }}</li>
      <li v-if="selectedTaxon.taxonRank">taxon rank: {{ selectedTaxon.taxonRank }}</li>
      <li v-if="selectedTaxon.taxa_dataset.name">source: {{ selectedTaxon.taxa_dataset.name }}</li>
      <!-- <li v-if="selectedTaxon.taxa_dataset.datasetID">datasetID: {{ selectedTaxon.taxa_dataset.datasetID }}</li> -->
      <!-- <li v-if="selectedTaxon.taxonID">taxonID: {{ selectedTaxon.taxonID }}</li> -->
      <!-- <li v-if="selectedTaxon.hierarchy">hierarchy: {{ selectedTaxon.hierarchy }}</li> -->
      <!-- <li v-if="selectedTaxon.status">status: {{ selectedTaxon.status }}</li> -->

    </ul>

    <form  @submit="handleSubmit">
      <label for="kingdom">kingdom</label>
      <input :disabled="isKingdom" type="text" id="kingdom" v-model="newTaxon.kingdom">

      <label for="phylum">phylum</label>
      <input :disabled="isPhylum" type="text" id="phylum" v-model="newTaxon.phylum">

      <label for="class">class</label>
      <input :disabled="isClass"  type="text" id="class" v-model="newTaxon.className">

      <label for="order">order</label>
      <input :disabled="isOrder" type="text" id="order" v-model="newTaxon.order">

      <label for="family">family</label>
      <input :disabled="isFamily" type="text" id="family" v-model="newTaxon.family">

      <label for="genus">genus</label>
      <input :disabled="isGenus" type="text" id="genus" v-model="newTaxon.genus">

      <label for="species">species</label>
      <input :disabled="isSpecies" type="text" id="species" v-model="newTaxon.specificEpithet">

      <label for="scientificName">scientificName</label>
      <input type="text" id="scientificName" v-model="newTaxon.scientificName">

      <label>taxonomy rank</label>
      <select v-model="newTaxon.taxonRank">
        <option disabled value="">Select Rank</option>
        <option
          v-bind:key="rank"
          v-for="rank in taxonRanks"
        >
          {{ rank }}
        </option>
      </select>

      <label>taxonomic status</label>
      <select v-model="newTaxon.taxonomicStatus">
        <option disabled value="">Select Status</option>
        <option v-bind:key="status" v-for="status in taxonomicStatuses">
          {{ status }}
        </option>
      </select>

      <label>taxonomy source</label>
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

      <input type="submit" value="Submit">
    </form>
    {{newTaxon}}<br>
    {{selectedTaxon}}

  </div>


</template>

<script>
  import Autocomplete from 'vue2-autocomplete-js';
  require('vue2-autocomplete-js/dist/style/vue2-autocomplete.css')

export default {
    components: { Autocomplete },
    data () {
      return  {
        selectedTaxon: {
          taxa_dataset: {}
        },
        newTaxon: {},
        taxaDatasets: [
          {
            name: 'Catalogue of Life',
            datasetID: '7ddf754f-d193-4cc9-b351-99906754a03b'
          },
          {
            name: 'Encyclopedia of Life',
            datasetID: 'cal-eol'
          },
          {
            name: 'NCIB',
            datasetID: 'cal-ncib'
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
      }
    },
    methods: {
      processJSON(json) {
        const res = json.data.map((record) => record.attributes);
        console.log(res)
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

      handleSubmit(e) {
        e.preventDefault();

        let species;
        if (/ /.test(this.newTaxon.specificEpithet)) {
          species = this.newTaxon.specificEpithet.split(' ')[1];
        } else {
          species = this.newTaxon.specificEpithet;
        }

        let canonicalName;
        if (this.newTaxon.taxonomyRank === 'species') {
          canonicalName = `${this.newTaxon.genus} ${species}`
        } else if (this.newTaxon.taxonomyRank === 'class') {
          canonicalName = this.newTaxon.className
        } else {
          canonicalName = this.newTaxon[this.newTaxon.taxonomyRank]
        }

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
          taxonomyRank: this.newTaxon.taxonomyRank,
          parentNameUsageID: this.newTaxon.parentNameUsageID,
          hierarchy: this.selectedTaxon.hierarchy,
          scientificName: this.newTaxon.scientificName,
          canonicalName
        }

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
taxonRank
