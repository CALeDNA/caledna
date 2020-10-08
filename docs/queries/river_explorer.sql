-- Aves
select * from ncbi_nodes where taxon_id = 7063;

SELECT canonical_name
FROM ncbi_nodes
WHERE (to_tsvector('simple', canonical_name) || to_tsvector('english', common_names) )
@@ plainto_tsquery('english', 'Birds')
ORDER BY asvs_count DESC NULLS LAST
LIMIT 1;


SELECT gbif_taxa.taxon_id
FROM pour.gbif_common_names
JOIN pour.gbif_taxa
ON gbif_taxa.taxon_id = gbif_common_names.taxon_id
WHERE to_tsvector('english', vernacular_name)
@@ plainto_tsquery('english', 'bird')
ORDER BY occurrence_count DESC NULLS LAST
LIMIT 1;


SELECT mapgrid.id, count(distinct(gbif_id)) AS count,
mapgrid.latitude, mapgrid.longitude, mapgrid.geom
FROM pour.gbif_occurrences_river as gbif_occurrences
 JOIN pour.gbif_taxa
   ON pour.gbif_taxa.taxon_id = gbif_occurrences.taxon_id
 JOIN pour.mapgrid
   ON ST_Contains(mapgrid.geom, gbif_occurrences.geom)
WHERE gbif_taxa.ids @> '{212}'
AND gbif_occurrences.distance = 1000
GROUP BY mapgrid.id;

select count(*)
from pour.gbif_occurrences
join pour.gbif_taxa
on gbif_taxa.taxon_id = gbif_occurrences.taxon_id
where names @> '{Aves}';


select *
from pour.gbif_occurrences
JOIN pour.mapgrid
ON (ST_Contains(mapgrid.geom_projected, gbif_occurrences.geom_projected))
JOIN pour.gbif_taxa
ON pour.gbif_taxa.taxon_id = pour.gbif_occurrences.taxon_id
where mapgrid.id = 5298
and gbif_taxa.names @> '{Sceloporus occidentalis}';

-- 814 aves 1km hex

 SELECT mapgrid.id, count(distinct(gbif_id)) AS count,
  mapgrid.latitude, mapgrid.longitude, ST_AsGeoJSON(mapgrid.geom) as geom
FROM pour.gbif_occurrences
 JOIN pour.gbif_taxa
   ON pour.gbif_taxa.taxon_id = pour.gbif_occurrences.taxon_id
 JOIN pour.mapgrid as mapgrid
   ON (ST_Contains(mapgrid.geom_projected,
     gbif_occurrences.geom_projected))
 JOIN places
   ON ST_DWithin(places.geom_projected,
     gbif_occurrences.geom_projected, 1000)
   AND places.place_source_type_cd = 'LA_river'
   AND places.place_type_cd = 'river'
where gbif_taxa.names @> '{Aves}'
GROUP BY mapgrid.id;

----------------------

-- 20795 aves within 1 km  of river
 SELECT
  gbif_id, gbif_occurrences.latitude, gbif_occurrences.longitude, gbif_occurrences.geom
FROM pour.gbif_occurrences
 JOIN pour.gbif_taxa
   ON pour.gbif_taxa.taxon_id = pour.gbif_occurrences.taxon_id
-- JOIN pour.mapgrid_river as mapgrid
--   ON (ST_Contains(mapgrid.geom_projected,
--     gbif_occurrences.geom_projected))
 JOIN places
   ON ST_DWithin(places.geom_projected,
     gbif_occurrences.geom_projected, 1000)
   AND places.place_source_type_cd = 'LA_river'
   AND places.place_type_cd = 'river'
where gbif_taxa.names @> '{Aves}'
GROUP BY   gbif_occurrences.gbif_id;

-- 814 aves 1km hex
-- 2613 gbif_id for haxbin 5891 for aves

 SELECT
  count(distinct gbif_id), mapgrid.id, mapgrid.latitude, mapgrid.longitude, mapgrid.geom
FROM pour.gbif_occurrences
 JOIN pour.gbif_taxa
   ON pour.gbif_taxa.taxon_id = pour.gbif_occurrences.taxon_id
 JOIN pour.mapgrid as mapgrid
   ON (ST_Contains(mapgrid.geom_projected,
     gbif_occurrences.geom_projected))
 JOIN places
   ON ST_DWithin(places.geom_projected,
     gbif_occurrences.geom_projected, 1000)
   AND places.place_source_type_cd = 'LA_river'
   AND places.place_type_cd = 'river'
