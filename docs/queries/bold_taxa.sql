 -- begin - add 2017 bold_id to existing ncbi_nodes

SELECT old.canonical_name, old.ncbi_id AS old_ncbi,
  old.bold_id AS old_bold, ncbi_nodes.ncbi_id , ncbi_nodes.bold_id
FROM "external"."ncbi_nodes_2017" AS old
LEFT JOIN ncbi_nodes ON LOWER(ncbi_nodes.canonical_name) =
  LOWER(old.canonical_name)
WHERE old.bold_id IS NOT NULL
AND ncbi_nodes.ncbi_id IS NOT NULL;

UPDATE ncbi_nodes
SET bold_id = subquery.old_bold
FROM
  (SELECT old.canonical_name, old.ncbi_id AS old_ncbi,
    old.bold_id AS old_bold, ncbi_nodes.ncbi_id, ncbi_nodes.bold_id
	FROM "external"."ncbi_nodes_2017" AS old
  LEFT JOIN ncbi_nodes ON LOWER(ncbi_nodes.canonical_name) =
    LOWER(old.canonical_name)
	WHERE old.bold_id IS NOT NULL
  AND ncbi_nodes.ncbi_id IS NOT NULL
  ) AS subquery
WHERE ncbi_nodes.ncbi_id = subquery.ncbi_id;

 -- end - add 2017 bold_id to existing ncbi_nodes

-- begin - export ncbi_nodes with only  bold_id

  SELECT  old.*
  FROM "external"."ncbi_nodes_2017" as old
  left join ncbi_nodes as new on lower(new.canonical_name) = lower(old.canonical_name)
  WHERE old.bold_id is not null
  and  new.ncbi_id is  null;

  update ncbi_nodes set source = 'BOLD' where ncbi_id is  null and bold_id is not null;

  -- end - export ncbi_nodes with only  bold_id




 -- begin reset bold result_taxa
-- 49 BOLD
update result_taxa
set  normalized = false
where id in (
select id from result_taxa
join ncbi_nodes on ncbi_nodes.taxon_id = result_taxa.taxon_id
where   ( result_taxa.bold_id IS NOT NULL)
AND ( result_taxa.ncbi_id IS NULL)
and ncbi_nodes.full_taxonomy_string is null
);

update result_taxa
set normalized = false
where (result_taxa.bold_id IS NOT NULL)
AND (result_taxa.ncbi_id IS NULL);


 -- end reset bold result_taxa



--------------
-- begin reset bold ncbi_nodes

-- 53 BOLD
select * from ncbi_nodes
where   ( bold_id IS NOT NULL)
AND ( ncbi_id IS NULL);

update ncbi_nodes
set parent_taxon_id = NULL, division_id = NULL, cal_division_id = NULL, full_taxonomy_string = NULL,
ids = '{}', ranks = '{}', names = '{}',
 hierarchy_names = '{}',  hierarchy = '{}'
where   ( bold_id IS NOT NULL)
AND ( ncbi_id IS NULL);

-- end reset bold ncbi_nodes
--------------



--------------

-- begin find parent ncbi node genus for bold species
-- 40
SELECT result_taxa.taxon_id,   result_taxa.taxon_rank, result_taxa.canonical_name,
parent.ncbi_id,  parent.rank, parent.canonical_name, parent.source
 FROM result_taxa
 join ncbi_nodes as parent on  lower(parent.canonical_name) = lower(result_taxa.hierarchy ->> 'genus')
  WHERE (result_taxa.bold_id IS NOT NULL)
  AND (result_taxa.ncbi_id IS NULL)
  and result_taxa.taxon_rank = 'species'

  and parent.rank = 'genus'
  and parent.source = 'NCBI'
  and result_taxa.hierarchy ->> 'family' = parent.hierarchy_names ->> 'family'
  ;


SELECT result_taxa.taxon_id,  result_taxa.taxon_rank, result_taxa.canonical_name,
parent.ncbi_id as current_parent_taxon_id
 FROM result_taxa
 join ncbi_nodes as parent on  lower(parent.canonical_name) = lower(result_taxa.hierarchy ->> 'genus')
  WHERE (result_taxa.bold_id IS NOT NULL)
  AND (result_taxa.ncbi_id IS NULL)
  and result_taxa.taxon_rank = 'species'

  and parent.rank = 'genus'
  and parent.source = 'NCBI'
  and result_taxa.hierarchy ->> 'family' = parent.hierarchy_names ->> 'family'
  ;

  -- end find parent ncbi node genus for bold species
