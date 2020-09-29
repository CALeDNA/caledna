function capitalizeFirstLetter(string) {
  return string.charAt(0).toUpperCase() + string.slice(1);
}

function formatLongTaxonString(taxon) {
  let taxonRanks = [
    taxon.phylum,
    taxon.class,
    taxon.order,
    taxon.family,
    taxon.genus,
    taxon.species,
  ];
  const phylum = taxon.phylum === null ? "--" : taxon.phylum;
  const selectedRank = taxonRanks
    .filter(rank => rank != phylum)
    .filter(rank => rank !== undefined)
    .filter(rank => rank !== null);

  let taxonString = `${taxon.kingdom}: ${phylum}`;
  if (selectedRank[0]) {
    taxonString += `, ${selectedRank[0]}`;
  }
  return taxonString;
}

function formatChartData(taxon) {
  const longString = formatLongTaxonString(taxon);
  return {
    name: longString,
    value: taxon.count,
    source: taxon.source,
    division: taxon.division,
    tooltip_name: longString,
  };
}

function sortData(dataArray) {
  return dataArray.sort((a, b) => a.value - b.value);
}

export {
  capitalizeFirstLetter,
  formatLongTaxonString,
  formatChartData,
  sortData,
};
