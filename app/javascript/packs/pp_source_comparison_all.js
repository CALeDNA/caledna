import axios from 'axios';
import { Spinner } from 'spin.js';
import  baseVenn from './base_venn.js';

// =============
// config
// =============

const source_names = {
  'edna': 'eDNA',
  'gbif': 'GBIF'
};
let taxaData;
let filters = { taxon_groups: [], taxon_rank: [] };
const apiEndpoint = '/api/v1/pillar_point/source_comparison_all';
const tableEls = []
const graphEls = [
  document.querySelector('#graph-compare'),
  document.querySelector('#table-compare')
]

// =============
// misc
// =============

function initDiversity(endpoint) {
  const opts = { color:'#333',  left: '50%', scale: 1.75 }
  let spinner1 = new Spinner(opts).spin(tableEls[0]);
  let spinner2 = new Spinner(opts).spin(graphEls[0]);

  axios.get(endpoint)
  .then((res) => {
    taxaData = res.data;
    const taxaSets = formatDatasets(taxaData)

    baseVenn.drawVenn(taxaSets, '#graph-compare')

    let tableColumns = ['sets', 'size']
    let tableColumnNames = ['dataset', 'taxa count']
    baseVenn.drawTable(taxaSets, tableColumns, tableColumnNames, '#table-compare')

    spinner1.stop();
    spinner2.stop();
  })
  .catch((err) => console.log(err))
}

function formatDatasets(data) {
  return data.sources.map((source) => {
    const set_name = source.names.map((source) => source_names[source])
    return { sets: set_name, size: source.count }
  })
}

// =============
// init
// =============
baseVenn.config({
  tables: tableEls,
  graphs: graphEls,
  apiEndpoint,
  init: initDiversity,
  chartFilters: filters,
})
initDiversity(apiEndpoint);
