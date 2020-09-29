<template>
  <fieldset>
    <legend>Substrate</legend>
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
        {{option.label}}
      </label>
    </div>
  </fieldset>
</template>

<script>
export default {
  name: "Substrates",
  props: {
    store: {
      type: Object
    }
  },
  data() {
    return {
      inputName: "substrate",
      options: [
        { label: "All", value: "all", id: "substrate-all" },
        { label: "Soil", value: "soil", id: "substrate-soil" },
        { label: "Sediment", value: "sediment", id: "substrate-sediment" },
        { label: "Water", value: "water", id: "substrate-water" }
      ]
    };
  }
};
</script>
