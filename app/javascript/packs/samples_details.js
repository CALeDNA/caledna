import axios from "axios";
import Vue from "vue";

import App from "../components/samples-details-organisms-list.vue";
import { asv_tree_init } from "./samples_asv_tree";
import convertFlatJsonToFlareJson from "../utils/flare_json";

document.addEventListener("DOMContentLoaded", () => {
  const endpoint = `/api/v1${window.location.pathname}/taxa_list`;
  axios.get(endpoint).then((res) => {
    let taxaList = res.data.taxa_list;
    let nestedData = convertFlatJsonToFlareJson(taxaList, "id");

    asv_tree_init(taxaList, nestedData);

    new Vue({
      el: document.querySelector("#js-organisms-list"),
      render: (h) => h(App),
      data: { organisms_list: nestedData },
    });
  });
});
