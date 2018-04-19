import Chart from 'chart.js';

$(function() {
  window.caledna.kingdom_counts.forEach((kingdom_count) => {
    var chartEl = document.getElementById(`kingdom-chart-${kingdom_count.id}`);
    if (!chartEl) { return }

    new Chart(chartEl, {
      type: 'bar',
      data: {
        labels: Object.keys(kingdom_count.counts),
        datasets: [{
          label: 'Organisms count',
          data: Object.values(kingdom_count.counts),
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

  })


});
