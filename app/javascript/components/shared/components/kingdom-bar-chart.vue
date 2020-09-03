<template>
  <canvas :ref="selector" :id="selector"></canvas>
</template>

<script>
  import Chart from "chart.js";

  export default {
    name: "KingdomBarChart",
    props: ["chartData", "selector"],
    created() {},
    mounted() {
      this.createChart(this.chartData);
    },

    methods: {
      createChart: function(data) {
        let chartData = {};
        data.forEach((datum) => {
          chartData[datum.kingdom] = datum.count;
        });

        this.$nextTick(() => {
          var chartEl = this.$refs[this.selector];
          new Chart(chartEl, {
            type: "bar",
            data: {
              labels: Object.keys(chartData),
              datasets: [
                {
                  label: "Organisms count",
                  data: Object.values(chartData),
                  backgroundColor: [
                    "#77c9d4",
                    "#57bc90",
                    "#015249",
                    "#a5a5af",
                    "#77c9d4",
                    "#57bc90",
                    "#015249",
                    "#a5a5af",
                  ],
                },
              ],
            },
            options: {
              legend: {
                display: false,
              },
              scales: {
                yAxes: [
                  {
                    gridLines: {
                      display: false,
                    },
                  },
                ],
                xAxes: [
                  {
                    gridLines: {
                      display: false,
                    },
                  },
                ],
              },
            },
          });
        });
      },
    },
  };
</script>

<style></style>
