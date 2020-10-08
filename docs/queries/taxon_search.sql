
-- optimize taxa_search with prefix and full text search


SELECT ncbi_names.name, ncbi_nodes.taxon_id, canonical_name, rank, common_names,
ncbi_divisions.name as division_name, 0 as asvs_count
FROM ncbi_nodes
JOIN ncbi_divisions
ON ncbi_nodes.cal_division_id = ncbi_divisions.id
JOIN ncbi_names
ON ncbi_names.taxon_id = ncbi_nodes.ncbi_id
AND name_class in ('common name', 'scientific name')
WHERE lower(ncbi_names.name) LIKE 'bir%'
ORDER BY asvs_count DESC NULLS LAST
LIMIT 10;

select * from ncbi_nodes where taxon_id = 705998;
select * from ncbi_names where taxon_id = 705998;

select canonical_name, taxon_id
from ncbi_nodes where lower(common_names) = 'ants';



CREATE INDEX full_text_search_idx ON ncbi_nodes USING gin(( to_tsvector('simple', canonical_name) || to_tsvector('english', coalesce(alt_names, ''))));

select to_tsvector(common_names), * from ncbi_nodes  where cal_division_id = 12 limit 5000;

CREATE INDEX full_text_search_idx ON ncbi_nodes USING GIN ((to_tsvector('simple'::regconfig, canonical_name::text) || to_tsvector('english'::regconfig, COALESCE(alt_names, ''::character varying)::text)) tsvector_ops);

drop index full_text_search_idx;

CREATE INDEX full_text_search_idx ON ncbi_nodes USING GIN ((
to_tsvector('simple'::regconfig, canonical_name::text) ||
to_tsvector('english'::regconfig, common_names::text)
) tsvector_ops);

CREATE INDEX full_text_search_idx ON ncbi_nodes USING GIN ((
setweight(to_tsvector('simple'::regconfig, canonical_name::text), 'A') ||
setweight(to_tsvector('english'::regconfig, common_names::text), 'B')
) tsvector_ops);

CREATE INDEX foo on ncbi_nodes USING btree (lower ("common_names"));


(SELECT taxon_id, canonical_name, rank, common_names, division_name,asvs_count
FROM (
SELECT ncbi_nodes.taxon_id, ncbi_nodes.canonical_name, ncbi_nodes.rank,
ncbi_divisions.name as division_name, asvs_count,
common_names,
to_tsvector('simple', canonical_name) ||
to_tsvector('english', common_names) AS doc
FROM ncbi_nodes
JOIN ncbi_divisions
ON ncbi_nodes.cal_division_id = ncbi_divisions.id
) AS search
WHERE (search.doc @@ plainto_tsquery('simple', 'ant')
OR search.doc @@ plainto_tsquery('english', 'ant'))
ORDER BY asvs_count DESC NULLS LAST
limit 10)

UNION

(SELECT taxon_id, canonical_name, rank, common_names, ncbi_divisions.name as division_name,
asvs_count
FROM ncbi_nodes
JOIN ncbi_divisions
ON ncbi_nodes.cal_division_id = ncbi_divisions.id
WHERE lower(canonical_name) LIKE 'ant%'
ORDER BY asvs_count DESC NULLS LAST
limit 5
)
ORDER BY asvs_count DESC NULLS LAST;

SELECT taxon_id, canonical_name, rank, common_names, division_name, asvs_count
FROM (
SELECT ncbi_nodes.taxon_id, ncbi_nodes.canonical_name, ncbi_nodes.rank,
ncbi_divisions.name as division_name,
common_names, asvs_count,
(to_tsvector('simple', canonical_name) ||
to_tsvector('english', common_names )) AS doc
FROM ncbi_nodes
JOIN ncbi_divisions
ON ncbi_nodes.cal_division_id = ncbi_divisions.id
) AS search
WHERE search.doc @@ plainto_tsquery('simple', 'birds')
OR search.doc @@ plainto_tsquery('english', 'birds')
order by asvs_count desc nulls last;

ORDER BY ts_rank(search.doc, plainto_tsquery('simple', 'birds')) DESC;
limit 15;

SELECT taxon_id, canonical_name, rank, common_names, division_name
FROM (
SELECT ncbi_nodes.taxon_id, ncbi_nodes.canonical_name, ncbi_nodes.rank,
ncbi_divisions.name as division_name,
common_names,
to_tsvector('simple', canonical_name) ||
to_tsvector('english', common_names) AS doc
FROM ncbi_nodes
JOIN ncbi_divisions
ON ncbi_nodes.cal_division_id = ncbi_divisions.id
GROUP BY ncbi_nodes.taxon_id, ncbi_divisions.name
ORDER BY asvs_count DESC NULLS LAST
) AS search
WHERE search.doc @@ plainto_tsquery('simple', 'Aves')
OR search.doc @@ plainto_tsquery('english', 'Aves')
LIMIT 15;

SELECT taxon_id, canonical_name, rank, common_names, division_name,
to_tsvector('simple', canonical_name), to_tsvector('english', common_names), asvs_count
FROM (
SELECT ncbi_nodes.taxon_id, ncbi_nodes.canonical_name, ncbi_nodes.rank,
ncbi_divisions.name as division_name,
common_names, asvs_count,
setweight(to_tsvector('simple', canonical_name), 'A') ||
setweight(to_tsvector('english', common_names), 'B') AS doc
FROM ncbi_nodes
JOIN ncbi_divisions
ON ncbi_nodes.cal_division_id = ncbi_divisions.id
) AS search
WHERE (search.doc @@ plainto_tsquery('simple', 'fis')
OR search.doc @@ plainto_tsquery('english', 'fis'))
or lower(canonical_name) like 'fis%'
order by asvs_count DESC NULLS LAST
limit 5;
or lower(canonical_name) = 'fish';
ORDER BY ts_rank(search.doc, plainto_tsquery('english', 'birds')) DESC,
ts_rank(search.doc, plainto_tsquery('simple', ' birds')) DESC;
limit 15;

-----------

SELECT ncbi_nodes.taxon_id, ncbi_nodes.canonical_name, ncbi_nodes.rank,
asvs_count, common_names,  to_tsvector('simple', canonical_name),
to_tsvector('english', coalesce(common_names, ''))
FROM ncbi_nodes
where  lower(canonical_name) = lower('scopalina ruetzleri')
and (to_tsvector('simple', canonical_name) ||
to_tsvector('english', coalesce(common_names, '')))
@@ plainto_tsquery('simple', 'Scopalina ruetzleri');



select * from ncbi_nodes where lower(canonical_name) = lower('Scopalina ruetzleri');


CREATE INDEX full_text_search_idx ON ncbi_nodes
USING gin(( to_tsvector('simple', canonical_name) ||
to_tsvector('english', coalesce(common_names, ''))));

drop index full_text_search_idx;
