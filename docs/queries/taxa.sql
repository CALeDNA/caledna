update pour.gbif_taxa  set ids = '{}';

update pour.gbif_taxa  set common_names = NULL;


UPDATE pour.gbif_taxa
SET common_names =
coalesce(common_names || ' | ' || temp.vernacular_name, temp.vernacular_name)
FROM (
SELECT vernacular_name, taxon_id
FROM pour.gbif_common_names
) AS temp
WHERE gbif_taxa.taxon_id = temp.taxon_id;


SELECT  gbif_common_names.taxon_id, count(*)
FROM pour.gbif_common_names
join  pour.gbif_taxa on gbif_taxa.taxon_id = gbif_common_names.taxon_id
group by  gbif_common_names.taxon_id;

update pour.gbif_taxa
set infraspecific_epithet = foo.infraspecific_epithet from (
select infraspecific_epithet,  taxon_id
from pour.gbif_occurrences
group by infraspecific_epithet,  taxon_id
) as foo
where gbif_taxa.taxon_id = foo.taxon_id;


-- 3267
select count(*) from pour.gbif_taxa ;

-- 3267
select count(*)
from pour.gbif_occurrences
group by taxon_id;

select infraspecific_epithet,  taxon_id, count(distinct verbatim_scientific_name) as count
from pour.gbif_occurrences
group by infraspecific_epithet,  taxon_id
having count(distinct verbatim_scientific_name)  > 1;


from  pour.gbif_taxa
left join  pour.gbif_occurrences
on gbif_taxa.taxon_id = gbif_occurrences.taxon_id
where gbif_occurrences.taxon_id is null;

---------

select distinct taxon_rank from pour.gbif_taxa;

-- fill in gbif_id

select *
from pour.inat_taxa
where gbif_id is null;


select *
from pour.inat_taxa
join pour.gbif_taxa
on inat_taxa.family = gbif_taxa.family;
where gbif_taxa.order = inat_taxa.order;


SELECT inat_taxa.inat_id, gbif_taxa.taxon_id as gbif_id,
 inat_taxa.scientific_name, gbif_taxa.verbatim_scientific_name,
 inat_taxa.species, gbif_taxa.species,
 inat_taxa.rank, gbif_taxa.taxon_rank,
  inat_taxa.scientific_name = gbif_taxa.verbatim_scientific_name
FROM pour.inat_taxa
JOIN pour.gbif_taxa
ON inat_taxa.species = gbif_taxa.species
WHERE gbif_taxa.family = inat_taxa.family
AND inat_taxa.gbif_id is null
AND inat_taxa.rank = 'species'
and gbif_taxa.taxon_rank = 'species'
;

-- 3011 verbatim_scientific_name = verbatim_scientific_name
--
select gbif_occurrences.taxon_id,
gbif_taxa.canonical_name = gbif_occurrences.canonical_name,
gbif_taxa.canonical_name, gbif_occurrences.verbatim_scientific_name
from  pour.gbif_taxa
join pour.gbif_occurrences on gbif_occurrences.taxon_id = gbif_taxa.taxon_id
--where gbif_taxa.verbatim_scientific_name = gbif_occurrences.verbatim_scientific_name
group by gbif_occurrences.taxon_id,
gbif_taxa.verbatim_scientific_name = gbif_occurrences.verbatim_scientific_name,
gbif_taxa.verbatim_scientific_name, gbif_occurrences.verbatim_scientific_name;

-- 2836 family
-- 2946 order
-- 2979 class
-- 2990 phylum
-- 2991 kingdom

select  gbif_taxa.canonical_name ,
 gbif_taxa.taxon_rank, gbif_taxa.kingdom, gbif_taxa.phylum, gbif_taxa.class_name, gbif_taxa.order, gbif_taxa.family,
 inat_taxa.canonical_name ,
inat_taxa.rank, inat_taxa.kingdom , inat_taxa.phylum , inat_taxa.class_name, inat_taxa.order, inat_taxa.family
from pour.inat_taxa
join pour.gbif_taxa on gbif_taxa.species = inat_taxa.species
where inat_taxa.gbif_id is null
;


select
 inat_taxa.canonical_name , inat_taxa.rank,  inat_taxa.scientific_name,
  gbif_taxa.canonical_name , gbif_taxa.taxon_rank,  gbif_taxa.scientific_name
from pour.inat_taxa
--join pour.gbif_taxa on inat_taxa.canonical_name like gbif_taxa.scientific_name || '%'
JOIN pour.gbif_taxa ON gbif_taxa.scientific_name LIKE inat_taxa.canonical_name || '%'
--join pour.gbif_taxa on gbif_taxa.species = inat_taxa.species
and gbif_taxa.taxon_rank = inat_taxa.rank
--
 where inat_taxa.gbif_id is null
;


select
inat_taxa.canonical_name , inat_taxa.rank, inat_taxa.id as inat_id,
gbif_occurrences.taxon_rank,  gbif_occurrences.verbatim_scientific_name,
gbif_occurrences.taxon_id as gbif_id
from pour.inat_taxa
JOIN pour.gbif_occurrences ON gbif_occurrences.verbatim_scientific_name = inat_taxa.canonical_name
--JOIN pour.gbif_occurrences ON gbif_occurrences.scientific_name like inat_taxa.canonical_name  || '%'

and gbif_occurrences.taxon_rank = inat_taxa.rank
where inat_taxa.gbif_id is null
 ;

update pour.gbif_taxa set common_names = temp.common from (
select
inat_taxa.common_name,
gbif_taxa.taxon_id, gbif_taxa.common_names,

CASE
   WHEN inat_taxa.common_name is null  and gbif_taxa.common_names is not  null
     THEN   gbif_taxa.common_names
   WHEN inat_taxa.common_name is not null  and gbif_taxa.common_names is  null
     THEN  inat_taxa.common_name
    WHEN inat_taxa.common_name  =   gbif_taxa.common_names
    then gbif_taxa.common_names

   else inat_taxa.common_name || ' | ' || gbif_taxa.common_names
END common

from pour.inat_taxa
JOIN pour.gbif_taxa ON gbif_taxa.taxon_id = inat_taxa.gbif_id
 ) as temp
 where gbif_taxa.taxon_id = temp.taxon_id
 ;


select    count(*)
from pour.inat_taxa
where inat_taxa.gbif_id is null;

-------


select  inat_taxa.kingdom as k_n, gbif_taxa.kingdom as k_g,
inat_taxa.phylum as p_n, gbif_taxa.phylum as p_g,
 inat_taxa.class_name as c_n,  gbif_taxa.class_name as c_g,
  inat_taxa.order as o_n,    gbif_taxa.order as o_g,
 inat_taxa.family as f_n,  gbif_taxa.family as f_g
from pour.inat_taxa
join pour.gbif_taxa
on inat_taxa.species = gbif_taxa.species
where gbif_taxa.family = inat_taxa.family;
