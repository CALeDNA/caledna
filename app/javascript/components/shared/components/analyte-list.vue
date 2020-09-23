<template>
  <ul>
    <li v-for="(value, key) in list" v-bind:key="key">
      <input
        type="checkbox"
        :id="key"
        :name="key"
        :value="key"
        @click="addLayer(key)"
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
        alert(`Info about ${layer}`);
      },
      addLayer: function(layer) {
        this.$emit("addSelectedLayer", layer);
      },
    },
  };
</script>
