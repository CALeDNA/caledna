import axios from "axios";
import Vue from "vue";

import App from "../components/samples-details-organisms-list.vue";
import { asv_tree_init } from "./samples_asv_tree";
import convertFlatJsonToFlareJson from "../utils/flare_json";

document.addEventListener("DOMContentLoaded", () => {
  const endpoint = `/api/v1${window.location.pathname}/taxa_tree`;
  axios.get(endpoint).then((res) => {
    let taxaTree = res.data.taxa_tree;
    let nestedData = convertFlatJsonToFlareJson(taxaTree, "id");

    asv_tree_init(taxaTree, nestedData);
  });

  const endpoint2 = `/api/v1${window.location.pathname}/taxa_list`;
  axios.get(endpoint2).then((res) => {
    new Vue({
      el: document.querySelector("#js-taxa-list"),
      render: (h) => h(App),
      data: { taxa_list: res.data.taxa_list },
    });
  });
});
