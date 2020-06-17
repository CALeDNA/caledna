$$SELECT unnest('{
K0297-LB-S1,
K0298-LA-S1,
K0298-LC-S2,
K0299-LA-S2,
K0299-LB-S1,
K0299-LC-S1,
K0299-LC-S2,
K0300-LB-S1,
K0300-LB-S2,
K0300-LC-S1,
K0301-LB-S1,
K0302-LB-S2,
K0303-LA-S1,
K0303-LB-S2,
K0305-LB-S2,
K0316-LA-S2,
K0316-LB-S1,
K0319-LA-S2,
K0319-LC-S2,
K0321-LC-S1,
K0333-LA-S1,
K0333-LB-S1,
K0333-LC-S2,
K0334-LA-S1,
K0334-LA-S2,
K0334-LB-S2,
K0345-LA-S2,
K0345-LC-S1,
K0350-LA-S1,
K0350-LB-S1,
K0350-LB-S2,
K0350-LC-S1,
K0352-LA-S2,
K0352-LB-S2,
K0352-LC-S1,
K0352-LC-S2
}'::text[])$$



-------------------

SELECT *
FROM crosstab(
'SELECT
COALESCE(ncbi_nodes.hierarchy_names ->> ''superkingdom'', '''') || '';'' ||
COALESCE(ncbi_nodes.hierarchy_names ->> ''phylum'', '''') || '';'' ||
COALESCE(ncbi_nodes.hierarchy_names ->> ''class'', '''') || '';'' ||
COALESCE(ncbi_nodes.hierarchy_names ->> ''order'', '''') || '';'' ||
COALESCE(ncbi_nodes.hierarchy_names ->> ''family'', '''') || '';'' ||
COALESCE(ncbi_nodes.hierarchy_names ->> ''genus'', '''') || '';'' ||
COALESCE(ncbi_nodes.hierarchy_names ->> ''species'', ''''),
samples.barcode,
asvs.count

FROM asvs
join samples on asvs.sample_id = samples.id
join ncbi_nodes on ncbi_nodes.taxon_id = asvs.taxon_id
where primer_id = 7
order by 1,2
' ,
'SELECT distinct(samples.barcode)
FROM asvs
join samples on asvs.sample_id = samples.id
where primer_id = 7
order by 1'
) AS foo (
"sum.taxonomy" text,
"ncbi_id" int,
"K0297-LB-S1" int,
"K0298-LA-S1" int,
"K0298-LC-S2" int,
"K0299-LA-S2" int,
"K0299-LB-S1" int,
"K0299-LC-S1" int,
"K0299-LC-S2" int,
"K0300-LB-S1" int,
"K0300-LB-S2" int,
"K0300-LC-S1" int,
"K0301-LB-S1" int,
"K0302-LB-S2" int,
"K0303-LA-S1" int,
"K0303-LB-S2" int,
"K0305-LB-S2" int,
"K0316-LA-S2" int,
"K0316-LB-S1" int,
"K0319-LA-S2" int,
"K0319-LC-S2" int,
"K0321-LC-S1" int,
"K0333-LA-S1" int,
"K0333-LB-S1" int,
"K0333-LC-S2" int,
"K0334-LA-S1" int,
"K0334-LA-S2" int,
"K0334-LB-S2" int,
"K0345-LA-S2" int,
"K0345-LC-S1" int,
"K0350-LA-S1" int,
"K0350-LB-S1" int,
"K0350-LB-S2" int,
"K0350-LC-S1" int,
"K0352-LA-S2" int,
"K0352-LB-S2" int,
"K0352-LC-S1" int,
"K0352-LC-S2" int
);
