import axios from "axios";
import bar from "britecharts/dist/umd/bar.min";
import * as pp_utils from "utils/pp_utils";
import * as d3Selection from "d3-selection";
import * as d3 from "d3";

import {
  addSubmitHandler,
  addResetHandler,
  addOptionsHander,
} from "../utils/data_viz_filters";

// =============
// config
// =============
const baseFilters = { taxon_groups: [], taxon_rank: [] };
let currentFilters = { taxon_groups: [], taxon_rank: [] };

let chartData = {};
let filteredData = {};
const endpoint = "/api/v1/research_projects/la_river/detection_frequency";
const limit = 200000;
const barHeight = 60;

// =============
// misc
// =============

function initApp(endpoint) {
  axios
    .get(endpoint)
    .then((res) => {
      let rawDataCal = res.data.cal;
      chartData.cal = rawDataCal.map((taxon) => {
        return pp_utils.formatChartData(taxon);
      });

      filteredData.cal = pp_utils.sortData(chartData.cal.slice(0, limit));

      createChart(filteredData.cal, "#taxonomic-diversity-chart-cal");
      d3.selectAll(".y-axis-group.axis")
        .attr("text-anchor", "start")
        .attr("transform", "translate(2, -20)");
    })
    .catch((err) => console.log(err));
}

function createColorScheme(data) {
  return data
    .map((taxon) => (taxon.source === "ncbi" ? "#5b9f72" : "#ccc"))
    .reverse();
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
        bottom: 10,
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

const optionEls = document.querySelectorAll(".filter-option");

function setFilters(newFilters) {
  currentFilters = newFilters;
  // console.log('currentFilters', currentFilters)
}

function resetFilters() {
  currentFilters = JSON.parse(JSON.stringify(baseFilters));
  // console.log('currentFilters', currentFilters)
}

function fetchFilters() {
  return currentFilters;
}

addOptionsHander(optionEls, fetchFilters, setFilters);
addSubmitHandler(initApp, endpoint, fetchFilters);
addResetHandler(initApp, endpoint, resetFilters);
// =============
// init
// =============

initApp(endpoint);
