import Vue from "vue";

import App from "../components/river-explorer.vue";

document.addEventListener("DOMContentLoaded", () => {
  new Vue({
    el: document.querySelector("#river-explorer-app"),
    render: (h) => h(App),
  });
});
