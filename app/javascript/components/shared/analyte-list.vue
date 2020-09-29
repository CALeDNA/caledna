<template>
  <div>
    <ul class="analyte-list">
      <li v-for="(value, key) in list" v-bind:key="key">
        <input
          type="checkbox"
          :id="key"
          :name="key"
          :value="key"
          @click="addLayer(key, $event)"
        />
        <label :for="key">{{ key }}</label>
        <span @click="showModal(key)">
          <i class="far fa-question-circle"></i>
        </span>
        <Modal v-if="key == currentModal" @close="currentModal = null">
          <h3 slot="header">{{ key }}</h3>
          <div slot="body">{{ showBody(key) }}</div>
        </Modal>
      </li>
    </ul>
  </div>
</template>

<script>
import Modal from "./modal";
import { locations } from "../../data/dataLayers";

export default {
  name: "AnalyteList",
  components: {
    Modal,
  },
  props: ["list"],
  data: function () {
    return { currentModal: null };
  },
  methods: {
    showBody: function (layer) {
      if (locations[layer]) {
        return locations[layer];
      } else {
        return `TODO: Add info about ${layer}`;
      }
    },
    showModal: function (layer) {
      this.currentModal = layer;
    },
    addLayer: function (layer, event) {
      this.$emit("addSelectedLayer", layer, event.target.checked);
    },
  },
};
</script>