where gbif_taxa.names @> '{Aves}'
and mapgrid.id = 2075
GROUP BY mapgrid.id,  mapgrid.latitude, mapgrid.longitude, mapgrid.geom
order by count desc
;


-- 1385  gbif_id   mapgrid 2075

 SELECT
  count(distinct gbif_id), mapgrid.id, mapgrid.latitude, mapgrid.longitude, mapgrid.geom
FROM pour.gbif_occurrences
 JOIN pour.gbif_taxa
   ON pour.gbif_taxa.taxon_id = pour.gbif_occurrences.taxon_id
 JOIN pour.mapgrid_river as mapgrid
    ON (ST_Contains(mapgrid.geom_projected,
     gbif_occurrences.geom_projected))
-- JOIN places
--   ON ST_DWithin(places.geom_projected,
--     gbif_occurrences.geom_projected, 1000)
--   AND places.place_source_type_cd = 'LA_river'
--   AND places.place_type_cd = 'river'
where gbif_taxa.names @> '{Aves}'
GROUP BY mapgrid.id,  mapgrid.latitude, mapgrid.longitude, mapgrid.geom
order by count desc
;

--------------

-- mapgrid partially within 1km
select geom_projected from pour.mapgrid where id = 2075;
-- 0106000020110F0000010000000103000000010000000700000076DF98FFF02769C1EA23C46304EC4E41DDEEEC54C72769C1F894A21025ED4E41A90D95FF732769C1F894A21025ED4E41101DE9544A2769C1EA23C46304EC4E41A90D95FF732769C1DCB2E5B6E3EA4E41DDEEEC54C72769C1DCB2E5B6E3EA4E4176DF98FFF02769C1EA23C46304EC4E41

-- mapgrid completely within 1km
select geom_projected from pour.mapgrid where id = 3572;
-- 0106000020110F00000100000001030000000100000007000000817B4CFF2C1E69C1987D8D5640E54E41E88AA054031E69C1A5EE6B0361E64E41B5A948FFAF1D69C1A5EE6B0361E64E411CB99C54861D69C1987D8D5640E54E41B5A948FFAF1D69C18A0CAFA91FE44E41E88AA054031E69C18A0CAFA91FE44E41817B4CFF2C1E69C1987D8D5640E54E41


-- 1385  gbif_id for mapgrid 2075 for aves
select gbif_occurrences.gbif_id
FROM pour.gbif_occurrences
JOIN pour.gbif_taxa ON pour.gbif_taxa.taxon_id = pour.gbif_occurrences.taxon_id
where ST_Contains('0106000020110F0000010000000103000000010000000700000076DF98FFF02769C1EA23C46304EC4E41DDEEEC54C72769C1F894A21025ED4E41A90D95FF732769C1F894A21025ED4E41101DE9544A2769C1EA23C46304EC4E41A90D95FF732769C1DCB2E5B6E3EA4E41DDEEEC54C72769C1DCB2E5B6E3EA4E4176DF98FFF02769C1EA23C46304EC4E41', geom_projected)
and gbif_taxa.names @> '{Aves}'
group by  gbif_occurrences.gbif_id;

-- 1193  gbif_id for mapgrid 3572 for aves
select gbif_occurrences.gbif_id
FROM pour.gbif_occurrences
JOIN pour.gbif_taxa ON pour.gbif_taxa.taxon_id = pour.gbif_occurrences.taxon_id
where ST_Contains('0106000020110F00000100000001030000000100000007000000817B4CFF2C1E69C1987D8D5640E54E41E88AA054031E69C1A5EE6B0361E64E41B5A948FFAF1D69C1A5EE6B0361E64E411CB99C54861D69C1987D8D5640E54E41B5A948FFAF1D69C18A0CAFA91FE44E41E88AA054031E69C18A0CAFA91FE44E41817B4CFF2C1E69C1987D8D5640E54E41', geom_projected)
and gbif_taxa.names @> '{Aves}'
group by  gbif_occurrences.gbif_id;


