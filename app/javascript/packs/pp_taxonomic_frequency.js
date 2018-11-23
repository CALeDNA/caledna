import Chart from 'chart.js';
import axios from 'axios';
import bar from 'britecharts/dist/umd/bar.min';
import miniTooltip from 'britecharts/dist/umd/miniTooltip.min';
import * as pp_utils from 'services/pp_utils';
import * as d3Selection from 'd3-selection';
import * as d3 from 'd3';

// =============
// config
// =============

let filters = { taxon_groups: [] };

const taxaGroups = {
  animals: ['Animals', 'Animalia'],
  plants: ['Plants', 'Plantae'],
  bacteria: ['Bacteria', 'Viruses', 'Archaea'],
  chromista: ['Chromista'],
  archaea: ['Archaea'],
  plants_and_fungi: ['Plants and Fungi'],
  fungi: ['Fungi']
}

let chartData = {};
let filteredData = {};
const endpoint = '/api/v1/pillar_point/pillar_point_biodiversity_bias';
const graphBtn = document.querySelector('.js-graph-btn')
const tableBtn = document.querySelector('.js-table-btn')
const limit = 200000;
const barHeight = 40;

const barContainerCal = d3Selection.select('#taxonomic-diversity-chart-cal');
const chartElCal = document.querySelector('#taxonomic-diversity-chart-cal')
const tableElCal = document.querySelector('#taxonomic-diversity-table-cal')
let barChartCal;

const barContainerGbif = d3Selection.select('#taxonomic-diversity-chart-gbif');
const chartElGbif = document.querySelector('#taxonomic-diversity-chart-gbif')
const tableElGbif = document.querySelector('#taxonomic-diversity-table-gbif')
let barChartGbif;



// =============
// misc
// =============

function initBias() {
  axios.get(endpoint)
  .then((res) => {
    let rawDataCal = res.data.cal
    let rawDataGbif = res.data.gbif
    chartData.cal = rawDataCal.map((taxon) => {
      return pp_utils.formatChartData(taxon, taxaGroups)
    })
    chartData.gbif = rawDataGbif.map((taxon) => {
      return pp_utils.formatChartData(taxon, taxaGroups)
    })

    filteredData.cal = pp_utils.sortData(chartData.cal.slice(0, limit))
    filteredData.gbif = pp_utils.sortData(chartData.gbif.slice(0, limit))

    barChartCal = createChart(filteredData.cal, barChartCal, barContainerCal)
    barChartGbif = createChart(filteredData.gbif, barChartGbif, barContainerGbif)
    drawTable(filteredData.cal.reverse(), "#taxonomic-diversity-table-cal")
    drawTable(filteredData.gbif.reverse(), "#taxonomic-diversity-table-gbif")
  })
  .catch(err => console.log(err))
}

// function initStats() {
//   axios.get('/api/v1/pillar_point/pillar_point_occurrences')
//   .then((res) => {
//     let rawData = res.data
//     chartData = rawData.map((taxon) => {
//       return pp_utils.formatChartData(taxon, taxaGroups)
//     })
//     filteredData = pp_utils.sortData(chartData.slice(0, limit))

//     createChart(filteredData)
//     drawTable(filteredData.reverse(), "#taxonomic-diversity-table")
//   })
//   .catch(err => console.log(err))
// }

function createColorScheme(data) {
  return data.map((taxon) => taxon.source === 'ncbi' ? '#5b9f72' : '#ccc').reverse()
}


// =============
// draw charts
// =============

function createChart(dataset, barChart, barContainer) {
  barChart = bar();
  let containerWidth = barContainer.node() ? barContainer.node().getBoundingClientRect().width : false;
  let tooltipContainer;

  if (containerWidth) {
    let tooltip = miniTooltip()
      .numberFormat(',')
      .nameLabel('tooltip_name');

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
      .xAxisLabel('Occurrences')
      .enableLabels(true)
      .labelsNumberFormat(',')
      .colorSchema(createColorScheme(dataset))
      .width(containerWidth)
      .yAxisPaddingBetweenChart(10)
      .height(dataset.length * barHeight + 50)
      .on('customMouseOver', tooltip.show)
      .on('customMouseMove', tooltip.update)
      .on('customMouseOut', tooltip.hide);

    barContainer.datum(dataset).call(barChart);
    tooltipContainer = d3Selection.select('#taxonomic-diversity-chart .bar-chart .metadata-group');
    tooltipContainer.datum([]).call(tooltip);
  }
  transformXAxis()
  return barChart
}

function transformXAxis() {
  d3Selection.selectAll('.x-axis-group.axis').attr('text-anchor', 'start').attr('transform', 'translate(0, -40)');
}

