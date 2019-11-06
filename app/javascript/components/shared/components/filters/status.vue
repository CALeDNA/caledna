<template>
  <fieldset>
    <legend>Sample Status</legend>

    <div class="radio" v-for="option in options" :key="option.value">
      <label :for="option.id">
        <input
          @click="store.setPrimerString($event)"
          :data-filter-type="inputName"
          type="radio"
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
  name: "Statuses",
  props: {
    store: {
      type: Object
    }
  },
  data() {
    return {
      inputName: "status",
      options: [
        { label: "All", value: "all", id: "status-all" },
        { label: "Approved", value: "approved", id: "status-approved" },
        {
          label: "Results Completed",
          value: "results_completed",
          id: "status-results-completed"
        }
      ]
    };
  }
};
</script>