-- 547 gbif_id for mapgrid 2075  and 1km for aves
-- 1193  gbif_id for mapgrid 3572 and 1km  for aves
SELECT mapgrid.id, count(distinct gbif_id)
FROM pour.gbif_occurrences
 JOIN pour.gbif_taxa
   ON pour.gbif_taxa.taxon_id = pour.gbif_occurrences.taxon_id
 JOIN pour.mapgrid as mapgrid
   ON (ST_Contains(mapgrid.geom_projected,
     gbif_occurrences.geom_projected))
 JOIN places
   ON ST_DWithin(places.geom_projected,
     gbif_occurrences.geom_projected, 1000)
   AND places.place_source_type_cd = 'LA_river'
   AND places.place_type_cd = 'river'
where gbif_taxa.names @> '{Aves}'
GROUP BY   mapgrid.id;


-- 547 gbif_id for mapgrid 2075  and 1km for aves
-- 1193  gbif_id for mapgrid 3572 and 1km  for aves
 SELECT
  count(distinct gbif_id), mapgrid.id, mapgrid.latitude, mapgrid.longitude,
  mapgrid.geom
FROM pour.gbif_occurrences_river as gbif_occurrences
 JOIN pour.gbif_taxa
   ON pour.gbif_taxa.taxon_id = gbif_occurrences.taxon_id
 JOIN pour.mapgrid_river as mapgrid
    ON (ST_Contains(mapgrid.geom_projected,
     gbif_occurrences.geom_projected))
-- JOIN places
--   ON ST_DWithin(places.geom_projected,
--     gbif_occurrences.geom_projected, 1000)
--   AND places.place_source_type_cd = 'LA_river'
--   AND places.place_type_cd = 'river'
where gbif_taxa.names @> '{Aves}'
--and mapgrid.id in ( 2075, 3572)
GROUP BY mapgrid.id,  mapgrid.latitude, mapgrid.longitude, mapgrid.geom ;


-----------------------


select count(*) from pour.gbif_occurrences;

select gbif_occurrences.latitude, gbif_occurrences.longitude;

CREATE INDEX name_autocomplete_idx ON pour.gbif_taxa USING btree (lower ("scientific_name") text_pattern_ops);

create materialized view  pour.inat_occurrences as
select * from pour.gbif_occurrences
where gbif_occurrences.gbif_dataset_id = 1;

-- 1861
select inat_occurrences.latitude, inat_occurrences.longitude
from pour.inat_occurrences
join pour.gbif_taxa on inat_occurrences.taxon_id = gbif_taxa.taxon_id
join places on ST_DWithin(places.geom_projected, inat_occurrences.geom_projected, 1000)
where places.place_source_type_cd = 'LA_river'
and places.place_type_cd = 'river'
and lower(pour.gbif_taxa.scientific_name)  like 'sceloporus';

select
ST_X(ST_SnapToGrid(pour.gbif_occurrences.geom,0.01)) as longitude,
ST_Y(ST_SnapToGrid(pour.gbif_occurrences.geom,0.01)) as latitude,
count(distinct(gbif_id))
from pour.gbif_occurrences
join pour.gbif_taxa on gbif_occurrences.taxon_id = gbif_taxa.taxon_id
join places on ST_DWithin(places.geom_projected, gbif_occurrences.geom_projected, 100)
where places.place_source_type_cd = 'LA_river'
and places.place_type_cd = 'river'
and pour.gbif_taxa.names @> ARRAY['Aves']
group by
ST_SnapToGrid(pour.gbif_occurrences.geom,0.01)
;

 -- species within 1km of river

 select gbif_id, gbif_occurrences.latitude
from pour.gbif_occurrences
join pour.gbif_taxa on gbif_occurrences.taxon_id = gbif_taxa.taxon_id
join places on ST_DWithin(places.geom_projected, gbif_occurrences.geom_projected, 1000)
where places.place_source_type_cd = 'LA_river'
and places.place_type_cd = 'river'
and pour.gbif_taxa.names @> ARRAY['Aves']
group by gbif_occurrences.gbif_id;


select id, geom, name
from places
where  places.place_source_type_cd = 'LA_river'
and places.place_type_cd = 'river'
;

-- select mapgrids 1km within river for birds

SELECT mapgrid.id, count((gbif_id)) AS count,
mapgrid.latitude, mapgrid.longitude, ST_AsGeoJSON(mapgrid.geom) as geom
FROM pour.gbif_occurrences
JOIN pour.mapgrid_1km AS mapgrid
ON (ST_Contains(mapgrid.geom_projected, gbif_occurrences.geom_projected))

join places on ST_DWithin(places.geom_projected, gbif_occurrences.geom_projected, 1000)
and places.place_source_type_cd = 'LA_river'
and places.place_type_cd = 'river'

