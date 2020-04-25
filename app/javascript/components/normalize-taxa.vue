<template>
  <div>
    <h2>Search Existing Taxa</h2>

    <p>
      If the taxon from the taxonomy string is not in the database, you need to
      add new taxa to the the CALeDNA database.
    </p>

    <autocomplete
      :url="getTaxaRoute"
      param="query"
      anchor="canonical_name"
      label="rank"
      name="autocomplete"
      :classes="{ input: 'form-control', wrapper: 'input-wrapper' }"
      :process="fetchSuggestions"
      :onSelect="handleSelect"
    >
    </autocomplete>
    <ul v-if="selectedTaxon.hierarchy_names">
      <li v-if="selectedTaxon.hierarchy_names.superkingdom">
        superkingdom: {{ selectedTaxon.hierarchy_names.superkingdom }}
      </li>
      <li v-if="selectedTaxon.hierarchy_names.kingdom">
        kingdom: {{ selectedTaxon.hierarchy_names.kingdom }}
      </li>
      <li v-if="selectedTaxon.hierarchy_names.phylum">
        phylum: {{ selectedTaxon.hierarchy_names.phylum }}
      </li>
      <li v-if="selectedTaxon.hierarchy_names.class">
        class: {{ selectedTaxon.hierarchy_names.class }}
      </li>
      <li v-if="selectedTaxon.hierarchy_names.order">
        order: {{ selectedTaxon.hierarchy_names.order }}
      </li>
      <li v-if="selectedTaxon.hierarchy_names.family">
        family: {{ selectedTaxon.hierarchy_names.family }}
      </li>
      <li v-if="selectedTaxon.hierarchy_names.genus">
        genus: {{ selectedTaxon.hierarchy_names.genus }}
      </li>
      <li v-if="selectedTaxon.hierarchy_names.species">
        species: {{ selectedTaxon.hierarchy_names.genus }}
        {{ selectedTaxon.hierarchy_names.species }}
      </li>
      <li v-if="selectedTaxon.canonical_name">
        canonical name: {{ selectedTaxon.canonical_name }}
      </li>
      <li v-if="selectedTaxon.rank">taxon rank: {{ selectedTaxon.rank }}</li>
    </ul>

    <h2>Create New Taxon</h2>

    <div>
      <ul class="form-errors">
        <li v-for="error in errors" v-bind:key="error">{{ error }}</li>
      </ul>
    </div>

    <form @submit="handleSubmit">
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
            <option v-bind:key="rank" v-for="rank in ranks">
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
          <select v-model="newTaxon.source">
            <option disabled value="">Select Source</option>
            <option
              v-bind:key="dataset.name"
              v-for="dataset in taxaDatasets"
              v-bind:value="dataset.source"
            >
              {{ dataset.name }}
            </option>
          </select>
        </div>
      </div>

      <TextField v-bind:model="newTaxon" label="Taxon ID" field="sourceId" />

      <div class="field-unit">
        <div class="field-unit__label"></div>
        <div class="field-unit__field">
          <input type="submit" value="Submit" />
        </div>
      </div>
    </form>
  </div>
</template>

<script>
import Autocomplete from "vue2-autocomplete-js";
require("vue2-autocomplete-js/dist/style/vue2-autocomplete.css");
import api from "../utils/api_routes";
import TextField from "./form/text_field";

