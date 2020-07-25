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

SELECT
"sum.taxonomy",
COALESCE("K0297-LB-S1", 0) as "K0297-LB-S1",
COALESCE("K0298-LA-S1", 0) as "K0298-LA-S1",
COALESCE("K0298-LC-S2", 0) as "K0298-LC-S2",
COALESCE("K0299-LA-S2", 0) as "K0299-LA-S2",
COALESCE("K0299-LB-S1", 0) as "K0299-LB-S1",
COALESCE("K0299-LC-S1", 0) as "K0299-LC-S1",
COALESCE("K0299-LC-S2", 0) as "K0299-LC-S2",
COALESCE("K0300-LB-S1", 0) as "K0300-LB-S1",
COALESCE("K0300-LB-S2", 0) as "K0300-LB-S2",
COALESCE("K0300-LC-S1", 0) as "K0300-LC-S1",
COALESCE("K0301-LB-S1", 0) as "K0301-LB-S1",
COALESCE("K0302-LB-S2", 0) as "K0302-LB-S2",
COALESCE("K0303-LA-S1", 0) as "K0303-LA-S1",
COALESCE("K0303-LB-S2", 0) as "K0303-LB-S2",
COALESCE("K0305-LB-S2", 0) as "K0305-LB-S2",
COALESCE("K0316-LA-S2", 0) as "K0316-LA-S2",
COALESCE("K0316-LB-S1", 0) as "K0316-LB-S1",
COALESCE("K0319-LA-S2", 0) as "K0319-LA-S2",
COALESCE("K0319-LC-S2", 0) as "K0319-LC-S2",
COALESCE("K0321-LC-S1", 0) as "K0321-LC-S1",
COALESCE("K0333-LA-S1", 0) as "K0333-LA-S1",
COALESCE("K0333-LB-S1", 0) as "K0333-LB-S1",
COALESCE("K0333-LC-S2", 0) as "K0333-LC-S2",
COALESCE("K0334-LA-S1", 0) as "K0334-LA-S1",
COALESCE("K0334-LA-S2", 0) as "K0334-LA-S2",
COALESCE("K0334-LB-S2", 0) as "K0334-LB-S2",
COALESCE("K0345-LA-S2", 0) as "K0345-LA-S2",
COALESCE("K0345-LC-S1", 0) as "K0345-LC-S1",
COALESCE("K0350-LA-S1", 0) as "K0350-LA-S1",
COALESCE("K0350-LB-S1", 0) as "K0350-LB-S1",
COALESCE("K0350-LB-S2", 0) as "K0350-LB-S2",
COALESCE("K0350-LC-S1", 0) as "K0350-LC-S1",
COALESCE("K0352-LA-S2", 0) as "K0352-LA-S2",
COALESCE("K0352-LB-S2", 0) as "K0352-LB-S2",
COALESCE("K0352-LC-S1", 0) as "K0352-LC-S1",
COALESCE("K0352-LC-S2", 0) as "K0352-LC-S2"
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


-------------


--- fixing  aggregate 1000 samples tables

select count(*), primers.name, barcode, primer_id, sample_id
 from asvs
 join primers on asvs.primer_id = primers.id
 join samples on asvs.sample_id = samples.id
 group by primers.name, barcode , primer_id, sample_id
 order by name, barcode;



 -- M3C1 has taxon_id listed twice

select
COALESCE(ncbi_nodes.hierarchy_names ->> 'superkingdom', '') || ';' ||
COALESCE(ncbi_nodes.hierarchy_names ->> 'phylum', '') || ';' ||
COALESCE(ncbi_nodes.hierarchy_names ->> 'class', '') || ';' ||
COALESCE(ncbi_nodes.hierarchy_names ->> 'order', '') || ';' ||
COALESCE(ncbi_nodes.hierarchy_names ->> 'family', '') || ';' ||
COALESCE(ncbi_nodes.hierarchy_names ->> 'genus', '') || ';' ||
COALESCE(ncbi_nodes.hierarchy_names ->> 'species', '')  ,
samples.barcode, asvs.count
FROM asvs
JOIN samples ON asvs.sample_id = samples.id
JOIN ncbi_nodes ON ncbi_nodes.taxon_id = asvs.taxon_id
WHERE primer_id = 1
and sample_id = 9117
;

 -- M3C1 has taxon_id listed twice whoch screws up cross joins
SELECT
"taxonomy", "M3C1"
FROM CROSSTAB(
'SELECT
COALESCE(ncbi_nodes.hierarchy_names ->> ''superkingdom'', '''') || '';'' ||
COALESCE(ncbi_nodes.hierarchy_names ->> ''phylum'', '''') || '';'' ||
COALESCE(ncbi_nodes.hierarchy_names ->> ''class'', '''') || '';'' ||
COALESCE(ncbi_nodes.hierarchy_names ->> ''order'', '''') || '';'' ||
COALESCE(ncbi_nodes.hierarchy_names ->> ''family'', '''') || '';'' ||
COALESCE(ncbi_nodes.hierarchy_names ->> ''genus'', '''') || '';'' ||
COALESCE(ncbi_nodes.hierarchy_names ->> ''species'', '''')|| ''<>''||asvs.id,
samples.barcode, asvs.count
FROM asvs
JOIN samples ON asvs.sample_id = samples.id
JOIN ncbi_nodes ON ncbi_nodes.taxon_id = asvs.taxon_id
WHERE primer_id = 1
 ORDER BY 1,2'
) AS foo (
"taxonomy" text,
"M3C1" int
);

-- create new asv table that sums the  read counts
select taxon_id,
sample_id, primer_id, research_project_id, sum(asvs.count) as sum
FROM asvs
WHERE primer_id = 1
and sample_id = 9117
group by taxon_id, sample_id, primer_id, research_project_id
;