JOIN pour.gbif_taxa
ON pour.gbif_taxa.taxon_id = pour.gbif_occurrences.taxon_id
where gbif_taxa.names @> ARRAY['Aves']
GROUP BY mapgrid.id;

----

-- most popular species
-- Western Fence Lizard,  Sceloporus occidentalis, 2451234
-- 1341976 Apis mellifera, honey bee

select count(*), class_name, "order", family, genus, species, gbif_taxa.taxon_id
from pour.gbif_occurrences
join pour.gbif_taxa on gbif_taxa.taxon_id = gbif_occurrences.taxon_id

group by class_name, "order", family, genus, species, gbif_taxa.taxon_id
;


SELECT  count(distinct(gbif_id)) AS count, gbif_taxa.scientific_name
FROM pour.gbif_occurrences_river as gbif_occurrences
 JOIN pour.gbif_taxa
   ON pour.gbif_taxa.taxon_id = gbif_occurrences.taxon_id
WHERE gbif_occurrences.distance = 1000
GROUP BY gbif_taxa.scientific_name;


 SELECT mapgrid.id, count(distinct(gbif_id)) AS count,
mapgrid.latitude, mapgrid.longitude, ST_AsGeoJSON(mapgrid.geom) as geom
FROM pour.gbif_occurrences_river as gbif_occurrences
 JOIN pour.gbif_taxa
   ON pour.gbif_taxa.taxon_id = gbif_occurrences.taxon_id
 JOIN pour.mapgrid
   ON ST_Contains(mapgrid.geom, gbif_occurrences.geom)
WHERE gbif_occurrences.distance = 1000;
AND mapgrid.size = 1500
AND mapgrid.type = 'hexagon'
GROUP BY mapgrid.id;
--

-- all Western Fence Lizard observations

select count(*), identified_by
from pour.gbif_occurrences
where taxon_id = 2451234
group by gbif_occurrences.identified_by;

select * from pour.gbif_occurrences
where taxon_id = 2451234;


select * from pour.gbif_occurrences;

-- bees

select * from pour.gbif_occurrences
where taxon_id = 1341976;

-- lizard in edna

select *
from asvs
where taxon_id = 8519;

select id, barcode, latitude, longitude from samples_map where research_project_ids @> '{7}';

----------------------------


--10 * 10 * 3.12

-- actual
--  834 miles^2 * 1.609344
-- 2160.050 km ^2

-- 2152.19000000000 km^2 original shape file
select ST_Area(geom_projected )
from places
where name ='Los Angeles'
and place_type_cd ='watershed';



select ST_Area(ST_Buffer(geom_projected, 1000)) / 1000 ^2
from places
where places.name = 'Maywood'
and places.place_type_cd = 'pour_location';

select ST_Area(ST_Buffer(geom_projected, 1000)) / 1000 ^2
from places
where places.name = 'Maywood'
and places.place_type_cd = 'pour_location';

-- 488m buffer, 394 km^2
-- 1000km buffer, 791 km^2
-- 2100km buffer, 1582 km^2
-- 5080km buffer, 3,165 km^2
select ST_Area(ST_Union(ST_Buffer(geom_projected, 5080))) / 1000 ^2
from places
where places.place_source_type_cd = 'LA_river'
and places.place_type_cd = 'river';


select ST_Union(ST_Buffer(geom_projected, 5080))
from places
where places.place_source_type_cd = 'LA_river'
and places.place_type_cd = 'river';

-- 122352 occurences in watershed
select count(*)
from pour.gbif_occurrences;

-- 3267 taxa in watershed
select count(distinct gbif_taxa.taxon_id)
from pour.gbif_occurrences
join pour.gbif_taxa on gbif_occurrences.taxon_id = gbif_taxa.taxon_id;


-- taxa counts by kingdom in watershed

select kingdom, count, count * 100 / (sum(count) over ()) as percent
from
(
select kingdom, count(distinct gbif_taxa.taxon_id)
from pour.gbif_occurrences
join pour.gbif_taxa on gbif_occurrences.taxon_id = gbif_taxa.taxon_id
group by kingdom
) temp;


with total as (
select kingdom, count(distinct gbif_taxa.taxon_id)
from pour.gbif_occurrences
join pour.gbif_taxa on gbif_occurrences.taxon_id = gbif_taxa.taxon_id
group by kingdom
)
select kingdom, count, count * 100 / (select sum(count) from total)   as percent
from total;



