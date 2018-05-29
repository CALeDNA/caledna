CREATE TABLE public.ncbi_citations (
    id integer NOT NULL,
    citation_key text,
    pubmed_id integer,
    medline_id integer,
    url text,
    text text,
    taxon_id_list text
);

CREATE TABLE public.ncbi_names (
    taxon_id integer NOT NULL,
    name text,
    unique_name character varying(255),
    name_class character varying(255)
);

CREATE TABLE public.ncbi_nodes (
    taxon_id integer NOT NULL,
    parent_taxon_id integer,
    rank character varying(255),
    embl_code character varying(255),
    division_id integer,
    inherited_division boolean,
    genetic_code_id integer,
    inherited_genetic_code boolean,
    mitochondrial_genetic_code_id integer,
    inherited_mitochondrial_genetic_code boolean,
    genbank_hidden boolean,
    hidden_subtree_root boolean,
    comments text
);

CREATE TABLE public.ncbi_divisions (
  id integer NOT NULL,
  cde character varying(255),
  name character varying(255),
  comments character varying(255)
);

ALTER TABLE ONLY ncbi_citations
    ADD CONSTRAINT ncbi_citations_pkey PRIMARY KEY ("id");

ALTER TABLE ONLY ncbi_nodes
    ADD CONSTRAINT ncbi_nodes_pkey PRIMARY KEY ("taxon_id");

CREATE INDEX ncbi_names_taxonid_idx ON ncbi_names USING btree ("taxon_id");
CREATE INDEX ncbi_nodes_divisionid_idx ON ncbi_nodes USING btree ("division_id");

ALTER TABLE ONLY ncbi_divisions
    ADD CONSTRAINT ncbi_divisions_pkey PRIMARY KEY ("id");
