import { get, put } from "./http";

const baseUrl = "/api/v1";

const routes = {
  taxa: `${baseUrl}/taxa`,
  taxaNextTaxonId: `${baseUrl}/taxa/next_taxon_id`,
  normalizeTaxa: "/admin/labwork/normalize_ncbi_taxa",
};

const createUpdateTaxa = (id, body) => {
  let url = `${routes.normalizeTaxa}/${id}/update_create`;
  return put(url, { body });
};

const getNextTaxonId = () => {
  return get(routes.taxaNextTaxonId);
};

export default {
  routes,
  createUpdateTaxa,
  getNextTaxonId,
};
