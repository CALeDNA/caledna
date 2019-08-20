import * as d3 from "d3";
import * as venn from "../vendor/venn";

const graphBtn = document.querySelector(".js-graph-btn");
const tableBtn = document.querySelector(".js-table-btn");
let filters;
let tableEls;
let graphEls;
let apiEndpointUrl;
let initApp;

// =============
// misc
// =============

function config({ tables, graphs, apiEndpoint, init, chartFilters }) {
  tableEls = tables;
  graphEls = graphs;
  apiEndpointUrl = apiEndpoint;
  initApp = init;
  filters = chartFilters;
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

function drawVenn(sets, selector) {
  let div = d3.select(selector);
  let chart = venn.VennDiagram();

  div.datum(sets).call(chart);

  let tooltip = d3
    .select("body")
    .append("div")
    .attr("class", "venntooltip");

  div
    .selectAll("path")
    .style("stroke-opacity", 0)
    .style("stroke", "#fff")
    .style("stroke-width", 3);

  div
    .selectAll("g")
    .on("mouseover", function(d, i) {
      // sort all the areas relative to the current item
      venn.sortAreas(div, d);
      // Display a tooltip with the current size
      tooltip
        .transition()
        .duration(400)
        .style("opacity", 0.9);
      tooltip.text(d.size + " taxa");
      // highlight the current path
      let selection = d3
        .select(this)
        .transition("tooltip")
        .duration(400);
      selection
        .select("path")
        .style("fill-opacity", d.sets.length == 1 ? 0.4 : 0.1)
        .style("stroke-opacity", 1);
    })
    .on("mousemove", function() {
      tooltip
        .style("left", d3.event.pageX + "px")
        .style("top", d3.event.pageY - 28 + "px");
    })
    .on("mouseout", function(d, i) {
      tooltip
        .transition()
        .duration(400)
        .style("opacity", 0);
      let selection = d3
        .select(this)
        .transition("tooltip")
        .duration(400);
      selection
        .select("path")
        .style("fill-opacity", d.sets.length == 1 ? 0.25 : 0.0)
        .style("stroke-opacity", 0);
    });

  d3.selectAll(selector + " .venn-circle").on("click", function(data) {
    // TODO: display all species for selected circle
  });
}

function hideGraphs(graphEls) {
  graphEls.forEach(graphEl => (graphEl.style.display = "none"));
}

function showGraphs(graphEls) {
  graphEls.forEach(graphEl => (graphEl.style.display = "block"));
}

// =============
// draw tables
// =============

function drawTable(data, columns, columnNames, selector) {
  removeTable(selector);

  let table = d3
    .select(selector)
    .append("table")
    .attr("class", "table");
  let thead = table.append("thead");
  let tbody = table.append("tbody");

  // append the header row
  thead
    .append("tr")
    .selectAll("th")
    .data(columnNames)
    .enter()
    .append("th")
    .text(column => column);

  // create a row for each object in the data
  let rows = tbody
    .selectAll("tr")
    .data(data)
    .enter()
    .append("tr");

  // create a cell in each row for each column
  let cells = rows
    .selectAll("td")
    .data(function(row) {
      return columns.map(column => {
        return { column: column, value: row[column] };
      });
    })
    .enter()
    .append("td")
    .text((d, i, u) => {
      if (i == 0) {
        return d.value.join(" ∩ ");
      } else {
        return d.value;
      }
    });

  return table;
}

// NOTE: need to remove existing table before redrawing table
function removeTable(selector) {
  const tableEl = document.querySelector(`${selector} table`);
  if (tableEl) {
    tableEl.remove();
  }
}

function hideTables(tableEls) {
  tableEls.forEach(tableEl => (tableEl.style.display = "none"));
}

function showTables(tableEls) {
  tableEls.forEach(tableEl => (tableEl.style.display = "block"));
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

    let url = `${apiEndpointUrl}?${formatQuerystring(filters)}`;
    initApp(url);
  });

if (graphBtn) {
  graphBtn.addEventListener("click", event => {
    hideTables(tableEls);
    showGraphs(graphEls);
  });
}

if (tableBtn) {
  tableBtn.addEventListener("click", event => {
    showTables(tableEls);
    hideGraphs(graphEls);
  });
}

document.querySelector(".js-reset-filters").addEventListener("click", event => {
  event.preventDefault();
  initApp(apiEndpointUrl);

  document.querySelectorAll("input").forEach(el => {
    if (el.value === "all") {
      el.checked = true;
    } else {
      el.checked = false;
    }
  });
});

export default {
  showTables,
  hideTables,
  drawTable,
  drawVenn,
  config
};
