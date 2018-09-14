import * as d3 from 'd3';
import axios from 'axios';
import * as  venn from '../vendor/venn';
import { Spinner } from 'spin.js';

// =============
// config
// =============

const location_names = {
  'Pillar Point embankment unprotected': 'unprotected embankment',
  'Pillar Point exposed unprotected': 'unprotected tidal pools',
  'Pillar Point SMCA': 'SMCA',
};
let diversityData;
let filters = { taxon_groups: [], months: [] };
const areaDiversityEndpoint = '/api/v1/pillar_point/area_diversity';
const tableEdnaEl = document.querySelector('#table-edna')
const tableGbifEl = document.querySelector('#table-gbif')
const graphEdnaEl = document.querySelector('#graph-edna')
const graphGbifEl = document.querySelector('#graph-gbif')
const graphBtn = document.querySelector('.js-graph-btn')
const tableBtn = document.querySelector('.js-table-btn')

// =============
// misc
// =============

function initDiversity(endpoint) {
  const opts = { color:'#333',  left: '50%', scale: 1.75 }
  let spinner1 = new Spinner(opts).spin(tableEdnaEl);
  let spinner2 = new Spinner(opts).spin(graphEdnaEl);

  axios.get(endpoint)
  .then((res) => {
    diversityData = res.data;
    const ednaSets = formatDatasets(diversityData.cal)
    const gbifSets = formatDatasets(diversityData.gbif)
    drawVenn(gbifSets, '#graph-gbif')
    drawVenn(ednaSets, '#graph-edna')
    drawTable(ednaSets, '#table-edna')
    drawTable(gbifSets, '#table-gbif')
    spinner1.stop();
    spinner2.stop();
  })
  .catch((err) => console.log(err))
}

function formatDatasets(data) {
  return data.locations.map((location) => {
    const set_name = location.names.map((location) => location_names[location])
    return { sets: set_name, size: location.count }
  })
}

function formatQuerystring(filters) {
  let query = [];
  for (let key in filters) {
    if(filters[key].length > 0) {
      query.push(`${key}=${filters[key].join('|')}`)
    }
  }
  return query.join('&')
}

// =============
// draw charts
// =============

function drawVenn(sets, selector) {
  let div = d3.select(selector)
  let chart = venn.VennDiagram()

  let customOrdering = {
    "SMCA" : 3,
    "unprotected tidal pools": 1,
    "unprotected embankment" : 2
  }
  chart.orientationOrder(function (a, b) {
    return customOrdering[a.setid] - customOrdering[b.setid]
  })

  div.datum(sets).call(chart);

  let tooltip = d3.select("body").append("div")
    .attr("class", "venntooltip");

  div.selectAll("path")
    .style("stroke-opacity", 0)
    .style("stroke", "#fff")
    .style("stroke-width", 3)

  div.selectAll("g")
    .on("mouseover", function(d, i) {
      // sort all the areas relative to the current item
      venn.sortAreas(div, d);
      // Display a tooltip with the current size
      tooltip.transition().duration(400).style("opacity", .9);
      tooltip.text(d.size + " taxa");
      // highlight the current path
      let selection = d3.select(this).transition("tooltip").duration(400);
      selection.select("path")
        .style("fill-opacity", d.sets.length == 1 ? .4 : .1)
        .style("stroke-opacity", 1);
    })
    .on("mousemove", function() {
      tooltip.style("left", (d3.event.pageX) + "px")
        .style("top", (d3.event.pageY - 28) + "px");
    })
    .on("mouseout", function(d, i) {
      tooltip.transition().duration(400).style("opacity", 0);
      let selection = d3.select(this).transition("tooltip").duration(400);
      selection.select("path")
        .style("fill-opacity", d.sets.length == 1 ? .25 : .0)
        .style("stroke-opacity", 0);
    });

  d3.selectAll(selector + " .venn-circle")
    .on("click", function(data) {
      // TODO: display all species for selected circle
    });
}

function hideGraphs() {
  graphEdnaEl.style.display = 'none'
  graphGbifEl.style.display = 'none'
}

function showGraphs() {
  graphEdnaEl.style.display = 'block'
  graphGbifEl.style.display = 'block'
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
  let columns = ['sets', 'size']
  let column_names = ['location', 'taxa count']

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
    .text((d, i, u) => {
      if (i == 0) {
        return d.value.join(' ∩ ')
      } else {
        return d.value
      }
    });

  return table;
}

// NOTE: need to remove existing table before redrawing table
function removeTable(selector) {
  const tableEl = document.querySelector(`${selector} table`)
  if (tableEl) {
    tableEl.remove()
  }
}

function hideTables() {
  tableEdnaEl.style.display = 'none'
  tableGbifEl.style.display = 'none'
}

function showTables() {
  tableEdnaEl.style.display = 'block'
  tableGbifEl.style.display = 'block'
}

// =============
// event listeners
// =============

document.querySelectorAll('input').forEach((el) => {
  el.addEventListener('click', (event) => {
    let targetFilter = filters[event.target.name]
    if(event.target.checked) {
      if (event.target.value == 'all') {
        targetFilter = []
      } else {
        targetFilter.push(event.target.value)
      }
    } else {
      let index = targetFilter.indexOf(event.target.value);
      if (index > -1) {
        targetFilter.splice(index, 1);
      }
    }
  })
})

document.querySelector('button[type=submit]')
.addEventListener('click', (event) => {
  event.preventDefault();

  let url = `${areaDiversityEndpoint}?${formatQuerystring(filters)}`
  initDiversity(url);
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
  initDiversity(areaDiversityEndpoint);

  document.querySelectorAll('input').forEach((el) => {
    el.checked = false;
  })
});

// =============
// init
// =============

hideTables()
initDiversity(areaDiversityEndpoint);
