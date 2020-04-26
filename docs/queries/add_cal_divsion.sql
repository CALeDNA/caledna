select  combine_taxa.kingdom, combine_taxa.phylum, combine_taxa.id,
ncbi_nodes.canonical_name ,
 ncbi_nodes.hierarchy_names ->> 'superkingdom',
array_agg(ncbi_nodes.taxon_id ), array_agg(ncbi_nodes.rank ), array_agg(ncbi_nodes.full_taxonomy_string),
 count(*)
from pillar_point.combine_taxa
 join ncbi_nodes on lower(ncbi_nodes.canonical_name) = lower(combine_taxa.phylum)
where combine_taxa.source = 'paper'
and combine_taxa.taxon_rank = 'phylum'
and (combine_taxa.kingdom != 'Bacteria' and combine_taxa.kingdom != 'Archaea' )
group by  combine_taxa.kingdom, combine_taxa.phylum, combine_taxa.id,
ncbi_nodes.canonical_name ,
ncbi_nodes.hierarchy_names ->> 'superkingdom'
order by  combine_taxa.kingdom;

-- protozoa: Eukaryota|Amoebozoa rp, Eukaryota|Metamonada rp,Eukaryota|Discoba ,
-- Eukaryota|Breviatea rc,
-- Eukaryota|Opisthokonta|Aphelida|Aphelidea rc, Eukaryota|Opisthokonta|Filasterea rc,
-- Eukaryota|Opisthokonta|Ichthyosporea rc, Eukaryota|CRuMs|Rigifilida ro
-- Eukaryota|Opisthokonta|Choanoflagellata


-- Eukaryota|Discoba|Euglenozoa rp, Eukaryota|Discoba|Heterolobosea rc

-----------------------

-- Chromista: Eukaryota|Sar|Rhizaria , Eukaryota|Sar|Stramenopiles,
-- Eukaryota|Sar|Alveolata, Eukaryota|Haptista , Eukaryota|Cryptophyceae rc,
-- Eukaryota|Eukaryota incertae sedis|Picozoa|Picomonadea rc,
-- Eukaryota|Opisthokonta|Rotosphaerida ro, Eukaryota|Eukaryota incertae sedis|Telonemida ro


-- Eukaryota|Haptista|Haptophyta rp

-----------------------


-- plantae: Eukaryota|Viridiplantae n-, Eukaryota|Rhodophyta rp
-- Fungi: Eukaryota|Opisthokonta|Fungi n-
-- animale:  Eukaryota|Opisthokonta|Metazoa n-
-- Archaea: cellular organisms|Archaea
-- bacteria: cellular organisms|Bacteria