-- taxa counts by phylum in watershed
select kingdom, phylum, count, count * 100 / (sum(count) over ()) as percent
from
(
select kingdom, phylum, count(distinct gbif_taxa.taxon_id)
from pour.gbif_occurrences
join pour.gbif_taxa on gbif_occurrences.taxon_id = gbif_taxa.taxon_id
group by kingdom, phylum
) temp;


-- taxa counts by kingdom within 1km of river

select kingdom, count, count * 100 / (sum(count) over ()) as percent
from
(
select kingdom, count(distinct gbif_taxa.taxon_id)
from pour.gbif_occurrences
join pour.gbif_taxa on gbif_occurrences.taxon_id = gbif_taxa.taxon_id
join places on ST_DWithin(places.geom_projected, gbif_occurrences.geom_projected, 4000)
where places.place_source_type_cd = 'LA_river'
and places.place_type_cd = 'river'
group by kingdom
) temp;

-- taxa counts by phylum within 1km of river

select kingdom, phylum, class_name, count, count * 100 / (sum(count) over ()) as percent
from
(
select kingdom, phylum, gbif_taxa.class_name, count(distinct gbif_taxa.taxon_id)
from pour.gbif_occurrences
join pour.gbif_taxa on gbif_occurrences.taxon_id = gbif_taxa.taxon_id
join places on ST_DWithin(places.geom_projected, gbif_occurrences.geom_projected, 1000)
where places.place_source_type_cd = 'LA_river'
and places.place_type_cd = 'river'
group by kingdom, phylum, gbif_taxa.class_name
) temp;

-- taxa counts by class within 1km of river

select kingdom, phylum, class_name, count, count * 100 / (sum(count) over ()) as percent
from
(
select kingdom, phylum, gbif_taxa.class_name, count(distinct gbif_taxa.taxon_id)
from pour.gbif_occurrences
join pour.gbif_taxa on gbif_occurrences.taxon_id = gbif_taxa.taxon_id
join places on ST_DWithin(places.geom_projected, gbif_occurrences.geom_projected, 1000)
where places.place_source_type_cd = 'LA_river'
and places.place_type_cd = 'river'
group by kingdom, phylum, gbif_taxa.class_name
) temp;

-------------


-- 122352 occurences
select count(*)
from pour.gbif_occurrences;

-- 44846 occurences with 1km
create view pour.gbif_occurrences_1km as
select  count(distinct gbif_occurrences.gbif_id)
from pour.gbif_occurrences
join pour.gbif_taxa on gbif_occurrences.taxon_id = gbif_taxa.taxon_id
join places on ST_DWithin(places.geom_projected, gbif_occurrences.geom_projected, 1000)
where places.place_source_type_cd = 'LA_river'
and places.place_type_cd = 'river';



-- occurence counts by kingdom within watershed

select kingdom,   count, count * 100 / (sum(count) over ()) as percent, sum(count) over ()
from
(
select kingdom,   count( gbif_taxa.taxon_id)
from pour.gbif_occurrences
join pour.gbif_taxa on gbif_occurrences.taxon_id = gbif_taxa.taxon_id
join places on ST_DWithin(places.geom_projected, gbif_occurrences.geom_projected, 1000)
where places.place_source_type_cd = 'LA_river'
and places.place_type_cd = 'river'
group by kingdom
order by kingdom
) temp;


-- occurence counts by class within 1km of river

select kingdom, phylum, class_name as class, count, count * 100 / (sum(count) over ()) as percent
from
(
select kingdom, phylum, gbif_taxa.class_name, count( gbif_taxa.taxon_id)
from pour.gbif_occurrences
join pour.gbif_taxa on gbif_occurrences.taxon_id = gbif_taxa.taxon_id
--join places on ST_DWithin(places.geom_projected, gbif_occurrences.geom_projected, 1000)
--where places.place_source_type_cd = 'LA_river'
--and places.place_type_cd = 'river'
group by kingdom, phylum, gbif_taxa.class_name
order by kingdom, phylum, gbif_taxa.class_name
) temp;


select kingdom, phylum, count(distinct gbif_taxa.taxon_id)
from pour.gbif_occurrences
join pour.gbif_taxa on gbif_occurrences.taxon_id = gbif_taxa.taxon_id

