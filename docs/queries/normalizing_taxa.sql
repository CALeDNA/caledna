
-- begin - look for taxon info from 2017 taxa, 2020 deleted, 2020 merged

SELECT canonical_name, external.ncbi_names_2017.name, rank, name_class,
external.ncbi_nodes_2017.short_taxonomy_string,
ncbi_id, bold_id,
external.ncbi_merged_taxa.old_taxon_id as merged_old_taxon_id, external.ncbi_merged_taxa.taxon_id as merged_taxon_id,
external.ncbi_deleted_taxa.taxon_id as deleted_taxon_id
from external.ncbi_nodes_2017
 join external.ncbi_names_2017 on external.ncbi_names_2017.taxon_id = external.ncbi_nodes_2017.ncbi_id
left join external.ncbi_merged_taxa on external.ncbi_merged_taxa.old_taxon_id = external.ncbi_nodes_2017.ncbi_id
left join external.ncbi_deleted_taxa on external.ncbi_deleted_taxa.taxon_id = external.ncbi_nodes_2017.ncbi_id
where lower(canonical_name) = lower('Ulocladium');
or lower(external.ncbi_names_2017.name) = lower('Psathyrella aff. gracilis')
;

select rank, ncbi_id, canonical_name
from external.ncbi_nodes_2017
where ncbi_id = 1955842;

-- end - look for taxon info from 2017 taxa, 2020 deleted, 2020 merged
