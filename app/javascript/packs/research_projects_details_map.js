import Vue from "vue";

import App from "../components/research-projects-details-map.vue";

document.addEventListener("DOMContentLoaded", () => {
  new Vue({
    el: document.querySelector("#projects-details-map"),
    render: h => h(App)
  });
});
