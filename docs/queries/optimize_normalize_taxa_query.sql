CREATE TABLE result_taxa_v11 AS
TABLE result_taxa;

TRUNCATE  result_taxa restart identity;
ALTER SEQUENCE result_taxa_id_seq RESTART WITH 1;


INSERT INTO result_taxa
SELECT * FROM result_taxa_v10;


-- v1 - v9 has desert, pillar point, la river

-- find matching taxa for the taxonomy string

-- v1 strict match all ranks

-- 13351
select count(*) from result_taxa;
-- 11778
select count(*) from result_taxa where normalized = true;
-- 1573
select count(*) from result_taxa where normalized = false;

-- 12925
select count(distinct(clean_taxonomy_string)) from result_taxa;
-- 11403
select count(distinct(clean_taxonomy_string)) from result_taxa where normalized = true;
-- 1522
select count(distinct(clean_taxonomy_string)) from result_taxa where normalized = false;


-- v2 match lowest then go up to next rank

-- 13351
select count(*) from result_taxa;
--  12933
select count(*) from result_taxa where normalized = true;
-- 418
select count(*) from result_taxa where normalized = false;

-- 12925
select count(distinct(clean_taxonomy_string)) from result_taxa;
-- 12523
select count(distinct(clean_taxonomy_string)) from result_taxa where normalized = true;
-- 402
select count(distinct(clean_taxonomy_string)) from result_taxa where normalized = false;

-- v3 match superkingdon/phylum and lowest or superkingdom/phylum, family, genus

-- 13351
select count(*) from result_taxa;
-- 12567
select count(*) from result_taxa where normalized = true;
-- 787
select count(*) from result_taxa where normalized = false;

-- 12925
select count(distinct(clean_taxonomy_string)) from result_taxa;
-- 12159
select count(distinct(clean_taxonomy_string)) from result_taxa where normalized = true;
-- 766
select count(distinct(clean_taxonomy_string)) from result_taxa where normalized = false;


-- v4 match superkingdon/phylum and lowest or superkingdom/phylum, family, genus

-- 13351
select count(*) from result_taxa;
-- 12602
select count(*) from result_taxa where normalized = true;
-- 749
select count(*) from result_taxa where normalized = false;

-- 12925
select count(distinct(clean_taxonomy_string)) from result_taxa;
-- 12195
select count(distinct(clean_taxonomy_string)) from result_taxa where normalized = true;
-- 730
select count(distinct(clean_taxonomy_string)) from result_taxa where normalized = false;

-- v5 match lowest then go up to next rank, strings with quotes, synonmymns

-- 13354
select count(*) from result_taxa;
--  13252
select count(*) from result_taxa where normalized = true;
-- 102
select count(*) from result_taxa where normalized = false;

-- 12925
select count(distinct(clean_taxonomy_string)) from result_taxa;
-- 12825
select count(distinct(clean_taxonomy_string)) from result_taxa where normalized = true;
-- 100
select count(distinct(clean_taxonomy_string)) from result_taxa where normalized = false;


-- v6 match highest and lowest, strings with quotes, synonmymns; match rank on canonical names

-- 12925
select count(distinct(clean_taxonomy_string)) from result_taxa;
-- 12447
select count(distinct(clean_taxonomy_string)) from result_taxa where normalized = true;
-- 478
select count(distinct(clean_taxonomy_string)) from result_taxa where normalized = false;

-- v7 match highest and lowest, strings with quotes, synonmymns; don't match rank on canonical names

-- 12925
select count(distinct(clean_taxonomy_string)) from result_taxa;
-- 12442
select count(distinct(clean_taxonomy_string)) from result_taxa where normalized = true;
-- 483
select count(distinct(clean_taxonomy_string)) from result_taxa where normalized = false;

-- v8 match highest and lowest, strings with quotes, synonmymns;
-- don’t add phylum if superkingdom exists
-- do match rank on canonical names

-- 12925
select count((clean_taxonomy_string)) from result_taxa;
-- 12757
select count( (clean_taxonomy_string)) from result_taxa where normalized = true;
-- 168; 62 genus
select count( (clean_taxonomy_string)) from result_taxa where normalized = false;
select * from result_taxa where normalized = false and taxon_rank = 'genus';


-- v9 match highest and lowest, strings with quotes, synonmymns;
-- add phylum for genus

-- 12925
select count(clean_taxonomy_string) from result_taxa;
-- 12814
select count( clean_taxonomy_string) from result_taxa where normalized = true;
-- 111; 49 genus
select count( clean_taxonomy_string) from result_taxa where normalized = false;
select * from result_taxa where normalized = false and taxon_rank = 'genus';


----

---
-- v9b - bold, 5 projects

-- 3 projects
-- 12925
select count(clean_taxonomy_string) from result_taxa;
-- 12808
select count( clean_taxonomy_string) from result_taxa where normalized = true;
-- 117; 49 genus
select count( clean_taxonomy_string) from result_taxa where normalized = false;
select count(*) from result_taxa where normalized = false and taxon_rank = 'genus';

