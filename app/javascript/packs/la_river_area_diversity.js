import axios from "axios";
import { Spinner } from "spin.js";
import baseVenn from "./base_venn.js";

// =============
// config
// =============

const location_names = {
  Hahamongna: "Hahamongna",
  "Maywood Park": "Maywood Park"
};
let diversityData;
let filters = { taxon_groups: [], months: [] };
const apiEndpoint = "/api/v1/la_river/area_diversity";
const tableEls = [document.querySelector("#table-edna")];
const graphEls = [document.querySelector("#graph-edna")];

// =============
// misc
// =============

function initDiversity(endpoint) {
  const opts = { color: "#333", left: "50%", scale: 1.75 };
  let spinner1 = new Spinner(opts).spin(tableEls[0]);
  let spinner2 = new Spinner(opts).spin(graphEls[0]);

  axios
    .get(endpoint)
    .then(res => {
      diversityData = res.data;
      const ednaSets = formatDatasets(diversityData.cal);

      baseVenn.drawVenn(ednaSets, "#graph-edna");

      let tableColumns = ["sets", "size"];
      let tableColumnNames = ["location", "taxa count"];
      baseVenn.drawTable(
        ednaSets,
        tableColumns,
        tableColumnNames,
        "#table-edna"
      );

      spinner1.stop();
      spinner2.stop();
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
// init
// =============

baseVenn.config({
  tables: tableEls,
  graphs: graphEls,
  apiEndpoint,
  init: initDiversity,
  chartFilters: filters
});
baseVenn.showTables(tableEls);
initDiversity(apiEndpoint);
