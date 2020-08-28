 SELECT (array_agg(
            canonical_name || '|' || ncbi_nodes.taxon_id
            ORDER BY asvs_count_la_river DESC NULLS LAST
          ))[0:15] as taxa;


 SELECT "samples_map"."id", "samples_map"."latitude", "samples_map"."longitude", "samples_map"."barcode", "samples_map"."status", "samples_map"."substrate", "samples_map"."location", "samples_map"."collection_date", "samples_map"."taxa_count",
 array_agg(distinct primers.id) as primer_ids,
 array_agg(distinct primers.name) as primer_names


-- ,
-- (select (array_agg(canonical_name || '|' || ncbi_nodes.taxon_id  ))[0:15]
--from ncbi_nodes
--join asvs on asvs.taxon_id = ncbi_nodes.taxon_id
--where  ncbi_nodes.ids @>  '{2189}'
--and asvs_count > 0
----and ncbi_nodes.taxon_id in (select taxon_id from asvs)
--and  sample_id =samples_map.id)

 FROM "samples_map"
 JOIN sample_primers ON samples_map.id = sample_primers.sample_id
JOIN primers ON sample_primers.primer_id = primers.id
WHERE (samples_map.id NOT IN (
  SELECT sample_id
  FROM sample_primers
  JOIN research_projects
    ON research_projects.id = sample_primers.research_project_id
    AND research_projects.published = false
 )
) AND "samples_map"."status" = 'results_completed'
 AND (taxon_ids @> '{2189 }')
  GROUP BY "samples_map"."id", "samples_map"."latitude", "samples_map"."longitude", "samples_map"."barcode", "samples_map"."status", "samples_map"."substrate", "samples_map"."location", "samples_map"."collection_date", "samples_map"."taxa_count"
 ;

 SELECT * FROM(
 SELECT "samples_map"."id", "samples_map"."latitude", "samples_map"."longitude", "samples_map"."barcode", "samples_map"."status", "samples_map"."substrate", "samples_map"."location", "samples_map"."collection_date", "samples_map"."taxa_count",
 array_agg(distinct primers.id) as primer_ids,
 array_agg(distinct primers.name) as primer_names
 FROM "samples_map"
 JOIN sample_primers ON samples_map.id = sample_primers.sample_id
JOIN primers ON sample_primers.primer_id = primers.id
WHERE (samples_map.id NOT IN (
  SELECT sample_id
  FROM sample_primers
  JOIN research_projects
    ON research_projects.id = sample_primers.research_project_id
    AND research_projects.published = false
 )
) AND "samples_map"."status" = 'results_completed'
 AND (taxon_ids @> '{2189 }')
  GROUP BY "samples_map"."id", "samples_map"."latitude", "samples_map"."longitude", "samples_map"."barcode", "samples_map"."status", "samples_map"."substrate", "samples_map"."location", "samples_map"."collection_date", "samples_map"."taxa_count"

 ) table1 JOIN (
 SELECT (array_agg(
  canonical_name || '|' || ncbi_nodes.taxon_id
  ORDER BY asvs_count DESC NULLS LAST
))[0:15] as taxa, samples_map.id
FROM samples_map
JOIN asvs ON asvs.sample_id = samples_map.id
  AND status ='results_completed'
 JOIN ncbi_nodes ON asvs.taxon_id = ncbi_nodes.taxon_id
  AND ncbi_nodes.asvs_count > 0
  AND ncbi_nodes.ids @> ARRAY[2189]::integer[]
GROUP BY samples_map.id
) table2
on table1.id = table2.id;

--------


create materialized view ncbi_nodes2 as
select taxon_id, rank,canonical_name,asvs_count, asvs_count_la_river, iucn_status, ids
from ncbi_nodes
where  taxon_id IN (SELECT taxon_id FROM asvs)
AND (ncbi_nodes.iucn_status IS NULL OR
ncbi_nodes.iucn_status NOT IN
('extinct',
'extinct in the wild',
'critically endangered',
'endangered',
'endangered species',
'associated species')
);



CREATE  INDEX ON ncbi_nodes2 (taxon_id);
CREATE  INDEX ON ncbi_nodes2 (asvs_count);
CREATE  INDEX ON ncbi_nodes2  USING GIN  (ids);

drop materialized view ncbi_nodes2;

-------

SELECT "samples_map"."id", "samples_map"."latitude", "samples_map"."longitude", "samples_map"."barcode", "samples_map"."status", "samples_map"."substrate", "samples_map"."location", "samples_map"."collection_date", "samples_map"."taxa_count",
array_agg(distinct  primers.id) as primer_ids,
array_agg(distinct  primers.name) as primer_names
,
(ARRAY_AGG(
"ncbi_nodes"."canonical_name" || '|' || ncbi_nodes.taxon_id ORDER BY asvs_count DESC NULLS LAST
))[0:15] AS taxa
FROM "samples_map"

JOIN asvs ON samples_map.id = asvs.sample_id
AND "samples_map"."status" = 'results_completed'
JOIN primers ON asvs.primer_id = primers.id
JOIN ncbi_nodes_edna as ncbi_nodes ON ncbi_nodes.taxon_id = asvs.taxon_id
AND ncbi_nodes.asvs_count > 0
and ids @> '{2189}'

WHERE (samples_map.id NOT IN (
SELECT sample_id
FROM sample_primers
JOIN research_projects
ON research_projects.id = sample_primers.research_project_id
AND research_projects.published = false
)
)
GROUP BY "samples_map"."id", "samples_map"."latitude", "samples_map"."longitude", "samples_map"."barcode", "samples_map"."status", "samples_map"."substrate", "samples_map"."location", "samples_map"."collection_date", "samples_map"."taxa_count"

;

-----

-- 2189 eurkayotes

select array_agg(canonical_name || '|' || ncbi_nodes.taxon_id order by asvs_count  desc nulls last)
from ncbi_nodes
where  ncbi_nodes.ids @>  '{2189}'
and asvs_count > 0

limit 10;


select array_agg(canonical_name || '|' || ncbi_nodes.taxon_id order by asvs_count  desc nulls last)
from ncbi_nodes
join asvs on asvs.taxon_id = ncbi_nodes.taxon_id
where  ncbi_nodes.ids @>  '{2189}'
and asvs_count > 0
and  sample_id =1;
order by asvs_count  desc nulls last

;
