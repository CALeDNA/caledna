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

ActiveRecord::Schema.define(version: 2019_08_29_122240) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_stat_statements"
  enable_extension "plpgsql"

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

  create_table "asvs", id: :serial, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "extraction_id"
    t.integer "taxonID"
    t.text "primers", default: [], array: true
    t.integer "sample_id"
    t.integer "count", default: 0
    t.jsonb "counts", default: {}
    t.index ["extraction_id"], name: "index_asvs_on_extraction_id"
    t.index ["sample_id"], name: "index_asvs_on_sample_id"
    t.index ["taxonID"], name: "index_asvs_on_taxonID"
  end

  create_table "cal_taxa", id: :serial, force: :cascade do |t|
    t.string "datasetID"
    t.string "parentNameUsageID"
    t.text "scientificName"
    t.string "canonicalName"
    t.string "taxonRank"
    t.string "taxonomicStatus"
    t.string "kingdom"
    t.string "phylum"
    t.string "className"
    t.string "order"
    t.string "family"
    t.string "genus"
    t.string "specificEpithet"
    t.jsonb "hierarchy"
    t.string "original_taxonomy_phylum"
    t.jsonb "original_hierarchy"
    t.boolean "normalized"
    t.integer "taxonID"
    t.string "genericName"
    t.string "complete_taxonomy"
    t.integer "rank_order"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "exact_gbif_match"
    t.text "notes"
    t.string "original_taxonomy_superkingdom"
    t.boolean "accepted", default: false
    t.index ["kingdom", "canonicalName"], name: "cal_taxa_kingdom_canonicalName_idx1", unique: true
    t.index ["original_taxonomy_phylum"], name: "index_cal_taxa_on_original_taxonomy_phylum"
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
    t.index ["source_taxon_id"], name: "index_combine_taxa_on_source_taxon_id"
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
    t.bigint "field_data_project_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["field_data_project_id"], name: "index_events_on_field_data_project_id"
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
    t.index ["gbif_id"], name: "index_external_resources_on_gbif_id"
    t.index ["ncbi_id"], name: "index_external_resources_on_ncbi_id"
    t.index ["source"], name: "index_external_resources_on_source"
  end

  create_table "extraction_types", id: :serial, force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "extractions", id: :serial, force: :cascade do |t|
    t.integer "sample_id"
    t.integer "extraction_type_id"
    t.integer "processor_id"
    t.string "priority_sequencing_cd"
    t.boolean "prepub_share", default: false
    t.string "prepub_share_group"
    t.boolean "prepub_filter_sensitive_info", default: false
    t.string "sra_url"
    t.integer "sra_adder_id"
    t.datetime "sra_add_date"
    t.string "local_fastq_storage_url"
    t.integer "local_fastq_storage_adder_id"
    t.datetime "local_fastq_storage_add_date"
    t.datetime "stat_bio_reps_pooled_date"
    t.string "loc_bio_reps_pooled"
    t.datetime "bio_reps_pooled_date"
    t.string "protocol_bio_reps_pooled"
    t.string "changes_protocol_bio_reps_pooled"
    t.datetime "stat_dna_extraction_date"
    t.string "loc_dna_extracts"
    t.datetime "dna_extraction_date"
    t.string "protocol_dna_extraction"
    t.string "changes_protocol_dna_extraction"
    t.string "metabarcoding_primers", default: [], array: true
    t.datetime "stat_barcoding_pcr_done_date"
    t.integer "barcoding_pcr_number_of_replicates"
    t.string "reamps_needed"
    t.datetime "stat_barcoding_pcr_pooled_date"
    t.datetime "stat_barcoding_pcr_bead_cleaned_date"
    t.string "brand_beads_cd"
    t.string "cleaned_concentration"
    t.string "loc_stored"
    t.string "select_indices_cd"
    t.string "index_1_name"
    t.string "index_2_name"
    t.datetime "stat_index_pcr_done_date"
    t.datetime "stat_index_pcr_bead_cleaned_date"
    t.string "index_brand_beads_cd"
    t.string "index_cleaned_concentration"
    t.string "index_loc_stored"
    t.datetime "stat_libraries_pooled_date"
    t.string "loc_libraries_pooled"
    t.datetime "stat_sequenced_date"
    t.string "intended_sequencing_depth_per_barcode"
    t.string "sequencing_platform"
    t.text "assoc_field_blank"
    t.text "assoc_extraction_blank"
    t.text "assoc_pcr_blank"
    t.text "sample_processor_notes"
    t.text "lab_manager_notes"
    t.text "director_notes"
    t.string "status_cd"
    t.string "sum_taxonomy_example"
    t.boolean "priority_sequencing"
    t.datetime "created_at", default: "2018-04-23 16:12:39", null: false
    t.datetime "updated_at", default: "2018-04-23 16:12:39", null: false
    t.index ["extraction_type_id"], name: "index_extractions_on_extraction_type_id"
    t.index ["local_fastq_storage_adder_id"], name: "index_extractions_on_local_fastq_storage_adder_id"
    t.index ["processor_id"], name: "index_extractions_on_processor_id"
    t.index ["sample_id"], name: "index_extractions_on_sample_id"
    t.index ["sra_adder_id"], name: "index_extractions_on_sra_adder_id"
  end

  create_table "field_data_projects", id: :serial, force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.integer "kobo_id"
    t.jsonb "kobo_payload"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "last_import_date"
    t.string "date_range"
    t.boolean "published", default: true
    t.index ["kobo_id"], name: "index_field_data_projects_on_kobo_id", unique: true
  end

  create_table "highlights", id: :serial, force: :cascade do |t|
    t.string "notes"
    t.integer "highlightable_id"
    t.string "highlightable_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["highlightable_id"], name: "index_highlights_on_highlightable_id"
    t.index ["highlightable_type"], name: "index_highlights_on_highlightable_type"
  end

  create_table "ncbi_divisions", id: :serial, force: :cascade do |t|
    t.string "cde", limit: 255
    t.string "name", limit: 255
    t.string "comments", limit: 255
  end

  create_table "ncbi_names", id: false, force: :cascade do |t|
    t.integer "taxon_id", null: false
    t.text "name"
    t.string "unique_name", limit: 255
    t.string "name_class", limit: 255
    t.index "lower(name)", name: "index_ncbi_names_on_name"
    t.index ["name_class"], name: "index_ncbi_names_on_name_class"
    t.index ["taxon_id"], name: "ncbi_names_taxonid_idx"
  end

  create_table "ncbi_nodes", primary_key: "taxon_id", id: :integer, default: nil, force: :cascade do |t|
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
    t.index "((hierarchy_names -> 'class'::text))", name: "ncbi_nodes_expr_idx1"
    t.index "((hierarchy_names -> 'order'::text))", name: "ncbi_nodes_expr_idx2"
    t.index "((hierarchy_names -> 'phylum'::text))", name: "ncbi_nodes_expr_idx"
    t.index "((to_tsvector('simple'::regconfig, (canonical_name)::text) || to_tsvector('english'::regconfig, (COALESCE(alt_names, ''::character varying))::text)))", name: "idx_taxa_search", using: :gin
    t.index "lower((canonical_name)::text)", name: "index_ncbi_nodes_on_canonical_name"
    t.index "lower(replace((canonical_name)::text, ''''::text, ''::text))", name: "boo"
    t.index ["asvs_count"], name: "index_ncbi_nodes_on_asvs_count"
    t.index ["asvs_count_5"], name: "index_ncbi_nodes_on_asvs_count_5"
    t.index ["asvs_count_la_river"], name: "index_ncbi_nodes_on_asvs_count_la_river"
    t.index ["asvs_count_la_river_5"], name: "index_ncbi_nodes_on_asvs_count_la_river_5"
    t.index ["bold_id"], name: "index_ncbi_nodes_on_bold_id"
    t.index ["cal_division_id"], name: "index_ncbi_nodes_on_cal_division_id"
    t.index ["division_id"], name: "ncbi_nodes_divisionid_idx"
    t.index ["hierarchy"], name: "index_taxa_on_hierarchy", using: :gin
    t.index ["hierarchy_names"], name: "ncbi_nodes_hierarchy_names_idx", using: :gin
    t.index ["ids"], name: "idx_ncbi_nodes_ids", using: :gin
    t.index ["ncbi_id"], name: "index_ncbi_nodes_on_ncbi_id"
    t.index ["parent_taxon_id"], name: "index_ncbi_nodes_on_parent_taxon_id"
    t.index ["rank"], name: "index_ncbi_nodes_on_rank"
    t.index ["short_taxonomy_string"], name: "ncbi_nodes_short_taxonomy_string_idx"
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
    t.integer "research_project_id"
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

  create_table "photos", id: :serial, force: :cascade do |t|
    t.string "source_url"
    t.string "file_name"
    t.integer "sample_id"
    t.jsonb "kobo_payload"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "height"
    t.integer "width"
    t.index ["sample_id"], name: "index_photos_on_sample_id"
  end

  create_table "raw_taxonomy_imports", force: :cascade do |t|
    t.string "name"
    t.string "taxonomy_string"
    t.string "primer"
    t.text "notes"
    t.bigint "research_project_id"
    t.index ["research_project_id"], name: "index_raw_taxonomy_imports_on_research_project_id"
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
    t.string "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "published", default: false
    t.string "slug"
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
    t.index ["email"], name: "index_researchers_on_email", unique: true
    t.index ["invitation_token"], name: "index_researchers_on_invitation_token", unique: true
    t.index ["invitations_count"], name: "index_researchers_on_invitations_count"
    t.index ["invited_by_id"], name: "index_researchers_on_invited_by_id"
    t.index ["reset_password_token"], name: "index_researchers_on_reset_password_token", unique: true
    t.index ["unlock_token"], name: "index_researchers_on_unlock_token", unique: true
  end

  create_table "samples", id: :serial, force: :cascade do |t|
    t.integer "field_data_project_id"
    t.integer "kobo_id"
    t.decimal "latitude"
    t.decimal "longitude"
    t.datetime "submission_date"
    t.string "barcode"
    t.jsonb "kobo_data", default: "{}"
    t.text "field_notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "collection_date"
    t.string "status_cd", default: "submitted"
    t.string "substrate_cd"
    t.string "ecosystem_category_cd"
    t.string "alt_id"
    t.decimal "altitude"
    t.integer "gps_precision"
    t.string "location"
    t.decimal "elevatr_altitude"
    t.text "director_notes"
    t.string "habitat"
    t.string "depth"
    t.string "environmental_features"
    t.string "environmental_settings"
    t.boolean "missing_coordinates", default: false
    t.jsonb "metadata", default: {}
    t.index "((metadata ->> 'month'::text))", name: "idx_samples_metadata_month"
    t.index ["field_data_project_id"], name: "index_samples_on_field_data_project_id"
    t.index ["latitude", "longitude"], name: "index_samples_on_latitude_and_longitude"
    t.index ["metadata"], name: "samples_metadata_idx", using: :gin
    t.index ["status_cd"], name: "index_samples_on_status_cd"
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

  create_table "taxa_search_caches", force: :cascade do |t|
    t.integer "taxon_id"
    t.integer "sample_ids", array: true
    t.integer "asvs_count"
    t.string "rank"
    t.string "canonical_name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "asvs_count_5", default: 0
    t.integer "asvs_count_la_river", default: 0
    t.integer "asvs_count_la_river_5", default: 0
    t.integer "sample_ids_5", default: [], array: true
    t.integer "sample_ids_la_river", default: [], array: true
    t.integer "sample_ids_la_river_5", default: [], array: true
  end

  create_table "uploads", force: :cascade do |t|
    t.string "filename"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
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
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["username"], name: "index_users_on_username", unique: true
  end

  create_table "websites", force: :cascade do |t|
    t.string "name", null: false
  end

  add_foreign_key "asvs", "extractions"
  add_foreign_key "extractions", "extraction_types"
  add_foreign_key "extractions", "researchers", column: "local_fastq_storage_adder_id"
  add_foreign_key "extractions", "researchers", column: "processor_id"
  add_foreign_key "extractions", "researchers", column: "sra_adder_id"
  add_foreign_key "extractions", "samples"
  add_foreign_key "ncbi_nodes", "ncbi_divisions", column: "cal_division_id"
  add_foreign_key "photos", "samples"
  add_foreign_key "research_project_authors", "research_projects"
  add_foreign_key "research_project_sources", "research_projects"
  add_foreign_key "samples", "field_data_projects"
end
