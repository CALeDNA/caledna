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
