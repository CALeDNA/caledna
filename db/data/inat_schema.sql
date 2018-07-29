CREATE TABLE "inat_observations" (
  "id" int,
  "occurrenceID" varchar(255),
  "basisOfRecord" varchar(255),
  "modified" varchar(255),
  "institutionCode" varchar(255),
  "collectionCode" varchar(255),
  "datasetName" varchar(255),
  "informationWithheld" varchar(255),
  "catalogNumber" varchar(255),
  "references" varchar(255),
  "occurrenceRemarks" text,
  "occurrenceDetails" text,
  "recordedBy" varchar(255),
  "establishmentMeans" varchar(255),
  "eventDate" varchar(255),
  "eventTime" varchar(255),
  "verbatimEventDate" varchar(255),
  "verbatimLocality" varchar(255),
  "decimalLatitude" numeric,
  "decimalLongitude" numeric,
  "coordinateUncertaintyInMeters" varchar(255),
  "countryCode" varchar(255),
  "identificationID" varchar(255),
  "dateIdentified" varchar(255),
  "identificationRemarks" text,

  "taxonID" varchar(255),
  "scientificName" varchar(255),
  "taxonRank" varchar(255),
  "kingdom" varchar(255),
  "phylum" varchar(255),
  "className" varchar(255),
  "order" varchar(255),
  "family" varchar(255),
  "genus" varchar(255),

  "license" varchar(255),
  "rights" varchar(255),
  "rightsHolder" varchar(255)
);

CREATE TABLE "inat_taxa" (
  "taxonID" varchar(255),
  "scientificName" varchar(255),
  "taxonRank" varchar(255),
  "kingdom" varchar(255),
  "phylum" varchar(255),
  "className" varchar(255),
  "order" varchar(255),
  "family" varchar(255),
  "genus" varchar(255)
);

ALTER TABLE inat_observations ADD PRIMARY KEY (id);
CREATE INDEX observations_taxonID_idx ON "inat_observations" ("taxonID");
CREATE INDEX observations_scientificName_idx ON "inat_observations" (lower("scientificName"));
CREATE INDEX observations_taxonRank_idx ON "inat_observations" ("taxonRank");
CREATE INDEX observations_taxa_idx ON "inat_observations" ("kingdom", "phylum", "className", "order", "family", "genus");

CREATE INDEX taxa_taxonID_idx ON "inat_taxa" ("taxonID");
CREATE INDEX taxa_scientificName_idx ON "inat_taxa" (lower("scientificName"));
CREATE INDEX taxa_taxonRank_idx ON "inat_taxa" ("taxonRank");
CREATE INDEX taxa_taxa_idx ON "inat_taxa" ("kingdom", "phylum", "className", "order", "family", "genus");
