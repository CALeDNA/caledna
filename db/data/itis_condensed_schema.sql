CREATE TABLE hierarchy (
    hierarchy_string character varying(300) NOT NULL,
    tsn integer NOT NULL,
    parent_tsn integer,
    level integer NOT NULL,
    childrencount integer NOT NULL
);

CREATE TABLE kingdoms (
    kingdom_id integer NOT NULL,
    kingdom_name character(10) NOT NULL,
    update_date date NOT NULL
);

CREATE TABLE longnames (
    tsn integer NOT NULL,
    completename character varying(300) NOT NULL
);

CREATE TABLE taxon_unit_types (
    kingdom_id integer NOT NULL,
    rank_id smallint NOT NULL,
    rank_name character(15) NOT NULL,
    dir_parent_rank_id smallint NOT NULL,
    req_parent_rank_id smallint NOT NULL,
    update_date date NOT NULL
);

CREATE TABLE taxonomic_units (
    tsn integer NOT NULL,
    unit_ind1 character(1) DEFAULT NULL::bpchar,
    unit_name1 character(35) NOT NULL,
    unit_ind2 character(1) DEFAULT NULL::bpchar,
    unit_name2 character varying(35) DEFAULT NULL::character varying,
    unit_ind3 character varying(7) DEFAULT NULL::character varying,
    unit_name3 character varying(35) DEFAULT NULL::character varying,
    unit_ind4 character varying(7) DEFAULT NULL::character varying,
    unit_name4 character varying(35) DEFAULT NULL::character varying,
    unnamed_taxon_ind character(1) DEFAULT NULL::bpchar,
    name_usage character varying(12) NOT NULL,
    unaccept_reason character varying(50) DEFAULT NULL::character varying,
    credibility_rtng character varying(40) NOT NULL,
    completeness_rtng character(10) DEFAULT NULL::bpchar,
    currency_rating character(7) DEFAULT NULL::bpchar,
    phylo_sort_seq smallint,
    initial_time_stamp timestamp without time zone NOT NULL,
    parent_tsn integer,
    taxon_author_id integer,
    hybrid_author_id integer,
    kingdom_id smallint NOT NULL,
    rank_id smallint NOT NULL,
    update_date date NOT NULL,
    uncertain_prnt_ind character(3) DEFAULT NULL::bpchar,
    n_usage text,
    complete_name character varying(255) NOT NULL
);

CREATE TABLE vernaculars (
    tsn integer NOT NULL,
    vernacular_name character varying(80) NOT NULL,
    language character varying(15) NOT NULL,
    approved_ind character(1) DEFAULT NULL::bpchar,
    update_date date NOT NULL,
    vern_id integer NOT NULL
);

ALTER TABLE ONLY hierarchy
    ADD CONSTRAINT hierarchy_pkey PRIMARY KEY (hierarchy_string);

ALTER TABLE ONLY kingdoms
    ADD CONSTRAINT kingdoms_pkey PRIMARY KEY (kingdom_id);

ALTER TABLE ONLY longnames
    ADD CONSTRAINT longnames_pkey PRIMARY KEY (tsn);

ALTER TABLE ONLY taxon_unit_types
    ADD CONSTRAINT taxon_unit_types_pkey PRIMARY KEY (kingdom_id, rank_id);

ALTER TABLE ONLY taxonomic_units
    ADD CONSTRAINT taxonomic_units_pkey PRIMARY KEY (tsn);

ALTER TABLE ONLY vernaculars
    ADD CONSTRAINT vernaculars_pkey PRIMARY KEY (tsn, vern_id);