export default {
  components: { Autocomplete, TextField },
  data() {
    return {
      selectedTaxon: {},
      newTaxon: {},
      taxaDatasets: [
        {
          name: "NCBI",
          source: "NCBI"
        },
        {
          name: "BOLD",
          source: "BOLD"
        }
      ],
      ranks: [
        "superkingdom",
        "kingdom",
        "phylum",
        "class",
        "order",
        "family",
        "genus",
        "species"
      ],
      getTaxaRoute: api.routes.taxa,
      errors: [],
      nextTaxonId: null
    };
  },
  methods: {
    fetchSuggestions(json) {
      const res = json.data.map(record => record.attributes);
      return res;
    },

    handleSelect(data) {
      this.selectedTaxon = data;
      this.newTaxon.superkingdom = data.hierarchy_names.superkingdom;
      this.newTaxon.kingdom = data.hierarchy_names.kingdom;
      this.newTaxon.phylum = data.hierarchy_names.phylum;
      this.newTaxon.class = data.hierarchy_names.class;
      this.newTaxon.order = data.hierarchy_names.order;
      this.newTaxon.family = data.hierarchy_names.family;
      this.newTaxon.genus = data.hierarchy_names.genus;
      this.newTaxon.selectedTaxon = data.selectedTaxon;
      this.newTaxon.parent_taxon_id = data.taxon_id;
      this.newTaxon.division_id = data.division_id;
      this.newTaxon.cal_division_id = data.cal_division_id;

      api.getNextTaxonId().then(res => (this.nextTaxonId = res.next_taxon_id));
    },

    processCanonicalName(newTaxon) {
      if (!newTaxon[newTaxon.rank]) {
        return;
      }

      return newTaxon[newTaxon.rank].trim();
    },

    handleFormSuccess(res) {
      if (res.errors) {
        this.errors = res.errors;
      } else {
        window.location = "/admin/labwork";
      }
    },

    handleFormError(res) {
      console.log(res);
    },

    trimObject(object) {
      const newObject = { ...object };
      Object.keys(newObject).forEach(field => {
        if (newObject[field] && typeof newObject[field] === "string") {
          newObject[field] = newObject[field].trim();
        }
      });
      return newObject;
    },

    handleSubmit(e) {
      e.preventDefault();
      if (!this.selectedTaxon.canonical_name) {
        return;
      }

      const canonical_name = this.processCanonicalName(this.newTaxon);
      const id = Number(
        window.location.pathname.split("normalize_ncbi_taxa/")[1]
      );
      const taxon_id = this.nextTaxonId;
      const hierarchy = {
        ...this.selectedTaxon.hierarchy,
        [this.newTaxon.rank]: taxon_id
      };

      this.selectedTaxon.ids.push(taxon_id);
      this.selectedTaxon.names.push(canonical_name);
      this.selectedTaxon.ranks.push(this.newTaxon.rank);
      this.selectedTaxon.full_taxonomy_string =
        this.selectedTaxon.full_taxonomy_string + `|${canonical_name}`;

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
          species: this.newTaxon.species
        },
        canonical_name,
        taxon_id,
        ids: this.selectedTaxon.ids,
        ranks: this.selectedTaxon.ranks,
        names: this.selectedTaxon.names,
        full_taxonomy_string: this.selectedTaxon.full_taxonomy_string,
        result_taxon_id: id,
        division_id: this.newTaxon.division_id,
        cal_division_id: this.newTaxon.cal_division_id,
        source: this.newTaxon.source
      };

      if (this.newTaxon.source === "NCBI") {
        body.ncbi_id = Number(this.newTaxon.sourceId);
      } else if (this.newTaxon.source === "BOLD") {
        body.bold_id = Number(this.newTaxon.sourceId);
      }

      api
        .createUpdateTaxa(id, this.trimObject(body))
        .then(this.handleFormSuccess)
        .catch(this.handleFormError);
    },

    calculateRank(num) {
      if (!this.selectedTaxon.rank) {
        return;
      }
      return this.ranks.indexOf(this.selectedTaxon.rank) >= num;
    }
  },
  computed: {
    isSuperkingdom() {
      return this.calculateRank(0);
    },
    isKingdom() {
      return this.calculateRank(1);
    },
    isPhylum() {
      return this.calculateRank(2);
    },
    isClass() {
      return this.calculateRank(3);
    },
    isOrder() {
      return this.calculateRank(4);
    },
    isFamily() {
      return this.calculateRank(5);
    },
    isGenus() {
      return this.calculateRank(6);
    },
    isSpecies() {
      return this.calculateRank(7);
    }
  }
};
</script>
