import Vue from 'vue';
import App from '../components/app.vue';

document.addEventListener('DOMContentLoaded', () => {

  const app = new Vue({
    el: document.querySelector('#create-taxa-form'),
    render: h => h(App)
  })
})