function updateChart(data, barChart, barContainer) {
  barChart.colorSchema(createColorScheme(data))
    .height(data.length * barHeight + 50)

  barContainer.datum(data).call(barChart);
  transformXAxis()

  return barChart
}

function hideGraphs() {
  chartElCal.style.display = 'none'
  chartElGbif.style.display = 'none'
}

function showGraphs() {
  chartElCal.style.display = 'block'
  chartElGbif.style.display = 'block'
}


// =============
// draw tables
// =============

function drawTable(data, selector) {
  removeTable(selector)

  let table = d3.select(selector)
    .append('table')
    .attr("class", "table")
  let thead = table.append('thead')
  let  tbody = table.append('tbody');
  let columns = ['name', 'value']
  let column_names = ['', 'occurrence count']

  // append the header row
  thead.append('tr')
    .selectAll('th')
    .data(column_names).enter()
    .append('th')
    .text((column) => column);

  // create a row for each object in the data
  let rows = tbody.selectAll('tr')
    .data(data)
    .enter()
    .append('tr');

  // create a cell in each row for each column
  let cells = rows.selectAll('td')
    .data(function (row) {
      return columns.map((column) => {
        return { column: column, value: row[column] };
      });
    })
    .enter()
    .append('td')
    .text((d) => d.value);

  return table;
}

// NOTE: need to remove existing table before redrawing table
function removeTable(selector) {
  const targetTableEl = document.querySelector(`${selector} table`)
  if (targetTableEl) {
    targetTableEl.remove()
  }
}

function hideTables() {
  tableElCal.style.display = 'none'
  tableElGbif.style.display = 'none'
}

function showTables() {
  tableElCal.style.display = 'block'
  tableElGbif.style.display = 'block'
}

// =============
// event listeners
// =============

const checkboxEls = document.querySelectorAll('input')

function uncheckTaxonGroupsHandler () {
  checkboxEls.forEach((el) => {
    if (el.value !== 'all') {
      el.checked = false;
    }
  })
}

function uncheckAllHandler () {
  checkboxEls.forEach((el) => {
    if (el.value == 'all') {
      el.checked = false;
    }
  })
}

checkboxEls.forEach((el) => {
  el.addEventListener('click', (event) => {
    let currentFilters = [...filters[event.target.name]]
    let eventTarget = event.target

    if(eventTarget.checked) {
      if (eventTarget.value == 'all') {
        currentFilters = []
        uncheckTaxonGroupsHandler()

      } else {
        currentFilters.push(eventTarget.value)
        uncheckAllHandler()
      }
    } else {
      if (eventTarget.value !== 'all') {
        let index = currentFilters.indexOf(eventTarget.value);
        if (index > -1) {
          currentFilters.splice(index, 1);
        }
      }
    }
    filters[event.target.name] = [...new Set(currentFilters)]
    console.log('currentFilters', filters[event.target.name])
  })
})

document.querySelector('button[type=submit]')
.addEventListener('click', (event) => {
  event.preventDefault();

  const optionsCal = { data: chartData.cal, limit, taxaGroups, filters }
  filteredData.cal = pp_utils.filterAndSortData(optionsCal)

  const optionsGbif = { data: chartData.gbif, limit, taxaGroups, filters }
  filteredData.gbif = pp_utils.filterAndSortData(optionsGbif)

  barChartCal = updateChart(filteredData.cal, barChartCal, barContainerCal)
  barChartGbif = updateChart(filteredData.gbif, barChartGbif, barContainerGbif)
  drawTable(filteredData.cal.reverse(), "#taxonomic-diversity-table-cal")
  drawTable(filteredData.gbif.reverse(), "#taxonomic-diversity-table-gbif")
});

graphBtn.addEventListener('click', (event) => {
  hideTables()
  showGraphs()
});


tableBtn.addEventListener('click', (event) => {
  showTables()
  hideGraphs()
});

document.querySelector('.js-reset-filters')
.addEventListener('click', (event) => {
  event.preventDefault();

  let dataCal = pp_utils.sortData(chartData.cal.slice(0, limit))
  let dataGbif = pp_utils.sortData(chartData.cal.slice(0, limit))
  barChartCal = updateChart(dataCal, barChartCal, barContainerCal)
  barChartGbif = updateChart(dataGbif, barChartGbif, barContainerGbif)

  drawTable(dataCal.reverse(), "#taxonomic-diversity-table-cal")
  drawTable(dataGbif.reverse(), "#taxonomic-diversity-table-gbif")

  document.querySelectorAll('input').forEach((el) => {
    if (el.value === 'all') {
      el.checked = true;
    } else  {
      el.checked = false;
    }
  })
});

// =============
// init
// =============

hideTables()
initBias()
