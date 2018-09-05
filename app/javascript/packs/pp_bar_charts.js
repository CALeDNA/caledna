import Chart from 'chart.js';

$(function() {
  function createChart (selector, data) {
    var chartEl = document.getElementById(selector);
    if (!chartEl) { return }

    new Chart(chartEl, {
      type: 'bar',
      data: {
        labels: Object.keys(data),
        datasets: [{
          label: 'Organisms count',
          data: Object.values(data),
          backgroundColor: [
            '#77c9d4',
            '#57bc90',
            '#015249',
            '#a5a5af',
            '#77c9d4',
            '#57bc90',
            '#015249',
            '#a5a5af',
          ],
        }]
      },
      options: {
        legend: {
          display: false,
        },
        scales: {
          yAxes: [{
            gridLines : {
              display : false
            }
          }],
          xAxes: [{
            gridLines : {
              display : false
            }
          }]
        }
      }
    });
  }

  createChart ('cal-total-chart', window.caledna.cal_division_total)
  createChart ('cal-unique-chart', window.caledna.cal_division_unique)
  createChart ('gbif-total-chart', window.caledna.gbif_division_total)
  createChart ('gbif-unique-chart', window.caledna.gbif_division_unique)

  createChart ('only-inat-chart', window.caledna.only_inat_data)
  createChart ('exclude-inat-chart', window.caledna.exclude_inat_data)

})
