CREATE TABLE external.gbif_occ_taxa (
  taxonkey integer,
  kingdom character varying,
  phylum character varying,
  classname character varying,
  "order" character varying,
  family character varying,
  genus character varying,
  species character varying,
  infraspecificepithet character varying,
  taxonrank character varying,
  scientificname character varying
);

-- populate species
INSERT INTO external.gbif_occ_taxa(
  taxonkey, kingdom, phylum, classname, "order", family, genus,
  species, infraspecificepithet, taxonrank, scientificname
)
SELECT distinct taxonkey, kingdom, phylum, classname, "order", family, genus,
species, infraspecificepithet, 'species', scientificname
FROM external.gbif_occurrences
WHERE taxonkey != 0 and species is not null;

-- populate genus
INSERT INTO external.gbif_occ_taxa(
  kingdom, phylum, classname, "order", family, genus, taxonrank
)
SELECT distinct kingdom, phylum, classname, "order", family, genus, 'genus'
FROM external.gbif_occurrences
where genus is not null;

-- populate family
INSERT INTO external.gbif_occ_taxa(
  kingdom, phylum, classname, "order", family, taxonrank
)
SELECT distinct kingdom, phylum, classname, "order", family, 'family'
FROM external.gbif_occurrences
where family is not null;

-- populate order
INSERT INTO external.gbif_occ_taxa(
  kingdom, phylum, classname, "order", taxonrank
)
SELECT distinct kingdom, phylum, classname, "order", 'order'
FROM external.gbif_occurrences
where "order" is not null;

-- populate classname
INSERT INTO external.gbif_occ_taxa(
  kingdom, phylum, classname, taxonrank
)
SELECT distinct kingdom, phylum, classname, 'class'
FROM external.gbif_occurrences
where classname is not null;

-- populate phylum
INSERT INTO external.gbif_occ_taxa(
  kingdom, phylum, taxonrank
)
SELECT distinct kingdom, phylum, 'phylum'
FROM external.gbif_occurrences
where phylum is not null;

-- populate kingdom
INSERT INTO external.gbif_occ_taxa(
  kingdom, taxonrank
)
SELECT distinct kingdom, 'kingdom'
FROM external.gbif_occurrences
where kingdom is not null;



CREATE INDEX gbif_occ_taxa_taxonkey_idx ON external.gbif_occ_taxa(taxonkey);
