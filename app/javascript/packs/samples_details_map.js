import Vue from "vue";

import App from "../components/samples-details-map.vue";

document.addEventListener("DOMContentLoaded", () => {
  new Vue({
    el: document.querySelector("#samples-details-map"),
    render: h => h(App)
  });
});
