import Vue from "vue";

import App from "../components/places-details-map.vue";

document.addEventListener("DOMContentLoaded", () => {
  new Vue({
    el: document.querySelector("#places-details-map"),
    render: (h) => h(App),
  });
});
