function capitalizeFirstLetter(string) {
  return string.charAt(0).toUpperCase() + string.slice(1);
}

function formatLongTaxonString(taxon, taxaGroups) {
  let groupName;
  for(let group in taxaGroups) {
    if (taxaGroups[group].includes(taxon.division)) {
      groupName = capitalizeFirstLetter(group)
    }
  }
  let taxonRanks = [
    taxon.phylum, taxon.class, taxon.order, taxon.family,
    taxon.genus, taxon.species
  ]
  const phylum = taxon.phylum === null ? '--' : taxon.phylum;
  const selectedRank = taxonRanks.filter(rank => rank != phylum)
    .filter(rank => rank !== undefined)
    .filter(rank => rank !== null)

  let taxonString = `${groupName}: ${phylum}`;
  if (selectedRank[0]) {
    taxonString += `, ${selectedRank[0]}`
  }
  return taxonString
}

function formatShortTaxonString(taxon, taxaGroups) {
  let groupName;
  for(let group in taxaGroups) {
    if (taxaGroups[group].includes(taxon.division)) {
      groupName = capitalizeFirstLetter(group)
    }
  }
  const phylum = taxon.phylum === null ? 'N/A' : taxon.phylum;
  return `${groupName}: ${taxon.class}`;
}



function formatChartData(taxon, taxaGroups) {
  const longString = formatLongTaxonString(taxon, taxaGroups)
  const shortString = formatShortTaxonString(taxon, taxaGroups)
  return {
    name: longString,
    value: taxon.count,
    source: taxon.source,
    division: taxon.division,
    tooltip_name: longString,
  }
}

function sortData(dataArray) {
  return dataArray.sort((a, b) => a.value - b.value);
}

function filterAndSortData({ data, limit, taxaGroups, filters }) {
  let sortedFilteredData;

  if(filters.taxon_groups.length > 0) {
    let selectedTaxonGroups = []
    for (let group in taxaGroups) {
      if(filters.taxon_groups.includes(group)) {
        selectedTaxonGroups = selectedTaxonGroups.concat(taxaGroups[group])
      }
    }

    sortedFilteredData = sortData(data.filter((taxon) => {
      return selectedTaxonGroups.includes(taxon.division)
    }))

  } else {
    sortedFilteredData = sortData(data)
  }

  const length = sortedFilteredData.length
  return sortedFilteredData.slice(length - limit, length)
}


export {
  capitalizeFirstLetter,
  formatLongTaxonString,
  formatChartData,
  sortData,
  filterAndSortData,
};