where gbif_id not in (
	select   gbif_occurrences.gbif_id
	from pour.gbif_occurrences
	 join places on ST_DWithin(places.geom_projected, gbif_occurrences.geom_projected, 1000)
	where places.place_source_type_cd = 'LA_river'
	and places.place_type_cd = 'river'
)
group by kingdom, phylum;

------------


-- 2063 taxa within 1km of river

-- 3267 taxa in watershed
-- 1110 taxa within 62.5m of river
-- 1320 taxa within 125m of river
-- 1522 taxa within 250m of river
-- 1753 taxa within 500m of river
-- 2063 taxa within 1km of river
-- 2436 taxa within 2km of river
-- 2680 taxa within 3km of river
-- 2828 taxa within 4km of river
select count(distinct gbif_taxa.taxon_id)
from pour.gbif_occurrences
join pour.gbif_taxa on gbif_occurrences.taxon_id = gbif_taxa.taxon_id
join places on ST_DWithin(places.geom_projected, gbif_occurrences.geom_projected, 1000)
where places.place_source_type_cd = 'LA_river'
and places.place_type_cd = 'river'
;





------------
-- venn of taxa river only, land only, river and land

-- 122352 occurences in watershed
select  gbif_occurrences.gbif_id
from pour.gbif_occurrences;


-- 44846 occurences within 1km river
select distinct gbif_occurrences.gbif_id
from pour.gbif_occurrences
 join places on ST_DWithin(places.geom_projected, gbif_occurrences.geom_projected, 1000)
where places.place_source_type_cd = 'LA_river'
and places.place_type_cd = 'river';

-- 77506 occurences not in river
select  gbif_occurrences.gbif_id
from pour.gbif_occurrences where gbif_id not in (
	select distinct gbif_occurrences.gbif_id
	from pour.gbif_occurrences
	 join places on ST_DWithin(places.geom_projected, gbif_occurrences.geom_projected, 1000)
	where places.place_source_type_cd = 'LA_river'
	and places.place_type_cd = 'river'
);


-- 3267 taxa in watershed
select count(distinct taxon_id)
from pour.gbif_occurrences;


-- 2063 taxa in river ; 2.2 sec
select distinct taxon_id
from pour.gbif_occurrences
where gbif_id in (
	select distinct gbif_occurrences.gbif_id
	from pour.gbif_occurrences
	join places on ST_DWithin(places.geom_projected, gbif_occurrences.geom_projected, 1000)
	where places.place_source_type_cd = 'LA_river'
	and places.place_type_cd = 'river'
);

-- 2063 taxa in river ; 2.2 sec
select  distinct gbif_taxa.taxon_id
from pour.gbif_occurrences
join pour.gbif_taxa on gbif_occurrences.taxon_id = gbif_taxa.taxon_id
join places on ST_DWithin(places.geom_projected, gbif_occurrences.geom_projected, 1000)
where places.place_source_type_cd = 'LA_river'
and places.place_type_cd = 'river';



-- 2805 taxa not in river ; 2.2 sec
select distinct taxon_id
from pour.gbif_occurrences
where gbif_id in (
	select  gbif_occurrences.gbif_id
	from pour.gbif_occurrences where gbif_id not in (
		select   gbif_occurrences.gbif_id
		from pour.gbif_occurrences
		 join places on ST_DWithin(places.geom_projected, gbif_occurrences.geom_projected, 1000)
		where places.place_source_type_cd = 'LA_river'
		and places.place_type_cd = 'river'
	)
);


-- 2805 taxa not in river ; 2.2 sec
select  distinct gbif_occurrences.taxon_id
from pour.gbif_occurrences where gbif_id not in (
	select   gbif_occurrences.gbif_id
	from pour.gbif_occurrences
	 join places on ST_DWithin(places.geom_projected, gbif_occurrences.geom_projected, 1000)
	where places.place_source_type_cd = 'LA_river'
	and places.place_type_cd = 'river'
);


-- 2805 taxa not in river ; 8.9 sec
select  distinct gbif_occurrences.taxon_id
from pour.gbif_occurrences
left join places on ST_DWithin(places.geom_projected, gbif_occurrences.geom_projected, 1000)
and places.place_source_type_cd = 'LA_river'
and places.place_type_cd = 'river'
where places.id is null;


-- 2805 taxa not in river; 30 second query
select   distinct gbif_occurrences.taxon_id
from pour.gbif_occurrences
join pour.gbif_taxa on gbif_occurrences.taxon_id = gbif_taxa.taxon_id
left join places on ST_DWithin(places.geom_projected, gbif_occurrences.geom_projected, 1000)
and places.place_source_type_cd = 'LA_river'
and places.place_type_cd = 'river'
where places.id is null;

