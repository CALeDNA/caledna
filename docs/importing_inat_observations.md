import csv

```bash
bin/rake inat_obs:create_la_river_inat_taxa[file path]

bin/rake inat_obs:create_la_river_inat_observations[file path]
```

==

create higher taxa in inat_taxa

```bash
bin/rake inat_taxa:create_higher_ranks
```

==

add inat data to inat_taxa using inat api

```bash
bin/rake inat_taxa:update_existing_taxa
```

check if every inat_taxa is in external_resources

```sql
select *
from external.inat_taxa as inat_taxa
left join external_resources
on external_resources.inaturalist_id = inat_taxa.taxon_id
where inaturalist_id is null;

SELECT canonical_name, taxon_id
FROM external.inat_taxa
left join external_resources
on external_resources.inaturalist_id = inat_taxa.taxon_id
WHERE external_resources.inaturalist_id IS NULL
GROUP BY canonical_name, taxon_id;
```

add external resources for inat taxa

```bash
bin/rake external_resources:create_resources_for_inat_taxa
```

==
r script
add ncbi_id to external_resources for inat taxa

status rank division scientificname commonname uid genus species subsp
1 active order vertebrates Crocodylia alligators and others 1294634
2 active superorder lizards Lepidosauria lepidosaurs 8504
3 active order turtles Testudines turtles 8459

==
update inat_id for ncbi taxa where canonical_name matches

```bash
bin/rake external_resources:update_inat_id_for_ncbi_taxa
```

==

find external_resources where ncbi taxa and inat taxa have different
canonical names or kingdoms

```sql
select inat_taxa.rank as inat_rank, ncbi_nodes.rank as ncbi_rank,
inat_taxa.taxon_id as inat_taxon_id, ncbi_nodes.taxon_id as ncbi_taxon_id,
inat_taxa.kingdom as inat_kingdom, ncbi_divisions.name as ncbi_kingdom,
inat_taxa.canonical_name as inat_name,
ncbi_nodes.canonical_name as ncbi_name,
external_resources.created_at, source
from external_resources
join external.inat_taxa as inat_taxa
on external_resources.inaturalist_id = inat_taxa.taxon_id
join ncbi_nodes on external_resources.ncbi_id = ncbi_nodes.taxon_id
join ncbi_divisions on ncbi_divisions.id = ncbi_nodes.cal_division_id
where inat_taxa.canonical_name != ncbi_nodes.canonical_name
or inat_taxa.kingdom != ncbi_divisions.name
order by external_resources.created_at desc;
```

manually update ncbi_id or inat_id in external_resources

```bash
bin/rake external_resources:manually_update_inat_taxa
```

check every inat taxa that doesn;t have ncbi_id

```sql
select inat_taxa.*
from external_resources
join external.inat_taxa as inat_taxa on inat_taxa.taxon_id = external_resources.inaturalist_id
where external_resources.ncbi_id is null
order by rank;
```

manually update ncbi_id or inat_id in external_resources

```bash
bin/rake external_resources:manually_update_inat_taxa
```

==
misc

reimport external_resources table from csv

```
\copy external_resources from 'external_resources.csv' csv header;
```

reset id after csv import

```sql
ALTER SEQUENCE external_resources_id_seq1 RESTART WITH 451464;
```
