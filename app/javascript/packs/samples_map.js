import Vue from "vue";

import App from "../components/samples-map.vue";

document.addEventListener("DOMContentLoaded", () => {
  new Vue({
    el: document.querySelector("#samples-map"),
    render: h => h(App)
  });
});
