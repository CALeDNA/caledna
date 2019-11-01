import axios from "axios";
import { Spinner } from "spin.js";
import baseVenn from "./base_venn.js";
import {
  addSubmitHandler,
  addResetHandler,
  addOptionsHander
} from "../utils/data_viz_filters";

// =============
// config
// =============

const source_names = {
  edna: "eDNA",
  gbif: "GBIF"
};
let taxaData;
const baseFilters = { taxon_groups: [], taxon_rank: [] };
let currentFilters = { taxon_groups: [], taxon_rank: [] };
const endpoint = "/api/v1/research_projects/pillar_point/taxonomy_comparison";
const tableEls = [];
const graphEls = [
  document.querySelector("#graph-compare"),
  document.querySelector("#table-compare")
];

// =============
// misc
// =============

function initApp(endpoint) {
  const opts = { color: "#333", left: "50%", scale: 1.75 };
  let spinner1 = new Spinner(opts).spin(tableEls[0]);
  let spinner2 = new Spinner(opts).spin(graphEls[0]);

  axios
    .get(endpoint)
    .then(res => {
      taxaData = res.data;
      const taxaSets = formatDatasets(taxaData);

      baseVenn.drawVenn(taxaSets, "#graph-compare");

      let tableColumns = ["sets", "size"];
      let tableColumnNames = ["dataset", "taxa count"];
      baseVenn.drawTable(
        taxaSets,
        tableColumns,
        tableColumnNames,
        "#table-compare"
      );

      spinner1.stop();
      spinner2.stop();
    })
    .catch(err => console.log(err));
}

function formatDatasets(data) {
  return data.sources.map(source => {
    const set_name = source.names.map(source => source_names[source]);
    return { sets: set_name, size: source.count };
  });
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
baseVenn.config({
  tables: tableEls,
  graphs: graphEls,
  apiEndpoint: endpoint,
  init: initApp,
  chartFilters: currentFilters
});
initApp(endpoint);