-- 1601 taxa in river and land
select   taxon_id
from pour.gbif_occurrences
where gbif_id in (
	select distinct gbif_occurrences.gbif_id
	from pour.gbif_occurrences
	 join places on ST_DWithin(places.geom_projected, gbif_occurrences.geom_projected, 1000)
	where places.place_source_type_cd = 'LA_river'
	and places.place_type_cd = 'river'
)

intersect

select   taxon_id
from pour.gbif_occurrences
where gbif_id in (
	select  gbif_occurrences.gbif_id
	from pour.gbif_occurrences where gbif_id not in (
		select distinct gbif_occurrences.gbif_id
		from pour.gbif_occurrences
		 join places on ST_DWithin(places.geom_projected, gbif_occurrences.geom_projected, 1000)
		where places.place_source_type_cd = 'LA_river'
		and places.place_type_cd = 'river'
	)
);


-- 1204 taxa land only; 4.5 sec

 select gbif_occurrences.taxon_id
from pour.gbif_occurrences where gbif_id not in (
	select   gbif_occurrences.gbif_id
	from pour.gbif_occurrences
	 join places on ST_DWithin(places.geom_projected, gbif_occurrences.geom_projected, 1000)
	where places.place_source_type_cd = 'LA_river'
	and places.place_type_cd = 'river'
)
except

select gbif_taxa.taxon_id
from pour.gbif_occurrences
join pour.gbif_taxa on gbif_occurrences.taxon_id = gbif_taxa.taxon_id
join places on ST_DWithin(places.geom_projected, gbif_occurrences.geom_projected, 1000)
where places.place_source_type_cd = 'LA_river'
and places.place_type_cd = 'river'

;

-- 1204 taxa land only; 2.2 sec
select distinct taxon_id
from pour.gbif_occurrences
where taxon_id not in(
select   gbif_taxa.taxon_id
from pour.gbif_occurrences
join pour.gbif_taxa on gbif_occurrences.taxon_id = gbif_taxa.taxon_id
join places on ST_DWithin(places.geom_projected, gbif_occurrences.geom_projected, 1000)
where places.place_source_type_cd = 'LA_river'
and places.place_type_cd = 'river'
);


-- 1204 taxa land only; 2.2 sec
select  taxon_id
from pour.gbif_occurrences
except
select  gbif_taxa.taxon_id
from pour.gbif_occurrences
join pour.gbif_taxa on gbif_occurrences.taxon_id = gbif_taxa.taxon_id
join places on ST_DWithin(places.geom_projected, gbif_occurrences.geom_projected, 1000)
where places.place_source_type_cd = 'LA_river'
and places.place_type_cd = 'river';




-- 462 taxa in river only; 4.5
select gbif_taxa.taxon_id
from pour.gbif_occurrences
join pour.gbif_taxa on gbif_occurrences.taxon_id = gbif_taxa.taxon_id
join places on ST_DWithin(places.geom_projected, gbif_occurrences.geom_projected, 1000)
where places.place_source_type_cd = 'LA_river'
and places.place_type_cd = 'river'

except

select gbif_occurrences.taxon_id
from pour.gbif_occurrences where gbif_id not in (
	select   gbif_occurrences.gbif_id
	from pour.gbif_occurrences
	 join places on ST_DWithin(places.geom_projected, gbif_occurrences.geom_projected, 1000)
	where places.place_source_type_cd = 'LA_river'
	and places.place_type_cd = 'river'
);


------------


-- taxa counts by kingdom in watershed

select kingdom, count, count * 100 / (sum(count) over ()) as percent
from
(
select kingdom, count(distinct gbif_taxa.taxon_id)
from pour.gbif_occurrences
join pour.gbif_taxa on gbif_occurrences.taxon_id = gbif_taxa.taxon_id
group by kingdom
) temp;


with total as (
select kingdom, count(distinct gbif_taxa.taxon_id)
from pour.gbif_occurrences
join pour.gbif_taxa on gbif_occurrences.taxon_id = gbif_taxa.taxon_id
group by kingdom
)
select kingdom, count, count * 100 / (select sum(count) from total)   as percent
from total;



