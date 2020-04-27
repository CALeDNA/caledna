import { get, put } from "./http";

const baseUrl = "/api/v1";

const routes = {
  taxa: `${baseUrl}/taxa`,
  taxaNextTaxonId: `${baseUrl}/taxa/next_taxon_id`,
  normalizeTaxa: "/admin/labwork/normalize_ncbi_taxa",
};

const updateAndCreateTaxa = (id, body) => {
  let url = `${routes.normalizeTaxa}/${id}/update_and_create_taxa`;
  return put(url, { body });
};

const getNextTaxonId = () => {
  return get(routes.taxaNextTaxonId);
};

export default {
  routes,
  updateAndCreateTaxa,
  getNextTaxonId,
};