-- 5 projects
-- 31381
select count(clean_taxonomy_string) from result_taxa;
-- 30535
select count( clean_taxonomy_string) from result_taxa where normalized = true;
-- 846; 131 genus
select count( clean_taxonomy_string) from result_taxa where normalized = false;
select count(*) from result_taxa where normalized = false and taxon_rank = 'genus';

----------

-- v10; recursive low to high
-- 3 projects
-- 12925
select count(clean_taxonomy_string) from result_taxa;
-- 12853
select count( clean_taxonomy_string) from result_taxa where normalized = true;
-- 72; 19 genus
select count( clean_taxonomy_string) from result_taxa where normalized = false;
select count(*) from result_taxa where normalized = false and taxon_rank = 'genus';

-- 5 projects
-- 31381
select count(clean_taxonomy_string) from result_taxa;
-- 31197
select count( clean_taxonomy_string) from result_taxa where normalized = true;
-- 184; 39 genus
select count( clean_taxonomy_string) from result_taxa where normalized = false;
select count(*) from result_taxa where normalized = false and taxon_rank = 'genus';

----------

-- v11; recursive low to high, rank match
-- 3 projects
-- 12925
select count(clean_taxonomy_string) from result_taxa;
-- 12862
select count( clean_taxonomy_string) from result_taxa where normalized = true;
-- 63; 11 genus
select count( clean_taxonomy_string) from result_taxa where normalized = false;
select count(*) from result_taxa where normalized = false and taxon_rank = 'genus';

-- 5 projects
-- 31381
select count(clean_taxonomy_string) from result_taxa;
-- 31221
select count( clean_taxonomy_string) from result_taxa where normalized = true;
-- 160; 19 genus
select count( clean_taxonomy_string) from result_taxa where normalized = false;
select count(*) from result_taxa where normalized = false and taxon_rank = 'genus';

----------

-- v12; recursive low to high for all finds
-- 3 projects

-- 12925
select count(clean_taxonomy_string) from result_taxa;
-- 12862
select count( clean_taxonomy_string) from result_taxa where normalized = true;
-- 63; 15 genus
select count( clean_taxonomy_string) from result_taxa where normalized = false;
select count(*) from result_taxa where normalized = false and taxon_rank = 'genus';

-- 5 projects
-- 23064
select count(clean_taxonomy_string) from result_taxa;
-- 22963
select count( clean_taxonomy_string) from result_taxa where normalized = true;
-- 101; 17 genus
select count( clean_taxonomy_string) from result_taxa where normalized = false;
select count(*) from result_taxa where normalized = false and taxon_rank = 'genus';


-----------------------------

-- use superkingdom
-- 2 species
-- 880 genus
-- 6 family
-- 0 order
-- 0 class
-- 0 phylum


select count(*), hierarchy_names ->> 'superkingdom',  hierarchy_names ->> 'genus'
from ncbi_nodes
where rank = 'genus'
group by  hierarchy_names ->> 'superkingdom',   hierarchy_names ->> 'genus'
having count(*) > 1;

-- use phylum
-- 1 species
-- 24 genus
-- 0 family
-- 0 order
-- 0 class
-- 0 phylum
select count(*), hierarchy_names ->> 'phylum',  hierarchy_names ->> 'species'
from ncbi_nodes
where rank = 'species'
group by  hierarchy_names ->> 'phylum',   hierarchy_names ->> 'species'
having count(*) > 1;

-- no phylum 77370, not viruses
select hierarchy_names ->> 'superkingdom', hierarchy_names from ncbi_nodes
 where not hierarchy_names ? 'phylum'
 and division_id in (0, 1, 2 , 3 , 4, 5, 6 , 10) ;

-- no superkingdom 374, not viruses
select hierarchy_names ->> 'superkingdom', hierarchy_names from ncbi_nodes
 where not hierarchy_names ? 'superkingdom'
 and division_id in (0, 1, 2 , 3 , 4, 5, 6 , 10) ;

--------

-- look at the various ncbi 2020 and 2017 tables for result taxa that did not match

select
result_taxa.id,  result_taxa.canonical_name, result_taxa.taxon_rank,

ncbi_names_2017.taxon_id as taxon_id_17_names, ncbi_names_2017.name, ncbi_names_2017.name_class, ncbi_names_2017.unique_name,

nc_names.canonical_name, nc_names.ncbi_id,


ncbi_names.taxon_id as taxon_id_20_names, ncbi_names.name, ncbi_names.name_class, ncbi_names.unique_name,


ncbi_merged_taxa.old_taxon_id as old_taxon_id_20_merged, ncbi_merged_taxa.taxon_id as taxon_id_20_merged ,

nc_merged.canonical_name as canonical_name_20_merged


from result_taxa

left join external.ncbi_names_2017 on ncbi_names_2017.name = result_taxa.canonical_name

left join ncbi_nodes as nc_names on ncbi_names_2017.taxon_id = nc_names.ncbi_id



left join ncbi_names on ncbi_names.name = result_taxa.canonical_name

left join external.ncbi_merged_taxa on ncbi_merged_taxa.old_taxon_id = ncbi_names.taxon_id

left join ncbi_nodes as nc_merged on ncbi_merged_taxa.taxon_id = nc_merged.ncbi_id


where normalized = false;
