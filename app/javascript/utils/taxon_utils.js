export function formatTaxonName(taxon) {
  const { common_names, canonical_name } = taxon;

  if (common_names) {
    return `${canonical_name} (${common_names.split("|").join(", ")})`;
  } else {
    return canonical_name;
  }
}

export function formatKingdomIcon(taxon) {
  if (taxon.division_name) {
    return `/images/taxa_icons/${taxon.division_name
      .replace(/ /g, "_")
      .toLowerCase()}.png`;
  }
}
