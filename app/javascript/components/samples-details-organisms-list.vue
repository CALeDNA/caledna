<template>
  <ul class="sample-taxa-list">
    <tree :itemData="taxaData"></tree>
  </ul>
</template>

<script>
  import Tree from "./shared/components/tree-item";
  import convertFlatJsonToFlareJson from "../utils/flare_json";

  export default {
    name: "SamplesDetailOrganismsList",
    components: {
      Tree,
    },
    data() {
      return {
        taxaData: [],
        isOpen: false,
      };
    },
    created() {
      this.taxaData = convertFlatJsonToFlareJson(
        this.$root.organisms_list,
        "id"
      );
    },

    mounted() {},
    methods: {},
  };
</script>
