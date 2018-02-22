CREATE TABLE multimedia (
    "taxonID" integer NOT NULL,
    identifier text,
    "references" text,
    title text,
    description text,
    license text,
    creator text,
    created character varying(255) DEFAULT NULL::character varying,
    contributor character varying(255) DEFAULT NULL::character varying,
    publisher character varying(255) DEFAULT NULL::character varying,
    "rightsHolder" text,
    source text
);

CREATE TABLE taxa (
    "taxonID" integer NOT NULL,
    "datasetID" character varying(255) DEFAULT NULL::character varying,
    "parentNameUsageID" integer,
    "acceptedNameUsageID" integer,
    "originalNameUsageID" integer,
    "scientificName" text,
    "scientificNameAuthorship" text,
    "canonicalName" character varying(255) DEFAULT NULL::character varying,
    "genericName" character varying(255) DEFAULT NULL::character varying,
    "specificEpithet" character varying(255) DEFAULT NULL::character varying,
    "infraspecificEpithet" character varying(255) DEFAULT NULL::character varying,
    "taxonRank" character varying(255) DEFAULT NULL::character varying,
    "nameAccordingTo" character varying(255) DEFAULT NULL::character varying,
    "namePublishedIn" text,
    "taxonomicStatus" character varying(255) DEFAULT NULL::character varying,
    "nomenclaturalStatus" character varying(255) DEFAULT NULL::character varying,
    "taxonRemarks" character varying(255) DEFAULT NULL::character varying,
    kingdom character varying(255) DEFAULT NULL::character varying,
    phylum character varying(255) DEFAULT NULL::character varying,
    "className" character varying(255) DEFAULT NULL::character varying,
    "order" character varying(255) DEFAULT NULL::character varying,
    family character varying(255) DEFAULT NULL::character varying,
    genus character varying(255) DEFAULT NULL::character varying,
    hierarchy jsonb
);


CREATE TABLE vernaculars (
    "taxonID" integer NOT NULL,
    "vernacularName" text,
    language character varying(255),
    country character varying(255),
    "countryCode" character varying(255),
    sex character varying(255),
    "lifeStage" character varying(255),
    source text
);
--

ALTER TABLE ONLY taxa
    ADD CONSTRAINT taxon_pkey PRIMARY KEY ("taxonID");

CREATE INDEX multimedia_taxonid_idx ON multimedia USING btree ("taxonID");

CREATE INDEX "taxa_acceptedNameUsageID_idx" ON taxa USING btree ("acceptedNameUsageID");
CREATE INDEX taxa_heirarchy_idx ON taxa USING gin (hierarchy);
CREATE INDEX taxon_canonicalname_idx ON taxa USING btree (lower(("canonicalName")::text));
CREATE INDEX taxon_taxonomicstatus_idx ON taxa USING btree ("taxonomicStatus");

CREATE INDEX vernacular_taxonid_idx ON vernaculars USING btree ("taxonID");
CREATE INDEX vernacular_vernacularname_idx ON vernaculars USING btree (lower("vernacularName"));
