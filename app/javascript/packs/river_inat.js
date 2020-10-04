import Vue from "vue";

import App from "../components/river-inat.vue";

document.addEventListener("DOMContentLoaded", () => {
  new Vue({
    el: document.querySelector("#river-app"),
    render: (h) => h(App),
  });
});
