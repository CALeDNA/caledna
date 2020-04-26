
CREATE INDEX name_autocomplete_idx ON ncbi_nodes USING btree (lower ("canonical_name") text_pattern_ops);
CREATE INDEX replace_quotes_idx ON ncbi_nodes USING btree (lower((REPLACE(canonical_name, '''', ''))::text));
CREATE INDEX idx_taxa_search ON ncbi_nodes USING gin(( to_tsvector('simple', canonical_name) || to_tsvector('english', coalesce(alt_names, ''))));
CREATE INDEX index_ncbi_nodes_on_hierarchy_names ON ncbi_nodes USING GIN (hierarchy_names jsonb_ops);
CREATE INDEX idx_btree_hobbies ON ncbi_nodes USING BTREE ((hierarchy_names->>'genus'));
CREATE INDEX index_ncbi_nodes_on_hierarchy_names ON ncbi_nodes USING GIN (ids);

drop index index_ncbi_nodes_on_hierarchy_names;

-- matches the word canis anywhere in name
SELECT taxon_id, canonical_name
FROM (
  SELECT ncbi_nodes.taxon_id, ncbi_nodes.canonical_name,
  to_tsvector('simple', canonical_name) ||
  to_tsvector('english', coalesce(alt_names, '')) AS doc
  FROM ncbi_nodes
) AS search
WHERE search.doc @@ plainto_tsquery('simple', 'canis')
OR search.doc @@ plainto_tsquery('english', 'canis');


-- matches 'Acacia melanoxylon' phytoplasma
select * from ncbi_nodes where(lower(REPLACE(canonical_name, '''', '')) = 'acacia melanoxylon phytoplasma');
-- does not match expression vector "pure" split-t7p564
select * from ncbi_nodes where(lower(REPLACE(canonical_name, '''', '')) = 'expression vector pure split-t7p564');
-- matches anything that starts with canis
select * from ncbi_nodes where lower("canonical_name") LIKE 'canis%';
-- matches exactly canis
select * from ncbi_nodes where lower("canonical_name") = 'canis';

-- 25 s no index
-- 22 s GIN (hierarchy_names jsonb_ops)
-- 2 ms BTREE ((hierarchy_names->>'genus'))
select * from ncbi_nodes where hierarchy_names ->> 'genus' = 'Isotealia';
-- 40 ms gin hierarchy_names
select * from ncbi_nodes where hierarchy_names ->> 'genus' = 'Heterothrix'  and rank = 'genus';
-- 3 ms with gin hierarchy_names
select * from ncbi_nodes where hierarchy_names  @> '{"genus": "Methylobacterium"}' ;

-- 100 ms with gin hierarchy_names
select * from ncbi_nodes where not hierarchy_names ? 'genus' limit 5;

-- g Heterothrix Isotealia Methylobacterium Melittangium Myxococcus
-- p Rotifera Bryozoa Cercozoa Phoronida Proteobacteria
select canonical_name from ncbi_nodes  where rank = 'phylum' limit 20;

