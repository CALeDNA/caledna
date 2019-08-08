import Chart from "chart.js";

$(function() {
  const kingdoms = ["Animalia", "Archaea", "Bacteria", "Fungi", "Plantae"];

  window.caledna.kingdom_counts.forEach(kingdom_count => {
    var chartEl = document.getElementById(`kingdom-chart-${kingdom_count.id}`);
    if (!chartEl) {
      return;
    }

    const filteredCounts = {};
    kingdoms.forEach(kingdom => {
      filteredCounts[kingdom] = kingdom_count.counts[kingdom];
    });

    new Chart(chartEl, {
      type: "bar",
      data: {
        labels: Object.keys(filteredCounts),
        datasets: [
          {
            label: "Organisms count",
            data: Object.values(filteredCounts),
            backgroundColor: [
              "#77c9d4",
              "#57bc90",
              "#015249",
              "#a5a5af",
              "#77c9d4",
              "#57bc90",
              "#015249",
              "#a5a5af"
            ]
          }
        ]
      },
      options: {
        legend: {
          display: false
        },
        scales: {
          yAxes: [
            {
              gridLines: {
                display: false
              }
            }
          ],
          xAxes: [
            {
              gridLines: {
                display: false
              }
            }
          ]
        }
      }
    });
  });
});
