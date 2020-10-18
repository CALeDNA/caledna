<template>
  <fieldset>
    <legend>
      Sequence Targets
      <span @click="showPrimerModal = true">
        <i class="far fa-question-circle"></i>
      </span>
    </legend>
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
    <Modal v-if="showPrimerModal" @close="showPrimerModal = false">
      <h4 slot="header">Sequence Targets</h4>
      <div slot="body" v-html="modalBody"></div>
    </Modal>
  </fieldset>
</template>

<script>
import axios from "axios";
import Modal from "../modal";

export default {
  name: "Primers",
  components: {
    Modal,
  },
  props: {
    store: {
      type: Object,
    },
  },
  data() {
    return {
      inputName: "primer",
      options: [],
      showPrimerModal: false,
      modalBody: null,
    };
  },
  created() {
    this.fetchPrimers();
  },
  methods: {
    fetchPrimers() {
      axios.get("/api/v1/primers").then((response) => {
        this.options = [];
        this.options.push({
          label: "All",
          value: "all",
          id: "primer-all",
        });
        let body = "";

        response.data.data.forEach((primerData) => {
          let primer = primerData.attributes;

          body += `<h4>${primer.name}</h4>
          <dl class='primer-list'>`;
          if (primer.forward_primer) {
            body += `<dt>Forward Primer</dt>
            <dd>${primer.forward_primer}</dd>`;
          }
          if (primer.reverse_primer) {
            body += `<dt>Reverse Primer</dt>
            <dd>${primer.reverse_primer}</dd>`;
          }
          if (primer.reference) {
            body += `<dt>Citation</dt>
            <dd>${primer.reference}</dd>`;
          }
          body += "</dl>";

          this.options.push({
            label: primer.name,
            value: primer.id,
            id: `primer-${primer.name}`,
          });
        });

        this.modalBody = body;
      });
    },
  },
};
</script>


