import Chart from "chart.js";
import axios from "axios";
import bar from "britecharts/dist/umd/bar.min";
import miniTooltip from "britecharts/dist/umd/miniTooltip.min";
import * as pp_utils from "services/pp_utils";
import * as d3Selection from "d3-selection";
import * as d3 from "d3";

// =============
// config
// =============

let filters = { taxon_groups: [], taxon_rank: [] };

let chartData = {};
let filteredData = {};
const endpoint = "/api/v1/research_projects/la_river/detection_frequency";
const limit = 200000;
const barHeight = 60;

const chartElCal = document.querySelector("#taxonomic-diversity-chart-cal");

// =============
// misc
// =============

function initApp(endpoint) {
  axios
    .get(endpoint)
    .then(res => {
      let rawDataCal = res.data.cal;
      chartData.cal = rawDataCal.map(taxon => {
        return pp_utils.formatChartData(taxon);
      });

      filteredData.cal = pp_utils.sortData(chartData.cal.slice(0, limit));

      createChart(filteredData.cal, "#taxonomic-diversity-chart-cal");
      d3.selectAll(".y-axis-group.axis")
        .attr("text-anchor", "start")
        .attr("transform", "translate(2, -20)");
    })
    .catch(err => console.log(err));
}

function createColorScheme(data) {
  return data
    .map(taxon => (taxon.source === "ncbi" ? "#5b9f72" : "#ccc"))
    .reverse();
}

function formatQuerystring(filters) {
  let query = [];
  for (let key in filters) {
    if (filters[key].length > 0) {
      query.push(`${key}=${filters[key].join("|")}`);
    }
  }
  return query.join("&");
}

// =============
// draw charts
// =============

function createChart(dataset, selector) {
  removeChart(selector);
  let barContainer = d3Selection.select(selector);
  let barChart = bar();
  let containerWidth = barContainer.node()
    ? barContainer.node().getBoundingClientRect().width
    : false;
  // let tooltipContainer;

  if (containerWidth) {
    // let tooltip = miniTooltip()
    //   .numberFormat(',')
    //   .nameLabel('tooltip_name');

    barChart
      .isHorizontal(true)
      .isAnimated(false)
      .margin({
        left: 340,
        right: 0,
        top: 45,
        bottom: 10
      })
      .percentageAxisToMaxRatio(1.15)
      .xAxisLabel("Occurrences")
      .enableLabels(true)
      .labelsNumberFormat(",")
      .colorSchema(createColorScheme(dataset))
      .width(containerWidth)
      .betweenBarsPadding(0.7)
      .height(dataset.length * barHeight + 50);
    // .on('customMouseOver', tooltip.show)
    // .on('customMouseMove', tooltip.update)
    // .on('customMouseOut', tooltip.hide);

    barContainer.datum(dataset).call(barChart);
    // tooltipContainer = d3Selection.select('#taxonomic-diversity-chart .bar-chart .metadata-group');
    // tooltipContainer.datum([]).call(tooltip);
  }
  transformXAxis();
  return barChart;
}

function transformXAxis() {
  d3Selection
    .selectAll(".x-axis-group.axis")
    .attr("text-anchor", "start")
    .attr("transform", "translate(0, -40)");
}

function updateChart(data, barChart, barContainer) {
  barChart
    .colorSchema(createColorScheme(data))
    .height(data.length * barHeight + 50);

  barContainer.datum(data).call(barChart);
  transformXAxis();

  return barChart;
}

// NOTE: need to remove existing  before redrawing
function removeChart(selector) {
  const targetEl = document.querySelector(`${selector} svg`);
  if (targetEl) {
    targetEl.remove();
  }
}

// =============
// event listeners
// =============

const checkboxEls = document.querySelectorAll("input");

function uncheckTaxonGroupsHandler() {
  checkboxEls.forEach(el => {
    if (el.value !== "all") {
      el.checked = false;
    }
  });
}

function uncheckAllHandler() {
  checkboxEls.forEach(el => {
    if (el.value == "all") {
      el.checked = false;
    }
  });
}

checkboxEls.forEach(el => {
  el.addEventListener("click", event => {
    let currentFilters = filters[event.target.name];

    if (event.target.type === "radio") {
      filters[event.target.name] = [event.target.value];
    } else {
      if (event.target.checked) {
        if (event.target.value == "all") {
          currentFilters = [];
          uncheckTaxonGroupsHandler();
        } else {
          currentFilters.push(event.target.value);
          uncheckAllHandler();
        }
      } else {
        if (event.target.value !== "all") {
          let index = currentFilters.indexOf(event.target.value);
          if (index > -1) {
            currentFilters.splice(index, 1);
          }
        }
      }
      filters[event.target.name] = [...new Set(currentFilters)];
    }
  });
});

document
  .querySelector("button[type=submit]")
  .addEventListener("click", event => {
    event.preventDefault();

    let url = `${endpoint}?${formatQuerystring(filters)}`;
    initApp(url);
  });

document.querySelector(".js-reset-filters").addEventListener("click", event => {
  event.preventDefault();
  initApp(endpoint);

  document.querySelectorAll("input").forEach(el => {
    if (el.value === "all") {
      el.checked = true;
    } else {
      el.checked = false;
    }
  });
});

// =============
// init
// =============

initApp(endpoint);
