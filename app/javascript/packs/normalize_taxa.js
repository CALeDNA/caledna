import Vue from 'vue';
import App from '../components/normalize-taxa.vue';

document.addEventListener('DOMContentLoaded', () => {

  const app = new Vue({
    el: document.querySelector('#js-autocomplete-normalize-taxa'),
    render: h => h(App)
  })
})
