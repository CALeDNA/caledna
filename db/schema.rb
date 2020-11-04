# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2020_11_04_043656) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_stat_statements"
  enable_extension "plpgsql"
  enable_extension "postgis"
  enable_extension "tablefunc"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.bigint "byte_size", null: false
    t.string "checksum", null: false
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "asvs", force: :cascade do |t|
    t.integer "taxon_id"
    t.bigint "sample_id"
    t.integer "count"
    t.bigint "research_project_id"
    t.bigint "primer_id"
    t.datetime "created_at", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.datetime "updated_at", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.string "taxonomy_string"
    t.index ["primer_id"], name: "index_asvs_on_primer_id"
    t.index ["primer_id"], name: "index_pillar_point.asvs_on_primer_id"
    t.index ["research_project_id"], name: "index_asvs_on_research_project_id"
    t.index ["research_project_id"], name: "index_pillar_point.asvs_on_research_project_id"
    t.index ["sample_id"], name: "index_asvs_on_sample_id"
    t.index ["sample_id"], name: "index_pillar_point.asvs_on_sample_id"
    t.index ["taxon_id"], name: "index_asvs_on_taxon_id"
    t.index ["taxon_id"], name: "index_pillar_point.asvs_on_taxon_id"
  end

  create_table "asvs", force: :cascade do |t|
    t.integer "taxon_id"
    t.bigint "sample_id"
    t.integer "count"
    t.bigint "research_project_id"
    t.bigint "primer_id"
    t.datetime "created_at", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.datetime "updated_at", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.string "taxonomy_string"
    t.index ["primer_id"], name: "index_asvs_on_primer_id"
    t.index ["primer_id"], name: "index_pillar_point.asvs_on_primer_id"
    t.index ["research_project_id"], name: "index_asvs_on_research_project_id"
    t.index ["research_project_id"], name: "index_pillar_point.asvs_on_research_project_id"
    t.index ["sample_id"], name: "index_asvs_on_sample_id"
    t.index ["sample_id"], name: "index_pillar_point.asvs_on_sample_id"
    t.index ["taxon_id"], name: "index_asvs_on_taxon_id"
    t.index ["taxon_id"], name: "index_pillar_point.asvs_on_taxon_id"
  end

  create_table "asvs_2017", id: :serial, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "taxon_id"
    t.text "primers", default: [], array: true
    t.integer "sample_id"
    t.integer "count", default: 0
    t.jsonb "counts", default: {}
    t.integer "research_project_id"
    t.string "primer"
    t.bigint "primer_id"
    t.index ["primer_id"], name: "index_asvs_2017_on_primer_id"
    t.index ["research_project_id"], name: "index_asvs_2017_on_research_project_id"
    t.index ["sample_id"], name: "index_asvs_2017_on_sample_id"
    t.index ["taxon_id"], name: "index_asvs_2017_on_taxon_id"
  end

  create_table "cal_taxa_old", id: false, force: :cascade do |t|
    t.integer "id"
    t.string "taxon_rank"
    t.jsonb "hierarchy"
    t.boolean "normalized"
    t.integer "taxon_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean "ignore"
    t.string "original_taxonomy_string"
    t.string "clean_taxonomy_string"
    t.text "sources", array: true
  end

  create_table "combine_taxa", force: :cascade do |t|
    t.bigint "source_taxon_id"
    t.string "source"
    t.string "superkingdom"
    t.string "kingdom"
    t.string "phylum"
    t.string "class_name"
    t.string "order"
    t.string "family"
    t.string "genus"
    t.string "species"
    t.string "taxon_rank"
    t.string "canonical_name"
    t.text "short_taxonomy_string"
    t.text "notes"
    t.integer "cal_division_id"
    t.string "source_superkingdom"
    t.string "source_kingdom"
    t.string "source_phylum"
    t.string "source_class_name"
    t.string "source_order"
    t.string "source_family"
    t.string "source_genus"
    t.string "source_species"
    t.string "synonym"
    t.jsonb "hierarchy_names"
    t.text "full_taxonomy_string"
    t.string "paper_match_type"
    t.jsonb "global_names"
    t.boolean "approved"
    t.bigint "caledna_taxon_id"
    t.index "lower((\"order\")::text)", name: "index_combine_taxa_on_order"
    t.index "lower((class_name)::text)", name: "index_combine_taxa_on_class_name"
    t.index "lower((family)::text)", name: "index_combine_taxa_on_family"
    t.index "lower((genus)::text)", name: "index_combine_taxa_on_genus"
    t.index "lower((phylum)::text)", name: "index_combine_taxa_on_phylum"
    t.index "lower((species)::text)", name: "index_combine_taxa_on_species"
    t.index ["cal_division_id"], name: "index_combine_taxa_on_cal_division_id"
    t.index ["caledna_taxon_id"], name: "index_pillar_point.combine_taxa_on_caledna_taxon_id"
    t.index ["kingdom"], name: "index_combine_taxa_on_kingdom"
    t.index ["source"], name: "index_combine_taxa_on_source"
    t.index ["source_taxon_id"], name: "index_combine_taxa_on_source_taxon_id"
  end

  create_table "edna_gbif", force: :cascade do |t|
    t.string "superkingdom"
    t.string "kingdom"
    t.string "phylum"
    t.string "class_name"
    t.string "order"
    t.string "family"
    t.string "genus"
    t.string "species"
    t.boolean "ncbi_match"
    t.boolean "edna_match"
    t.integer "count"
    t.string "gbif_taxa"
    t.string "ncbi_taxa"
    t.string "rank"
    t.index ["rank"], name: "index_pillar_point.edna_gbif_on_rank"
  end

  create_table "event_registrations", force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "event_id"
    t.string "status_cd"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["event_id"], name: "index_event_registrations_on_event_id"
    t.index ["user_id", "event_id"], name: "index_event_registrations_on_user_id_and_event_id", unique: true
    t.index ["user_id"], name: "index_event_registrations_on_user_id"
  end

  create_table "events", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "start_date", null: false
    t.datetime "end_date", null: false
    t.text "description", null: false
    t.text "location"
    t.text "contact"
    t.bigint "field_project_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "registration_required", default: true
    t.index ["field_project_id"], name: "index_events_on_field_project_id"
  end

  create_table "external_resources", force: :cascade do |t|
    t.integer "ncbi_id"
    t.integer "eol_id"
    t.integer "gbif_id"
    t.string "wikidata_image"
    t.integer "bold_id"
    t.integer "calflora_id"
    t.integer "cites_id"
    t.integer "cnps_id"
    t.integer "inaturalist_id"
    t.integer "itis_id"
    t.integer "iucn_id"
    t.integer "msw_id"
    t.string "wikidata_entity"
    t.integer "worms_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "iucn_status"
    t.string "source"
    t.string "col_id"
    t.string "wikispecies_id"
    t.jsonb "payload"
    t.boolean "low_score"
    t.string "vernaculars", default: [], array: true
    t.string "search_term"
    t.string "notes"
    t.jsonb "inat_payload", default: {}
    t.string "eol_image"
    t.string "eol_image_attribution"
    t.string "inat_image"
    t.string "inat_image_attribution"
    t.integer "tol_id"
    t.text "wiki_excerpt"
    t.string "wiki_title"
    t.boolean "active", default: true
    t.jsonb "dup_data", default: {}
    t.string "ncbi_name"
    t.bigint "inat_image_id"
    t.string "gbif_image"
    t.string "gbif_image_attribution"
    t.index ["gbif_id"], name: "index_external_resources_on_gbif_id"
    t.index ["ncbi_id"], name: "index_external_resources_on_ncbi_id"
    t.index ["search_term"], name: "index_external_resources_on_search_term"
    t.index ["source"], name: "index_external_resources_on_source"
    t.index ["wikidata_entity"], name: "index_external_resources_on_wikidata_entity"
    t.index ["wikidata_image"], name: "external_resources_wikidata_image_idx"
  end

  create_table "field_projects", id: :serial, force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.integer "kobo_id"
    t.jsonb "kobo_payload"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "last_import_date"
    t.string "date_range"
    t.boolean "published", default: true
    t.index ["kobo_id"], name: "index_field_projects_on_kobo_id", unique: true
  end

  create_table "gbif_common_names", force: :cascade do |t|
    t.bigint "taxon_id"
    t.string "vernacular_name"
    t.string "language"
    t.string "scientific_name"
    t.string "taxonomic_status"
    t.string "taxon_rank"
    t.bigint "accepted_taxon_id"
    t.index "lower((vernacular_name)::text) text_pattern_ops", name: "vernacular_name_prefix"
    t.index "to_tsvector('english'::regconfig, (vernacular_name)::text)", name: "full_text_search_idx", using: :gin
    t.index ["taxon_id"], name: "index_pour.gbif_common_names_on_taxon_id"
  end

  create_table "gbif_datasets", force: :cascade do |t|
    t.string "dataset_key"
    t.string "institution_code"
    t.string "collection_code"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "gbif_occ_taxa", id: false, force: :cascade do |t|
    t.integer "taxonkey"
    t.string "kingdom"
    t.string "phylum"
    t.string "classname"
    t.string "order"
    t.string "family"
    t.string "genus"
    t.string "species"
    t.string "infraspecificepithet"
    t.string "taxonrank"
    t.string "scientificname"
    t.index ["taxonkey"], name: "gbif_occ_taxa_taxonkey_idx"
  end

  create_table "gbif_occurrences", primary_key: "gbif_id", force: :cascade do |t|
    t.string "occurrence_id"
    t.bigint "gbif_dataset_id"
    t.string "scientific_name"
    t.string "verbatim_scientific_name"
    t.string "taxon_rank"
    t.bigint "taxon_id"
    t.bigint "species_id"
    t.decimal "latitude"
    t.decimal "longitude"
    t.decimal "coordinate_uncertainty_in_meters"
    t.string "country_code"
    t.string "state_province"
    t.geometry "geom", limit: {:srid=>4326, :type=>"st_point"}
    t.datetime "event_date"
    t.string "identified_by"
    t.datetime "date_identified"
    t.string "license"
    t.string "rights_holder"
    t.string "recorded_by"
    t.datetime "last_interpreted"
    t.string "basis_of_record"
    t.integer "catalog_number"
    t.string "media_type"
    t.string "issue"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.geometry "geom_projected", limit: {:srid=>3857, :type=>"geometry"}
    t.string "verbatim_scientific_name_authorship"
    t.string "locality"
    t.string "occurrence_status"
    t.integer "individual_count"
    t.string "publishing_org_key"
    t.decimal "coordinate_precision"
    t.integer "elevation"
    t.integer "elevation_accuracy"
    t.integer "depth"
    t.integer "depth_accuracy"
    t.integer "day"
    t.integer "month"
    t.integer "year"
    t.string "institution_code"
    t.string "collection_code"
    t.integer "record_number"
    t.string "type_status"
    t.string "establishment_means"
    t.string "infraspecific_epithet"
    t.index "lower((genus)::text)", name: "index_gbif_occurrences_on_genus"
    t.index ["classname"], name: "index_external.gbif_occurrences_on_classname"
    t.index ["family"], name: "index_external.gbif_occurrences_on_family"
    t.index ["gbif_dataset_id"], name: "index_pour.gbif_occurrences_on_gbif_dataset_id"
    t.index ["genus"], name: "index_external.gbif_occurrences_on_genus"
    t.index ["geom"], name: "index_pour.gbif_occurrences_on_geom", using: :gist
    t.index ["geom_projected"], name: "index_pour.gbif_occurrences_on_geom_projected", using: :gist
    t.index ["order"], name: "index_external.gbif_occurrences_on_order"
    t.index ["phylum"], name: "index_external.gbif_occurrences_on_phylum"
    t.index ["scientificname"], name: "gbif_ob_scientificname_idx"
    t.index ["species"], name: "index_external.gbif_occurrences_on_species"
    t.index ["taxonkey"], name: "gbif_ob_taxonkey_idx"
    t.index ["taxonrank"], name: "gbif_ob_taxonrank_idx"
  end

  create_table "gbif_occurrences", primary_key: "gbif_id", force: :cascade do |t|
    t.string "occurrence_id"
    t.bigint "gbif_dataset_id"
    t.string "scientific_name"
    t.string "verbatim_scientific_name"
    t.string "taxon_rank"
    t.bigint "taxon_id"
    t.bigint "species_id"
    t.decimal "latitude"
    t.decimal "longitude"
    t.decimal "coordinate_uncertainty_in_meters"
    t.string "country_code"
    t.string "state_province"
    t.geometry "geom", limit: {:srid=>4326, :type=>"st_point"}
    t.datetime "event_date"
    t.string "identified_by"
    t.datetime "date_identified"
    t.string "license"
    t.string "rights_holder"
    t.string "recorded_by"
    t.datetime "last_interpreted"
    t.string "basis_of_record"
    t.integer "catalog_number"
    t.string "media_type"
    t.string "issue"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.geometry "geom_projected", limit: {:srid=>3857, :type=>"geometry"}
    t.string "verbatim_scientific_name_authorship"
    t.string "locality"
    t.string "occurrence_status"
    t.integer "individual_count"
    t.string "publishing_org_key"
    t.decimal "coordinate_precision"
    t.integer "elevation"
    t.integer "elevation_accuracy"
    t.integer "depth"
    t.integer "depth_accuracy"
    t.integer "day"
    t.integer "month"
    t.integer "year"
    t.string "institution_code"
    t.string "collection_code"
    t.integer "record_number"
    t.string "type_status"
    t.string "establishment_means"
    t.string "infraspecific_epithet"
    t.index "lower((genus)::text)", name: "index_gbif_occurrences_on_genus"
    t.index ["classname"], name: "index_external.gbif_occurrences_on_classname"
    t.index ["family"], name: "index_external.gbif_occurrences_on_family"
    t.index ["gbif_dataset_id"], name: "index_pour.gbif_occurrences_on_gbif_dataset_id"
    t.index ["genus"], name: "index_external.gbif_occurrences_on_genus"
    t.index ["geom"], name: "index_pour.gbif_occurrences_on_geom", using: :gist
    t.index ["geom_projected"], name: "index_pour.gbif_occurrences_on_geom_projected", using: :gist
    t.index ["order"], name: "index_external.gbif_occurrences_on_order"
    t.index ["phylum"], name: "index_external.gbif_occurrences_on_phylum"
    t.index ["scientificname"], name: "gbif_ob_scientificname_idx"
    t.index ["species"], name: "index_external.gbif_occurrences_on_species"
    t.index ["taxonkey"], name: "gbif_ob_taxonkey_idx"
    t.index ["taxonrank"], name: "gbif_ob_taxonrank_idx"
  end

  create_table "gbif_taxa", primary_key: "taxon_id", force: :cascade do |t|
    t.string "kingdom"
    t.bigint "kingdom_id"
    t.string "phylum"
    t.bigint "phylum_id"
    t.string "class_name"
    t.bigint "class_id"
    t.string "order"
    t.bigint "order_id"
    t.string "family"
    t.bigint "family_id"
    t.string "genus"
    t.bigint "genus_id"
    t.string "species"
    t.bigint "species_id"
    t.string "infraspecific_epithet"
    t.string "taxon_rank"
    t.string "scientific_name"
    t.string "taxonomic_status"
    t.string "accepted_scientific_name"
    t.string "accepted_taxon_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "names", default: [], array: true
    t.text "common_names"
    t.integer "ids", default: [], array: true
    t.integer "occurrence_count"
    t.string "canonical_name"
    t.index "((to_tsvector('simple'::regconfig, (canonical_name)::text) || to_tsvector('english'::regconfig, COALESCE(common_names, ''::text))))", name: "full_text_gbif_taxa_idx", using: :gin
    t.index "lower((scientific_name)::text) text_pattern_ops", name: "name_autocomplete_idx"
    t.index "to_tsvector('english'::regconfig, common_names)", name: "full_text_search_gc_idx", using: :gin
    t.index ["canonical_name"], name: "index_external.gbif_taxa_on_canonical_name"
    t.index ["class_id"], name: "gbif_taxa_class_id_idx"
    t.index ["family_id"], name: "gbif_taxa_family_id_idx"
    t.index ["gbif_id"], name: "index_external.gbif_taxa_on_gbif_id"
    t.index ["genus_id"], name: "gbif_taxa_genus_id_idx"
    t.index ["ids"], name: "index_pour.gbif_taxa_on_ids", using: :gin
    t.index ["kingdom_id"], name: "gbif_taxa_kingdom_id_idx"
    t.index ["names"], name: "index_pour.gbif_taxa_on_names", using: :gin
    t.index ["ncbi_id"], name: "index_external.gbif_taxa_on_ncbi_id"
    t.index ["order_id"], name: "gbif_taxa_order_id_idx"
    t.index ["phylum_id"], name: "gbif_taxa_phylum_id_idx"
    t.index ["species_id"], name: "gbif_taxa_species_id_idx"
    t.index ["taxonomic_status"], name: "index_external.gbif_taxa_on_taxonomic_status"
  end

  create_table "gbif_taxa", primary_key: "taxon_id", force: :cascade do |t|
    t.string "kingdom"
    t.bigint "kingdom_id"
    t.string "phylum"
    t.bigint "phylum_id"
    t.string "class_name"
    t.bigint "class_id"
    t.string "order"
    t.bigint "order_id"
    t.string "family"
    t.bigint "family_id"
    t.string "genus"
    t.bigint "genus_id"
    t.string "species"
    t.bigint "species_id"
    t.string "infraspecific_epithet"
    t.string "taxon_rank"
    t.string "scientific_name"
    t.string "taxonomic_status"
    t.string "accepted_scientific_name"
    t.string "accepted_taxon_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "names", default: [], array: true
    t.text "common_names"
    t.integer "ids", default: [], array: true
    t.integer "occurrence_count"
    t.string "canonical_name"
    t.index "((to_tsvector('simple'::regconfig, (canonical_name)::text) || to_tsvector('english'::regconfig, COALESCE(common_names, ''::text))))", name: "full_text_gbif_taxa_idx", using: :gin
    t.index "lower((scientific_name)::text) text_pattern_ops", name: "name_autocomplete_idx"
    t.index "to_tsvector('english'::regconfig, common_names)", name: "full_text_search_gc_idx", using: :gin
    t.index ["canonical_name"], name: "index_external.gbif_taxa_on_canonical_name"
    t.index ["class_id"], name: "gbif_taxa_class_id_idx"
    t.index ["family_id"], name: "gbif_taxa_family_id_idx"
    t.index ["gbif_id"], name: "index_external.gbif_taxa_on_gbif_id"
    t.index ["genus_id"], name: "gbif_taxa_genus_id_idx"
    t.index ["ids"], name: "index_pour.gbif_taxa_on_ids", using: :gin
    t.index ["kingdom_id"], name: "gbif_taxa_kingdom_id_idx"
    t.index ["names"], name: "index_pour.gbif_taxa_on_names", using: :gin
    t.index ["ncbi_id"], name: "index_external.gbif_taxa_on_ncbi_id"
    t.index ["order_id"], name: "gbif_taxa_order_id_idx"
    t.index ["phylum_id"], name: "gbif_taxa_phylum_id_idx"
    t.index ["species_id"], name: "gbif_taxa_species_id_idx"
    t.index ["taxonomic_status"], name: "index_external.gbif_taxa_on_taxonomic_status"
  end

  create_table "gbif_taxa_tos", primary_key: "taxon_id", force: :cascade do |t|
    t.string "kingdom"
    t.bigint "kingdom_id"
    t.string "phylum"
    t.bigint "phylum_id"
    t.string "class_name"
    t.bigint "class_id"
    t.string "order"
    t.bigint "order_id"
    t.string "family"
    t.bigint "family_id"
    t.string "genus"
    t.bigint "genus_id"
    t.string "species"
    t.bigint "species_id"
    t.string "taxon_rank"
    t.string "scientific_name"
    t.string "taxonomic_status"
    t.string "accepted_scientific_name"
    t.string "accepted_taxon_id"
    t.integer "occurrence_count"
    t.string "canonical_name"
    t.string "image"
    t.bigint "ncbi_id"
    t.integer "tos"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["canonical_name"], name: "index_external.gbif_taxa_tos_on_canonical_name"
    t.index ["ncbi_id"], name: "index_external.gbif_taxa_tos_on_ncbi_id"
    t.index ["taxon_rank"], name: "index_external.gbif_taxa_tos_on_taxon_rank"
    t.index ["taxonomic_status"], name: "index_external.gbif_taxa_tos_on_taxonomic_status"
  end

  create_table "ggbn_meta", force: :cascade do |t|
    t.string "technical_contact_name"
    t.string "technical_contact_email"
    t.string "technical_contact_address"
    t.string "content_contact_name"
    t.string "content_contact_email"
    t.string "content_contact_address"
    t.string "dataset_title"
    t.text "dataset_details"
    t.string "owner_organization_name"
    t.string "owner_organization_abbrev"
    t.string "owner_contact_person"
    t.string "owner_address"
    t.string "owner_email"
    t.text "copyright_details"
    t.text "terms_of_use_details"
    t.text "disclaimers_details"
    t.text "licenses_details"
    t.string "license_uri"
    t.text "acknowledgements_details"
    t.text "citations_details"
    t.string "source_institution_id"
    t.string "source_id"
    t.string "record_basis"
    t.string "kind_of_unit"
    t.string "language"
    t.string "altitude_unit_of_measurement"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "globi_interactions", force: :cascade do |t|
    t.string "sourceTaxonId"
    t.string "sourceTaxonIds"
    t.string "sourceTaxonName"
    t.string "sourceTaxonRank"
    t.string "sourceTaxonPathNames"
    t.string "sourceTaxonPathIds"
    t.string "sourceTaxonPathRankNames"
    t.string "sourceId"
    t.string "sourceOccurrenceId"
    t.string "sourceCatalogNumber"
    t.string "sourceBasisOfRecordId"
    t.string "sourceBasisOfRecordName"
    t.string "sourceLifeStageId"
    t.string "sourceLifeStageName"
    t.string "sourceBodyPartId"
    t.string "sourceBodyPartName"
    t.string "sourcePhysiologicalStateId"
    t.string "sourcePhysiologicalStateName"
    t.string "interactionTypeName"
    t.string "interactionTypeId"
    t.string "targetTaxonId"
    t.string "targetTaxonIds"
    t.string "targetTaxonName"
    t.string "targetTaxonRank"
    t.string "targetTaxonPathNames"
    t.string "targetTaxonPathIds"
    t.string "targetTaxonPathRankNames"
    t.string "targetId"
    t.string "targetOccurrenceId"
    t.string "targetCatalogNumber"
    t.string "targetBasisOfRecordId"
    t.string "targetBasisOfRecordName"
    t.string "targetLifeStageId"
    t.string "targetLifeStageName"
    t.string "targetBodyPartId"
    t.string "targetBodyPartName"
    t.string "targetPhysiologicalStateId"
    t.string "targetPhysiologicalStateName"
    t.string "decimalLatitude"
    t.string "decimalLongitude"
    t.string "localityId"
    t.string "localityName"
    t.string "eventDateUnixEpoch"
    t.string "referenceCitation"
    t.string "referenceDoi"
    t.string "referenceUrl"
    t.string "sourceCitation"
    t.string "sourceNamespace"
    t.string "sourceArchiveURI"
    t.string "sourceDOI"
    t.string "sourceLastSeenAtUnixEpoch"
    t.bigint "target_ncbi_id"
    t.bigint "target_gbif_id"
    t.bigint "source_ncbi_id"
    t.bigint "source_gbif_id"
    t.index ["sourceTaxonName"], name: "index_external.globi_interactions_on_sourceTaxonName"
    t.index ["source_gbif_id"], name: "globi_interactions_on_sourceGbifId"
    t.index ["source_ncbi_id"], name: "globi_interactions_on_sourceNcbiId"
    t.index ["targetTaxonId"], name: "index_external.globi_interactions_on_targetTaxonId"
    t.index ["targetTaxonName"], name: "index_external.globi_interactions_on_targetTaxonName"
    t.index ["target_gbif_id"], name: "globi_interactions_on_targetGbifId"
    t.index ["target_ncbi_id"], name: "globi_interactions_on_targetNcbiId"
  end

  create_table "globi_requests", force: :cascade do |t|
    t.string "taxon_name"
    t.string "taxon_id", array: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.jsonb "metadata", default: {}
  end

  create_table "globi_show", force: :cascade do |t|
    t.string "source_taxon_name"
    t.string "source_taxon_ids"
    t.string "source_taxon_path"
    t.string "source_taxon_rank"
    t.string "interaction_type"
    t.string "target_taxon_name"
    t.string "target_taxon_ids"
    t.string "target_taxon_path"
    t.string "target_taxon_rank"
    t.boolean "is_source"
    t.boolean "edna_match"
    t.boolean "gbif_match"
    t.string "keyword"
    t.index ["source_taxon_name"], name: "index_pillar_point.globi_show_on_source_taxon_name"
    t.index ["target_taxon_name"], name: "index_pillar_point.globi_show_on_target_taxon_name"
  end

  create_table "inat_taxa", force: :cascade do |t|
    t.string "scientific_name"
    t.string "common_name"
    t.string "iconic_taxon_name"
    t.string "kingdom"
    t.string "phylum"
    t.string "class_name"
    t.string "order"
    t.string "family"
    t.string "genus"
    t.string "species"
    t.string "rank"
    t.bigint "inat_id"
    t.bigint "gbif_id"
    t.bigint "ncbi_id"
    t.string "form"
    t.string "variety"
    t.string "subspecies"
    t.string "infraspecific_epithet"
    t.string "canonical_name"
    t.index ["common_name"], name: "index_pour.inat_taxa_on_common_name"
    t.index ["gbif_id"], name: "index_pour.inat_taxa_on_gbif_id"
    t.index ["inat_id"], name: "index_pour.inat_taxa_on_inat_id"
    t.index ["ncbi_id"], name: "index_pour.inat_taxa_on_ncbi_id"
    t.index ["scientific_name"], name: "index_pour.inat_taxa_on_scientific_name"
  end

  create_table "kobo_photos", id: :serial, force: :cascade do |t|
    t.string "source_url"
    t.string "file_name"
    t.integer "sample_id"
    t.jsonb "kobo_payload"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "height"
    t.integer "width"
    t.index ["sample_id"], name: "index_kobo_photos_on_sample_id"
  end

  create_table "mapgrid", id: :integer, default: -> { "nextval('hexbin_1km_id_seq'::regclass)" }, force: :cascade do |t|
    t.geometry "geom_projected", limit: {:srid=>3857, :type=>"multi_polygon"}
    t.decimal "left", precision: 24, scale: 15
    t.decimal "bottom", precision: 24, scale: 15
    t.decimal "right", precision: 24, scale: 15
    t.decimal "top", precision: 24, scale: 15
    t.geometry "geom", limit: {:srid=>4326, :type=>"geometry"}
    t.decimal "latitude"
    t.decimal "longitude"
    t.integer "size"
    t.string "type"
    t.index ["geom"], name: "index_pour.hexbin_on_geom", using: :gist
    t.index ["geom_projected"], name: "hexbin_1km_geom_projected_geom_projected_idx", using: :gist
  end

  create_table "ncbi_deleted_taxa", force: :cascade do |t|
    t.integer "taxon_id"
    t.bigint "ncbi_version_id"
    t.datetime "created_at", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.datetime "updated_at", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.index ["ncbi_version_id"], name: "index_external.ncbi_deleted_taxa_on_ncbi_version_id"
    t.index ["taxon_id"], name: "index_external.ncbi_deleted_taxa_on_taxon_id"
  end

  create_table "ncbi_divisions", id: :serial, force: :cascade do |t|
    t.string "cde", limit: 255
    t.string "name", limit: 255
    t.string "comments", limit: 255
  end

  create_table "ncbi_merged_taxa", force: :cascade do |t|
    t.integer "old_taxon_id"
    t.integer "taxon_id"
    t.bigint "ncbi_version_id"
    t.datetime "created_at", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.datetime "updated_at", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.index ["ncbi_version_id"], name: "index_external.ncbi_merged_taxa_on_ncbi_version_id"
    t.index ["old_taxon_id"], name: "index_external.ncbi_merged_taxa_on_old_taxon_id"
    t.index ["taxon_id"], name: "index_external.ncbi_merged_taxa_on_taxon_id"
  end

  create_table "ncbi_names", force: :cascade do |t|
    t.integer "taxon_id"
    t.text "name"
    t.string "unique_name"
    t.string "name_class"
    t.bigint "ncbi_version_id"
    t.datetime "created_at", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.datetime "updated_at", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.index "lower(name) text_pattern_ops", name: "name_prefix"
    t.index "lower(name)", name: "index_pillar_point.ncbi_names_on_lower_name"
    t.index ["name_class"], name: "index_ncbi_names_on_name_class"
    t.index ["name_class"], name: "index_pillar_point.ncbi_names_on_name_class"
    t.index ["ncbi_version_id"], name: "index_ncbi_names_on_ncbi_version_id"
    t.index ["taxon_id"], name: "index_ncbi_names_on_taxon_id"
    t.index ["taxon_id"], name: "index_pillar_point.ncbi_names_on_taxon_id"
  end

  create_table "ncbi_names", force: :cascade do |t|
    t.integer "taxon_id"
    t.text "name"
    t.string "unique_name"
    t.string "name_class"
    t.bigint "ncbi_version_id"
    t.datetime "created_at", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.datetime "updated_at", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.index "lower(name) text_pattern_ops", name: "name_prefix"
    t.index "lower(name)", name: "index_pillar_point.ncbi_names_on_lower_name"
    t.index ["name_class"], name: "index_ncbi_names_on_name_class"
    t.index ["name_class"], name: "index_pillar_point.ncbi_names_on_name_class"
    t.index ["ncbi_version_id"], name: "index_ncbi_names_on_ncbi_version_id"
    t.index ["taxon_id"], name: "index_ncbi_names_on_taxon_id"
    t.index ["taxon_id"], name: "index_pillar_point.ncbi_names_on_taxon_id"
  end

  create_table "ncbi_names_2017", force: :cascade do |t|
    t.integer "taxon_id", null: false
    t.text "name"
    t.string "unique_name", limit: 255
    t.string "name_class", limit: 255
    t.index "lower(name)", name: "index_ncbi_names_on_name"
    t.index ["name_class"], name: "index_ncbi_names_2017_on_name_class"
    t.index ["taxon_id"], name: "ncbi_names_taxonid_idx"
  end

  create_table "ncbi_nodes", primary_key: "taxon_id", id: :serial, force: :cascade do |t|
    t.integer "parent_taxon_id"
    t.string "rank"
    t.string "canonical_name"
    t.integer "division_id"
    t.integer "cal_division_id"
    t.text "full_taxonomy_string"
    t.integer "ids", default: [], array: true
    t.text "ranks", default: [], array: true
    t.text "names", default: [], array: true
    t.jsonb "hierarchy_names", default: {}
    t.jsonb "hierarchy", default: {}
    t.integer "ncbi_id"
    t.integer "bold_id"
    t.string "source", default: "ncbi"
    t.bigint "ncbi_version_id"
    t.string "alt_names"
    t.string "common_names"
    t.integer "asvs_count", default: 0
    t.integer "asvs_count_la_river", default: 0
    t.datetime "created_at", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.datetime "updated_at", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.string "iucn_status"
    t.index "((to_tsvector('simple'::regconfig, (canonical_name)::text) || to_tsvector('english'::regconfig, (COALESCE(common_names, ''::character varying))::text)))", name: "full_text_search_idx", using: :gin
    t.index "lower((canonical_name)::text) text_pattern_ops", name: "name_autocomplete_idx"
    t.index "lower((canonical_name)::text)", name: "index_pillar_point.ncbi_nodes_on_lower_canonical_name"
    t.index "lower((common_names)::text)", name: "foo"
    t.index "lower(replace((canonical_name)::text, ''''::text, ''::text))", name: "replace_quotes_idx"
    t.index ["asvs_count"], name: "index_ncbi_nodes_on_asvs_count"
    t.index ["asvs_count_la_river"], name: "index_ncbi_nodes_on_asvs_count_la_river"
    t.index ["bold_id"], name: "index_ncbi_nodes_on_bold_id"
    t.index ["cal_division_id"], name: "index_ncbi_nodes_on_cal_division_id"
    t.index ["hierarchy"], name: "index_ncbi_nodes_on_hierarchy", using: :gin
    t.index ["hierarchy_names"], name: "index_ncbi_nodes_on_hierarchy_names", using: :gin
    t.index ["ids"], name: "index_ncbi_nodes_on_ids", using: :gin
    t.index ["iucn_status"], name: "index_ncbi_nodes_on_iucn_status"
    t.index ["ncbi_id"], name: "index_ncbi_nodes_on_ncbi_id"
    t.index ["ncbi_version_id"], name: "index_ncbi_nodes_on_ncbi_version_id"
    t.index ["parent_taxon_id"], name: "index_ncbi_nodes_on_parent_taxon_id"
    t.index ["rank"], name: "index_ncbi_nodes_on_rank"
  end

  create_table "ncbi_nodes", primary_key: "taxon_id", id: :serial, force: :cascade do |t|
    t.integer "parent_taxon_id"
    t.string "rank"
    t.string "canonical_name"
    t.integer "division_id"
    t.integer "cal_division_id"
    t.text "full_taxonomy_string"
    t.integer "ids", default: [], array: true
    t.text "ranks", default: [], array: true
    t.text "names", default: [], array: true
    t.jsonb "hierarchy_names", default: {}
    t.jsonb "hierarchy", default: {}
    t.integer "ncbi_id"
    t.integer "bold_id"
    t.string "source", default: "ncbi"
    t.bigint "ncbi_version_id"
    t.string "alt_names"
    t.string "common_names"
    t.integer "asvs_count", default: 0
    t.integer "asvs_count_la_river", default: 0
    t.datetime "created_at", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.datetime "updated_at", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.string "iucn_status"
    t.index "((to_tsvector('simple'::regconfig, (canonical_name)::text) || to_tsvector('english'::regconfig, (COALESCE(common_names, ''::character varying))::text)))", name: "full_text_search_idx", using: :gin
    t.index "lower((canonical_name)::text) text_pattern_ops", name: "name_autocomplete_idx"
    t.index "lower((canonical_name)::text)", name: "index_pillar_point.ncbi_nodes_on_lower_canonical_name"
    t.index "lower((common_names)::text)", name: "foo"
    t.index "lower(replace((canonical_name)::text, ''''::text, ''::text))", name: "replace_quotes_idx"
    t.index ["asvs_count"], name: "index_ncbi_nodes_on_asvs_count"
    t.index ["asvs_count_la_river"], name: "index_ncbi_nodes_on_asvs_count_la_river"
    t.index ["bold_id"], name: "index_ncbi_nodes_on_bold_id"
    t.index ["cal_division_id"], name: "index_ncbi_nodes_on_cal_division_id"
    t.index ["hierarchy"], name: "index_ncbi_nodes_on_hierarchy", using: :gin
    t.index ["hierarchy_names"], name: "index_ncbi_nodes_on_hierarchy_names", using: :gin
    t.index ["ids"], name: "index_ncbi_nodes_on_ids", using: :gin
    t.index ["iucn_status"], name: "index_ncbi_nodes_on_iucn_status"
    t.index ["ncbi_id"], name: "index_ncbi_nodes_on_ncbi_id"
    t.index ["ncbi_version_id"], name: "index_ncbi_nodes_on_ncbi_version_id"
    t.index ["parent_taxon_id"], name: "index_ncbi_nodes_on_parent_taxon_id"
    t.index ["rank"], name: "index_ncbi_nodes_on_rank"
  end

  create_table "ncbi_nodes_2017", primary_key: "taxon_id", id: :integer, default: nil, force: :cascade do |t|
    t.integer "parent_taxon_id"
    t.string "rank", limit: 255
    t.string "embl_code", limit: 255
    t.integer "division_id"
    t.boolean "inherited_division"
    t.integer "genetic_code_id"
    t.boolean "inherited_genetic_code"
    t.integer "mitochondrial_genetic_code_id"
    t.boolean "inherited_mitochondrial_genetic_code"
    t.boolean "genbank_hidden"
    t.boolean "hidden_subtree_root"
    t.text "comments"
    t.string "canonical_name"
    t.text "lineage", array: true
    t.jsonb "hierarchy", default: {}
    t.text "full_taxonomy_string"
    t.text "short_taxonomy_string"
    t.integer "cal_division_id"
    t.integer "asvs_count", default: 0
    t.string "ids", default: [], array: true
    t.string "alt_names"
    t.jsonb "hierarchy_names", default: {}
    t.integer "ncbi_id"
    t.bigint "bold_id"
    t.integer "asvs_count_5", default: 0
    t.integer "asvs_count_la_river", default: 0
    t.integer "asvs_count_la_river_5", default: 0
    t.string "common_names"
    t.index "((to_tsvector('simple'::regconfig, (canonical_name)::text) || to_tsvector('english'::regconfig, (COALESCE(alt_names, ''::character varying))::text)))", name: "idx_taxa_search", using: :gin
    t.index "lower((canonical_name)::text) text_pattern_ops", name: "canonical_name_prefix"
    t.index "lower((canonical_name)::text)", name: "index_ncbi_nodes_on_canonical_name"
    t.index "lower(replace((canonical_name)::text, ''''::text, ''::text))", name: "boo"
    t.index ["asvs_count"], name: "index_ncbi_nodes_2017_on_asvs_count"
    t.index ["asvs_count_5"], name: "index_ncbi_nodes_2017_on_asvs_count_5"
    t.index ["asvs_count_la_river"], name: "index_ncbi_nodes_2017_on_asvs_count_la_river"
    t.index ["asvs_count_la_river_5"], name: "index_ncbi_nodes_2017_on_asvs_count_la_river_5"
    t.index ["bold_id"], name: "index_ncbi_nodes_2017_on_bold_id"
    t.index ["cal_division_id"], name: "index_ncbi_nodes_2017_on_cal_division_id"
    t.index ["division_id"], name: "ncbi_nodes_divisionid_idx"
    t.index ["hierarchy"], name: "index_taxa_on_hierarchy", using: :gin
    t.index ["hierarchy_names"], name: "index_ncbi_nodes_2017_on_hierarchy_names", using: :gin
    t.index ["ids"], name: "idx_ncbi_nodes_ids", using: :gin
    t.index ["ids"], name: "index_ncbi_nodes_2017_on_ids", using: :gin
    t.index ["ncbi_id"], name: "index_ncbi_nodes_2017_on_ncbi_id"
    t.index ["parent_taxon_id"], name: "index_ncbi_nodes_2017_on_parent_taxon_id"
    t.index ["rank"], name: "index_ncbi_nodes_2017_on_rank"
    t.index ["short_taxonomy_string"], name: "ncbi_nodes_short_taxonomy_string_idx"
  end

  create_table "ncbi_versions", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.datetime "updated_at", default: -> { "CURRENT_TIMESTAMP" }, null: false
  end

  create_table "page_blocks", force: :cascade do |t|
    t.text "content"
    t.bigint "page_id"
    t.string "slug"
    t.string "image_position_cd"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "website_id"
    t.text "admin_note"
    t.index ["page_id"], name: "index_page_blocks_on_page_id"
    t.index ["slug"], name: "index_page_blocks_on_slug", unique: true
    t.index ["website_id"], name: "index_page_blocks_on_website_id"
  end

  create_table "pages", id: :serial, force: :cascade do |t|
    t.string "title", null: false
    t.text "body", null: false
    t.boolean "published", default: false, null: false
    t.string "menu_cd"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "slug"
    t.integer "display_order"
    t.string "menu_text"
    t.bigint "website_id"
    t.index ["display_order"], name: "index_pages_on_display_order"
    t.index ["slug"], name: "index_pages_on_slug"
    t.index ["website_id"], name: "index_pages_on_website_id"
  end

  create_table "pg_search_documents", id: :serial, force: :cascade do |t|
    t.text "content"
    t.string "searchable_type"
    t.integer "searchable_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["searchable_type", "searchable_id"], name: "index_pg_search_documents_on_searchable_type_and_searchable_id"
  end

  create_table "place_pages", force: :cascade do |t|
    t.string "title", null: false
    t.text "body", null: false
    t.boolean "published", default: false, null: false
    t.string "slug"
    t.integer "display_order"
    t.bigint "place_id"
    t.string "menu_text"
    t.boolean "show_map"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["place_id"], name: "index_place_pages_on_place_id"
    t.index ["slug"], name: "index_place_pages_on_slug"
  end

  create_table "place_sources", force: :cascade do |t|
    t.string "name"
    t.string "url"
    t.string "file_name"
    t.string "place_source_type_cd"
  end

  create_table "places", force: :cascade do |t|
    t.string "name"
    t.integer "state_fips"
    t.integer "county_fips"
    t.integer "place_fips"
    t.integer "lsad"
    t.string "place_type_cd"
    t.decimal "latitude"
    t.decimal "longitude"
    t.geometry "geom", limit: {:srid=>4326, :type=>"geometry"}
    t.string "place_source_type_cd"
    t.bigint "place_source_id"
    t.string "huc8"
    t.string "uc_campus"
    t.string "gnis_id"
    t.string "us_l4code"
    t.string "us_l4name"
    t.string "us_l3code"
    t.string "us_l3name"
    t.string "na_l3code"
    t.string "na_l3name"
    t.string "na_l2code"
    t.string "na_l2name"
    t.string "na_l1code"
    t.string "na_l1name"
    t.geometry "geom_projected", limit: {:srid=>3857, :type=>"geometry"}
    t.index "lower((name)::text) text_pattern_ops", name: "index_places_on_name"
    t.index ["geom"], name: "index_places_on_geom", using: :gist
    t.index ["geom_projected"], name: "index_places_on_geom_projected", using: :gist
    t.index ["place_source_id"], name: "index_places_on_place_source_id"
    t.index ["place_source_type_cd"], name: "places_place_source_type_cd_idx"
    t.index ["place_type_cd"], name: "places_place_type_cd_idx"
  end

  create_table "primers", force: :cascade do |t|
    t.string "name", null: false
    t.text "forward_primer"
    t.text "reverse_primer"
    t.text "reference"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "research_project_authors", force: :cascade do |t|
    t.bigint "research_project_id"
    t.string "authorable_type"
    t.integer "authorable_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["authorable_id"], name: "index_research_project_authors_on_authorable_id"
    t.index ["research_project_id"], name: "index_research_project_authors_on_research_project_id"
  end

  create_table "research_project_pages", force: :cascade do |t|
    t.string "title", null: false
    t.text "body", null: false
    t.boolean "published", default: false, null: false
    t.string "slug"
    t.integer "display_order"
    t.bigint "research_project_id"
    t.string "menu_text"
    t.boolean "show_map"
    t.boolean "show_edna_results_metadata"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["research_project_id"], name: "index_research_project_pages_on_research_project_id"
    t.index ["slug"], name: "index_research_project_pages_on_slug"
  end

  create_table "research_project_sources", id: :serial, force: :cascade do |t|
    t.integer "research_project_id"
    t.integer "sourceable_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "sample_id"
    t.string "sourceable_type"
    t.jsonb "metadata", default: {}
    t.index "((metadata ->> 'location'::text))", name: "idx_rps_metadata_location"
    t.index ["research_project_id"], name: "index_research_project_sources_on_research_project_id"
    t.index ["sample_id"], name: "index_research_project_sources_on_sample_id"
    t.index ["sourceable_id"], name: "index_research_project_sources_on_sourceable_id"
    t.index ["sourceable_type"], name: "index_research_project_sources_on_sourceable_type"
  end

  create_table "research_projects", id: :serial, force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "published", default: false
    t.string "slug"
    t.text "reference_barcode_database"
    t.string "dryad_link"
    t.text "decontamination_method"
    t.jsonb "metadata", default: {}
    t.decimal "map_latitude"
    t.decimal "map_longitude"
    t.integer "map_zoom"
    t.string "primers", array: true
  end

  create_table "researchers", id: :serial, force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "username", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet "current_sign_in_ip"
    t.inet "last_sign_in_ip"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "invitation_token"
    t.datetime "invitation_created_at"
    t.datetime "invitation_sent_at"
    t.datetime "invitation_accepted_at"
    t.integer "invitation_limit"
    t.string "invited_by_type"
    t.integer "invited_by_id"
    t.integer "invitations_count", default: 0
    t.string "role_cd", default: "sample_processor"
    t.boolean "active", default: true
    t.integer "failed_attempts", default: 0, null: false
    t.string "unlock_token"
    t.datetime "locked_at"
    t.string "orcid"
    t.index ["email"], name: "index_researchers_on_email", unique: true
    t.index ["invitation_token"], name: "index_researchers_on_invitation_token", unique: true
    t.index ["invitations_count"], name: "index_researchers_on_invitations_count"
    t.index ["invited_by_id"], name: "index_researchers_on_invited_by_id"
    t.index ["reset_password_token"], name: "index_researchers_on_reset_password_token", unique: true
    t.index ["unlock_token"], name: "index_researchers_on_unlock_token", unique: true
  end

  create_table "result_taxa", id: :serial, force: :cascade do |t|
    t.string "taxon_rank"
    t.jsonb "hierarchy"
    t.boolean "normalized"
    t.integer "taxon_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "ignore", default: false
    t.text "original_taxonomy_string", array: true
    t.string "clean_taxonomy_string"
    t.text "result_sources", default: [], array: true
    t.boolean "exact_match", default: true
    t.integer "ncbi_id"
    t.integer "bold_id"
    t.integer "ncbi_version_id"
    t.string "canonical_name"
    t.string "match_type_cd"
    t.string "clean_taxonomy_string_phylum"
    t.index ["clean_taxonomy_string"], name: "index_result_taxa_on_clean_taxonomy_string"
    t.index ["clean_taxonomy_string_phylum"], name: "index_result_taxa_on_clean_taxonomy_string_phylum"
    t.index ["ignore"], name: "index_result_taxa_on_ignore"
    t.index ["taxon_id"], name: "index_result_taxa_on_taxon_id"
    t.index ["taxon_rank"], name: "index_result_taxa_on_taxon_rank"
  end

  create_table "result_taxa_with_pcr", id: false, force: :cascade do |t|
    t.integer "id"
    t.string "taxon_rank"
    t.jsonb "hierarchy"
    t.boolean "normalized"
    t.integer "taxon_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean "ignore"
    t.text "original_taxonomy_string", array: true
    t.string "clean_taxonomy_string"
    t.text "result_sources", array: true
    t.boolean "exact_match"
    t.integer "ncbi_id"
    t.integer "bold_id"
    t.integer "ncbi_version_id"
    t.string "canonical_name"
  end

  create_table "sample_primers", force: :cascade do |t|
    t.bigint "sample_id"
    t.bigint "primer_id"
    t.bigint "research_project_id"
    t.index ["primer_id"], name: "index_sample_primers_on_primer_id"
    t.index ["research_project_id"], name: "index_sample_primers_on_research_project_id"
    t.index ["sample_id"], name: "index_sample_primers_on_sample_id"
  end

  create_table "samples", id: :serial, force: :cascade do |t|
    t.integer "field_project_id"
    t.integer "kobo_id"
    t.decimal "latitude"
    t.decimal "longitude"
    t.datetime "submission_date"
    t.string "barcode"
    t.jsonb "kobo_data", default: {}
    t.text "field_notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "collection_date"
    t.string "status_cd", default: "submitted"
    t.string "substrate_cd"
    t.decimal "altitude"
    t.integer "gps_precision"
    t.string "location"
    t.text "director_notes"
    t.string "habitat_cd"
    t.string "depth_cd"
    t.boolean "missing_coordinates", default: false
    t.jsonb "metadata", default: {}
    t.string "primers", default: [], array: true
    t.jsonb "csv_data", default: {}
    t.string "country", default: "United States of America"
    t.string "country_code", default: "US"
    t.boolean "has_permit", default: true
    t.string "environmental_features", default: [], array: true
    t.string "environmental_settings", default: [], array: true
    t.geometry "geom", limit: {:srid=>4326, :type=>"st_point"}
    t.integer "taxa_count"
    t.integer "primer_ids", default: [], array: true
    t.geometry "geom_projected", limit: {:srid=>3857, :type=>"geometry"}
    t.index "((metadata ->> 'month'::text))", name: "idx_samples_metadata_month"
    t.index ["field_project_id"], name: "index_samples_on_field_project_id"
    t.index ["geom"], name: "index_samples_on_geom", using: :gist
    t.index ["geom_projected"], name: "index_samples_on_geom_projected", using: :gist
    t.index ["latitude", "longitude"], name: "index_samples_on_latitude_and_longitude"
    t.index ["metadata"], name: "samples_metadata_idx", using: :gin
    t.index ["primers"], name: "index_samples_on_primer", using: :gin
    t.index ["status_cd"], name: "index_samples_on_status_cd"
  end

  create_table "samples_prod", id: false, force: :cascade do |t|
    t.integer "id"
    t.integer "field_project_id"
    t.integer "kobo_id"
    t.decimal "latitude"
    t.decimal "longitude"
    t.datetime "submission_date"
    t.string "barcode"
    t.jsonb "kobo_data"
    t.text "field_notes"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "collection_date"
    t.string "status_cd"
    t.string "substrate_cd"
    t.decimal "altitude"
    t.integer "gps_precision"
    t.string "location"
    t.text "director_notes"
    t.string "habitat_cd"
    t.string "depth_cd"
    t.boolean "missing_coordinates"
    t.jsonb "metadata"
    t.string "primers", array: true
    t.jsonb "csv_data"
    t.string "country"
    t.string "country_code"
    t.boolean "has_permit"
    t.string "environmental_features", array: true
    t.string "environmental_settings", array: true
  end

  create_table "samples_rollback", id: false, force: :cascade do |t|
    t.integer "id"
    t.integer "field_project_id"
    t.integer "kobo_id"
    t.decimal "latitude"
    t.decimal "longitude"
    t.datetime "submission_date"
    t.string "barcode"
    t.jsonb "kobo_data"
    t.text "field_notes"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "collection_date"
    t.string "status_cd"
    t.string "substrate_cd"
    t.decimal "altitude"
    t.integer "gps_precision"
    t.string "location"
    t.text "director_notes"
    t.string "habitat_cd"
    t.string "depth_cd"
    t.boolean "missing_coordinates"
    t.jsonb "metadata"
    t.string "primers", array: true
    t.jsonb "csv_data"
    t.string "country"
    t.string "country_code"
    t.boolean "has_permit"
    t.string "environmental_features", array: true
    t.string "environmental_settings", array: true
  end

  create_table "site_news", force: :cascade do |t|
    t.string "title", null: false
    t.text "body", null: false
    t.boolean "published", default: false
    t.bigint "website_id"
    t.datetime "published_date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["website_id"], name: "index_site_news_on_website_id"
  end

  create_table "survey_answers", force: :cascade do |t|
    t.bigint "survey_question_id", null: false
    t.bigint "survey_response_id", null: false
    t.jsonb "content", default: {}, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "score", default: 0
    t.index ["survey_question_id"], name: "index_survey_answers_on_survey_question_id"
    t.index ["survey_response_id"], name: "index_survey_answers_on_survey_response_id"
  end

  create_table "survey_options", force: :cascade do |t|
    t.text "content", null: false
    t.bigint "survey_question_id", null: false
    t.boolean "accepted_answer", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["survey_question_id"], name: "index_survey_options_on_survey_question_id"
  end

  create_table "survey_questions", force: :cascade do |t|
    t.text "content", null: false
    t.bigint "survey_id", null: false
    t.string "type_cd", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "order_number"
    t.index ["survey_id"], name: "index_survey_questions_on_survey_id"
  end

  create_table "survey_responses", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "survey_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "total_score", default: 0
    t.boolean "passed", default: false
    t.index ["survey_id"], name: "index_survey_responses_on_survey_id"
    t.index ["user_id"], name: "index_survey_responses_on_user_id"
  end

  create_table "surveys", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "slug"
    t.text "description"
    t.integer "passing_score", default: 0
    t.index ["slug"], name: "index_surveys_on_slug"
  end

  create_table "unmatched_results", force: :cascade do |t|
    t.string "taxonomy_string"
    t.string "clean_taxonomy_string"
    t.bigint "primer_id"
    t.bigint "research_project_id"
    t.boolean "normalized"
    t.index ["primer_id"], name: "index_unmatched_results_on_primer_id"
    t.index ["research_project_id"], name: "index_unmatched_results_on_research_project_id"
  end

  create_table "uploads", force: :cascade do |t|
    t.string "filename"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "user_submissions", force: :cascade do |t|
    t.bigint "user_id"
    t.string "user_display_name", null: false
    t.string "title", null: false
    t.text "user_bio"
    t.text "content", null: false
    t.string "media_url"
    t.string "twitter"
    t.string "facebook"
    t.string "instagram"
    t.string "website"
    t.boolean "approved", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "embed_code"
    t.string "email"
    t.index ["user_id"], name: "index_user_submissions_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string "unconfirmed_email"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "username", null: false
    t.string "name"
    t.string "location"
    t.integer "age"
    t.string "gender_cd"
    t.string "education_cd"
    t.string "ethnicity"
    t.boolean "conservation_experience"
    t.boolean "dna_experience"
    t.text "work_info"
    t.string "time_outdoors_cd"
    t.string "occupation"
    t.text "science_career_goals"
    t.text "environmental_career_goals"
    t.boolean "uc_affiliation"
    t.string "uc_campus"
    t.string "caledna_source"
    t.boolean "agree", null: false
    t.boolean "can_contact", default: false, null: false
    t.text "spam"
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["username"], name: "index_users_on_username", unique: true
  end

  create_table "websites", force: :cascade do |t|
    t.string "name", null: false
    t.integer "taxa_count"
    t.integer "species_count"
    t.integer "families_count"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_foreign_key "asvs", "primers"
  add_foreign_key "asvs", "research_projects"
  add_foreign_key "asvs", "samples"
  add_foreign_key "asvs", "primers"
  add_foreign_key "asvs", "research_projects"
  add_foreign_key "asvs", "samples"
  add_foreign_key "event_registrations", "events"
  add_foreign_key "event_registrations", "users"
  add_foreign_key "events", "field_projects"
  add_foreign_key "kobo_photos", "samples"
  add_foreign_key "ncbi_deleted_taxa", "ncbi_versions"
  add_foreign_key "ncbi_merged_taxa", "ncbi_versions"
  add_foreign_key "ncbi_names", "ncbi_versions"
  add_foreign_key "ncbi_names", "ncbi_versions"
  add_foreign_key "ncbi_nodes", "ncbi_versions"
  add_foreign_key "ncbi_nodes", "ncbi_versions"
  add_foreign_key "page_blocks", "websites"
  add_foreign_key "pages", "websites"
  add_foreign_key "research_project_authors", "research_projects"
  add_foreign_key "research_project_sources", "research_projects"
  add_foreign_key "sample_primers", "primers"
  add_foreign_key "sample_primers", "research_projects"
  add_foreign_key "sample_primers", "samples"
  add_foreign_key "samples", "field_projects"
  add_foreign_key "site_news", "websites"
  add_foreign_key "survey_answers", "survey_questions"
  add_foreign_key "survey_answers", "survey_responses"
  add_foreign_key "survey_options", "survey_questions"
  add_foreign_key "survey_questions", "surveys"
  add_foreign_key "survey_responses", "surveys"
  add_foreign_key "user_submissions", "users"
end
