<template>
  <fieldset>
    <legend>Primer</legend>
    <div class="checkbox" v-for="option in options" :key="option.value">
      <label :for="option.id">
        <input
          @click="store.setPrimerArray($event, store)"
          :data-filter-type="inputName"
          type="checkbox"
          :name="inputName"
          :id="option.id"
          :value="option.value"
          v-model="store.state.currentFilters[inputName]"
        />
        {{ option.label }}
      </label>
    </div>
  </fieldset>
</template>

<script>
import axios from "axios";

export default {
  name: "Primers",
  props: {
    store: {
      type: Object
    }
  },
  data() {
    return {
      inputName: "primer",
      options: []
    };
  },
  created() {
    this.fetchPrimers();
  },
  methods: {
    fetchPrimers() {
      axios.get("/api/v1/primers").then(response => {
        this.options = [];
        this.options.push({
          label: "All",
          value: "all",
          id: "primer-all"
        });
        response.data.data.forEach(primer => {
          let name = primer.attributes.name;
          this.options.push({
            label: name,
            value: primer.attributes.id,
            id: `primer-${name}`
          });
        });
      });
    }
  }
};
</script>


