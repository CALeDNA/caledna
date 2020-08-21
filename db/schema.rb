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

ActiveRecord::Schema.define(version: 2020_08_21_190922) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "postgis"

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
    t.index ["primer_id"], name: "index_asvs_on_primer_id"
    t.index ["research_project_id"], name: "index_asvs_on_research_project_id"
    t.index ["sample_id"], name: "index_asvs_on_sample_id"
    t.index ["taxon_id"], name: "index_asvs_on_taxon_id"
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
    t.string "iucn_status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
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
    t.index ["gbif_id"], name: "index_external_resources_on_gbif_id"
    t.index ["ncbi_id"], name: "index_external_resources_on_ncbi_id"
    t.index ["source"], name: "index_external_resources_on_source"
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

  create_table "highlights", id: :serial, force: :cascade do |t|
    t.string "notes"
    t.integer "highlightable_id"
    t.string "highlightable_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["highlightable_id"], name: "index_highlights_on_highlightable_id"
    t.index ["highlightable_type"], name: "index_highlights_on_highlightable_type"
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

  create_table "ncbi_divisions", id: :serial, force: :cascade do |t|
    t.string "cde", limit: 255
    t.string "name", limit: 255
    t.string "comments", limit: 255
  end

  create_table "ncbi_names", force: :cascade do |t|
    t.integer "taxon_id"
    t.text "name"
    t.string "unique_name"
    t.string "name_class"
    t.bigint "ncbi_version_id"
    t.datetime "created_at", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.datetime "updated_at", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.index "lower(name)", name: "index_ncbi_names_on_lower_name"
    t.index ["name_class"], name: "index_ncbi_names_on_name_class"
    t.index ["ncbi_version_id"], name: "index_ncbi_names_on_ncbi_version_id"
    t.index ["taxon_id"], name: "index_ncbi_names_on_taxon_id"
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
    t.index "((to_tsvector('simple'::regconfig, (canonical_name)::text) || to_tsvector('english'::regconfig, (COALESCE(alt_names, ''::character varying))::text)))", name: "full_text_search_idx", using: :gin
    t.index "lower((canonical_name)::text) text_pattern_ops", name: "name_autocomplete_idx"
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

  create_table "page_blocks", force: :cascade do |t|
    t.text "content"
    t.bigint "page_id"
    t.string "slug"
    t.string "image_position_cd"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "website_id"
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

  create_table "pghero_query_stats", force: :cascade do |t|
    t.text "database"
    t.text "user"
    t.text "query"
    t.bigint "query_hash"
    t.float "total_time"
    t.bigint "calls"
    t.datetime "captured_at"
    t.index ["database", "captured_at"], name: "index_pghero_query_stats_on_database_and_captured_at"
  end

  create_table "pghero_space_stats", force: :cascade do |t|
    t.text "database"
    t.text "schema"
    t.text "relation"
    t.bigint "size"
    t.datetime "captured_at"
    t.index ["database", "captured_at"], name: "index_pghero_space_stats_on_database_and_captured_at"
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
    t.index "lower((name)::text) text_pattern_ops", name: "index_places_on_name"
    t.index ["geom"], name: "index_places_on_geom", using: :gist
    t.index ["place_source_id"], name: "index_places_on_place_source_id"
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
    t.string "primers", default: [], array: true
    t.decimal "map_latitude"
    t.decimal "map_longitude"
    t.integer "map_zoom"
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
    t.index ["invited_by_type", "invited_by_id"], name: "index_researchers_on_invited_by_type_and_invited_by_id"
    t.index ["reset_password_token"], name: "index_researchers_on_reset_password_token", unique: true
    t.index ["unlock_token"], name: "index_researchers_on_unlock_token", unique: true
  end

  create_table "result_raw_imports", force: :cascade do |t|
    t.string "original_taxonomy_string"
    t.string "clean_taxonomy_string"
    t.string "canonical_name"
    t.string "primer"
    t.bigint "research_project_id"
    t.jsonb "payload"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["research_project_id"], name: "index_result_raw_imports_on_research_project_id"
  end

  create_table "result_taxa", id: :integer, default: -> { "nextval('cal_taxa_taxonid_seq'::regclass)" }, force: :cascade do |t|
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
    t.index "((metadata ->> 'month'::text))", name: "idx_samples_metadata_month"
    t.index ["field_project_id"], name: "index_samples_on_field_project_id"
    t.index ["geom"], name: "index_samples_on_geom", using: :gist
    t.index ["latitude", "longitude"], name: "index_samples_on_latitude_and_longitude"
    t.index ["metadata"], name: "samples_metadata_idx", using: :gin
    t.index ["primers"], name: "index_samples_on_primer", using: :gin
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
  end

  add_foreign_key "asvs", "primers"
  add_foreign_key "asvs", "research_projects"
  add_foreign_key "asvs", "samples"
  add_foreign_key "event_registrations", "events"
  add_foreign_key "event_registrations", "users"
  add_foreign_key "events", "field_projects"
  add_foreign_key "kobo_photos", "samples"
  add_foreign_key "ncbi_names", "external.ncbi_versions", column: "ncbi_version_id"
  add_foreign_key "ncbi_nodes", "external.ncbi_versions", column: "ncbi_version_id"
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
end
