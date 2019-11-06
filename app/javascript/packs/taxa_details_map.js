import Vue from "vue";

import App from "../components/taxa-details-map.vue";

document.addEventListener("DOMContentLoaded", () => {
  new Vue({
    el: document.querySelector("#taxa-map-table"),
    render: h => h(App)
  });
});
