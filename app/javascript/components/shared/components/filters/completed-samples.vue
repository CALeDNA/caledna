<template>
  <span>
    <button
      class="btn btn-default"
      type="button"
      data-toggle="collapse"
      data-target="#collapseFilters"
      aria-expanded="false"
      aria-controls="collapseFilters"
      :class="{ active: expandFilters }"
      @click="expandFilters = !expandFilters"
    >
      <i class="fas fa-sliders-h"></i> Filters
    </button>

    <form class="filters-container collapse" id="collapseFilters" @submit.prevent="submitFilters">
      <div class="row">
        <div class="col-sm-6">
          <substrate :store="store" />
        </div>

        <div class="col-sm-6">
          <primer :store="store" />
        </div>
      </div>

      <button type="submit" class="btn btn-primary">Update Search</button>
      <button class="btn btn-primary" @click.prevent="resetFilters">Reset Search</button>
    </form>
  </span>
</template>

<script>
import Substrate from "./substrate";
import Primer from "./primer";

export default {
  components: {
    Substrate,
    Primer
  },
  data() {
    return {
      expandFilters: false
    };
  },
  methods: {
    resetFilters() {
      this.$emit("reset-filters");
    },
    submitFilters() {
      this.$emit("submit-filters");
    }
  },
  props: {
    store: {
      type: Object
    }
  }
};
</script>
