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

const location_names = {
  "Arroyo Seco": "Arroyo Seco",
  "Maywood": "Maywood"
};
let diversityData;
const baseFilters = { taxon_groups: [], taxon_rank: [] };
let currentFilters = { taxon_groups: [], taxon_rank: [] };
const endpoint = "/api/v1/research_projects/la_river/area_diversity";
const tableEls = [document.querySelector("#table-edna")];
const graphEls = [document.querySelector("#graph-edna")];

// =============
// misc
// =============

function initApp(endpoint) {
  const opts = { color: "#333", left: "50%", scale: 1.75 };
  let spinner1 = new Spinner(opts).spin(graphEls[0]);

  axios
    .get(endpoint)
    .then(res => {
      diversityData = res.data;
      const ednaSets = formatDatasets(diversityData.cal);

      baseVenn.drawVenn(ednaSets, "#graph-edna");

      let tableColumns = ["sets", "size"];
      let tableColumnNames = ["location", "species count"];
      baseVenn.drawTable(
        ednaSets,
        tableColumns,
        tableColumnNames,
        "#table-edna"
      );

      spinner1.stop();
    })
    .catch(err => console.log(err));
}

function formatDatasets(data) {
  return data.locations.map(location => {
    const set_name = location.names.map(location => location_names[location]);
    return { sets: set_name, size: location.count };
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
baseVenn.showTables(tableEls);
initApp(endpoint);
