import axios from "axios";
import Vue from "vue";

import App from "../components/samples-details-organisms-list.vue";

document.addEventListener("DOMContentLoaded", () => {
  const endpoint = `/api/v1${window.location.pathname}/organisms_list`;
  axios.get(endpoint).then((res) => {
    new Vue({
      el: document.querySelector("#js-organisms-list"),
      render: (h) => h(App),
      data: { organisms_list: res.data.organisms_list },
    });
  });
});
