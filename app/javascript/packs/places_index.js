import Vue from "vue";

import App from "../components/places-index-map.vue";

document.addEventListener("DOMContentLoaded", () => {
  new Vue({
    el: document.querySelector("#places-index"),
    render: (h) => h(App),
  });
});