-- taxa counts by phylum in watershed
select kingdom, phylum, count, count * 100 / (sum(count) over ()) as percent
from
(
select kingdom, phylum, count(distinct gbif_taxa.taxon_id)
from pour.gbif_occurrences
join pour.gbif_taxa on gbif_occurrences.taxon_id = gbif_taxa.taxon_id
group by kingdom, phylum
) temp;


select
 kingdom,
--count(*)
count(distinct gbif_taxa.taxon_id)
from pour.gbif_occurrences
join pour.gbif_taxa on gbif_occurrences.taxon_id = gbif_taxa.taxon_id
--join places on ST_DWithin(places.geom_projected, gbif_occurrences.geom_projected, 1000)
--where places.place_source_type_cd = 'LA_river'
--and places.place_type_cd = 'river'
group by kingdom;

-------------


  ----------



CREATE INDEX full_text_search_idx ON pour.gbif_taxa USING gin(
to_tsvector('english', common_names)
);

SELECT latitude, longitude, common_names
FROM (
  SELECT
    latitude, longitude, common_names,
    to_tsvector('english', common_names) AS doc
  FROM pour.gbif_occurrences
  JOIN pour.gbif_taxa
    ON gbif_occurrences.taxon_id = gbif_taxa.taxon_id
) as search
WHERE search.doc @@ plainto_tsquery('english', 'fish');

select count(*) from pour.gbif_taxa;
select count(*) from pour.gbif_occurrences;

SELECT *
FROM pour.gbif_occurrences
JOIN pour.gbif_taxa
ON pour.gbif_taxa.taxon_id = pour.gbif_occurrences.taxon_id
where gbif_taxa."scientific_name"  = 'Actinopterygii';

SELECT *
FROM pour.gbif_occurrences
JOIN pour.gbif_taxa
ON pour.gbif_taxa.taxon_id = pour.gbif_occurrences.taxon_id
where gbif_taxa."class_name"  = 'Actinopterygii';

SELECT mapgrid.id, count(distinct(gbif_id)) AS count,
mapgrid.latitude, mapgrid.longitude
FROM pour.mapgrid_1km AS mapgrid
JOIN pour.gbif_occurrences
ON (ST_Contains(mapgrid.geom_projected, gbif_occurrences.geom_projected))
JOIN pour.gbif_taxa
ON pour.gbif_taxa.taxon_id = pour.gbif_occurrences.taxon_id
where gbif_taxa.names @> '{Actinopterygii}'
GROUP BY mapgrid.id;


SELECT  count( (gbif_id)) AS count
        FROM   pour.gbif_occurrences
JOIN pour.gbif_taxa
ON pour.gbif_taxa.taxon_id = pour.gbif_occurrences.taxon_id
where gbif_taxa.names @> '{Actinopterygii}'
;


 SELECT id, count, latitude, longitude
FROM (
  SELECT mapgrid.id, count(distinct(gbif_id)) AS count,
    mapgrid.latitude, mapgrid.longitude, vernacular_name,
    to_tsvector('english', vernacular_name) AS doc
  FROM pour.mapgrid_1km AS mapgrid
  JOIN pour.gbif_occurrences
    ON (ST_Contains(mapgrid.geom_projected, gbif_occurrences.geom_projected))
  JOIN pour.gbif_taxa
    ON pour.gbif_taxa.taxon_id = pour.gbif_occurrences.taxon_id
  JOIN pour.gbif_common_names
    ON gbif_taxa.taxon_id = gbif_common_names.taxon_id
  GROUP BY mapgrid.id, vernacular_name
) as search
WHERE search.doc @@ plainto_tsquery('english', 'fish');
-- show hexgon with any inat observations in watershed
-- change size 500, 1000, 1500, 2000

SELECT mapgrid.id, count(distinct(gbif_id)) AS count,
mapgrid.latitude, mapgrid.longitude, mapgrid.geom
FROM pour.gbif_occurrences  as gbif_occurrences
JOIN pour.mapgrid
   ON ST_Contains(mapgrid.geom, gbif_occurrences.geom)
WHERE mapgrid.size = 500 and mapgrid.type = 'hexagon'
GROUP BY mapgrid.id;

 ----

 -- show all inat observations in watershed


SELECT gbif_occurrences.gbif_id, count(distinct(gbif_id)) AS count,
gbif_occurrences.latitude, gbif_occurrences.longitude, gbif_occurrences.geom
FROM pour.gbif_occurrences  as gbif_occurrences
GROUP BY gbif_occurrences.gbif_id;

-------
