<template>
  <ul>
    <li v-for="(value, key) in list" v-bind:key="key">
      <input
        type="checkbox"
        :id="key"
        :name="key"
        :value="key"
        @click="addLayer(key, $event)"
      />
      <label :for="key">{{ key }} </label>
      <span @click="showInfo(key)">
        <i class="far fa-question-circle"></i>
      </span>
    </li>
  </ul>
</template>

<script>
  export default {
    name: "AnalyteList",
    props: ["list"],
    methods: {
      showInfo: function(layer) {
        alert(`TODO: Add info about ${layer}`);
      },
      addLayer: function(layer, event) {
        this.$emit("addSelectedLayer", layer, event.target.checked);
      },
    },
  };
</script>
