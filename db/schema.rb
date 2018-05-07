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

ActiveRecord::Schema.define(version: 20180507012855) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "asvs", force: :cascade do |t|
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
    t.integer  "extraction_id"
    t.integer  "taxonID"
    t.text     "primers",       default: [],              array: true
    t.index ["extraction_id"], name: "index_asvs_on_extraction_id", using: :btree
    t.index ["taxonID"], name: "index_asvs_on_taxonID", using: :btree
  end

  create_table "cal_taxa", id: :integer, default: -> { "nextval('cal_taxa_taxonid_seq'::regclass)" }, force: :cascade do |t|
    t.string   "datasetID"
    t.string   "parentNameUsageID"
    t.text     "scientificName"
    t.string   "canonicalName"
    t.string   "taxonRank"
    t.string   "taxonomicStatus"
    t.string   "kingdom"
    t.string   "phylum"
    t.string   "className"
    t.string   "order"
    t.string   "family"
    t.string   "genus"
    t.string   "specificEpithet"
    t.jsonb    "hierarchy"
    t.string   "original_taxonomy"
    t.jsonb    "original_hierarchy"
    t.boolean  "normalized",         default: false
    t.string   "genericName"
    t.integer  "taxonID",            default: -> { "currval('cal_taxa_taxonid_seq'::regclass)" }
    t.string   "complete_taxonomy"
    t.integer  "rank_order"
    t.datetime "created_at",         default: '2018-05-07 02:05:46',                              null: false
    t.datetime "updated_at",         default: '2018-05-07 02:05:46',                              null: false
    t.boolean  "exact_gbif_match",   default: false
    t.index ["kingdom", "canonicalName"], name: "index_cal_taxa_on_kingdom_and_canonicalName", unique: true, using: :btree
  end

  create_table "extraction_types", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "extractions", force: :cascade do |t|
    t.integer  "sample_id"
    t.integer  "extraction_type_id"
    t.integer  "processor_id"
    t.string   "priority_sequencing_cd"
    t.boolean  "prepub_share",                          default: false
    t.string   "prepub_share_group"
    t.boolean  "prepub_filter_sensitive_info",          default: false
    t.string   "sra_url"
    t.integer  "sra_adder_id"
    t.datetime "sra_add_date"
    t.string   "local_fastq_storage_url"
    t.integer  "local_fastq_storage_adder_id"
    t.datetime "local_fastq_storage_add_date"
    t.boolean  "stat_bio_reps_pooled",                  default: false
    t.datetime "stat_bio_reps_pooled_date"
    t.string   "loc_bio_reps_pooled"
    t.datetime "bio_reps_pooled_date"
    t.string   "protocol_bio_reps_pooled"
    t.string   "changes_protocol_bio_reps_pooled"
    t.boolean  "stat_dna_extraction",                   default: false
    t.datetime "stat_dna_extraction_date"
    t.string   "loc_dna_extracts"
    t.datetime "dna_extraction_date"
    t.string   "protocol_dna_extraction"
    t.string   "changes_protocol_dna_extraction"
    t.string   "metabarcoding_primers",                 default: [],                                 array: true
    t.boolean  "stat_barcoding_pcr_done",               default: false
    t.datetime "stat_barcoding_pcr_done_date"
    t.integer  "barcoding_pcr_number_of_replicates"
    t.string   "reamps_needed"
    t.boolean  "stat_barcoding_pcr_pooled",             default: false
    t.datetime "stat_barcoding_pcr_pooled_date"
    t.boolean  "stat_barcoding_pcr_bead_cleaned",       default: false
    t.datetime "stat_barcoding_pcr_bead_cleaned_date"
    t.string   "brand_beads_cd"
    t.string   "cleaned_concentration"
    t.string   "loc_stored"
    t.string   "select_indices_cd"
    t.string   "index_1_name"
    t.string   "index_2_name"
    t.boolean  "stat_index_pcr_done",                   default: false
    t.datetime "stat_index_pcr_done_date"
    t.boolean  "stat_index_pcr_bead_cleaned",           default: false
    t.datetime "stat_index_pcr_bead_cleaned_date"
    t.string   "index_brand_beads_cd"
    t.string   "index_cleaned_concentration"
    t.string   "index_loc_stored"
    t.boolean  "stat_libraries_pooled",                 default: false
    t.datetime "stat_libraries_pooled_date"
    t.string   "loc_libraries_pooled"
    t.boolean  "stat_sequenced",                        default: false
    t.datetime "stat_sequenced_date"
    t.string   "intended_sequencing_depth_per_barcode"
    t.string   "sequencing_platform"
    t.text     "assoc_field_blank"
    t.text     "assoc_extraction_blank"
    t.text     "assoc_pcr_blank"
    t.text     "sample_processor_notes"
    t.text     "lab_manager_notes"
    t.text     "director_notes"
    t.string   "status_cd"
    t.string   "sum_taxonomy_example"
    t.boolean  "priority_sequencing"
    t.datetime "created_at",                            default: '2018-05-07 02:05:46', null: false
    t.datetime "updated_at",                            default: '2018-05-07 02:05:46', null: false
    t.index ["extraction_type_id"], name: "index_extractions_on_extraction_type_id", using: :btree
    t.index ["local_fastq_storage_adder_id"], name: "index_extractions_on_local_fastq_storage_adder_id", using: :btree
    t.index ["processor_id"], name: "index_extractions_on_processor_id", using: :btree
    t.index ["sample_id"], name: "index_extractions_on_sample_id", using: :btree
    t.index ["sra_adder_id"], name: "index_extractions_on_sra_adder_id", using: :btree
  end

  create_table "field_data_projects", force: :cascade do |t|
    t.string   "name"
    t.text     "description"
    t.integer  "kobo_id"
    t.jsonb    "kobo_payload"
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
    t.datetime "last_import_date"
    t.string   "date_range"
    t.index ["kobo_id"], name: "index_field_data_projects_on_kobo_id", unique: true, using: :btree
  end

  create_table "highlights", force: :cascade do |t|
    t.string   "notes"
    t.integer  "highlightable_id"
    t.string   "highlightable_type"
    t.datetime "created_at",         null: false
    t.datetime "updated_at",         null: false
    t.index ["highlightable_id"], name: "index_highlights_on_highlightable_id", using: :btree
    t.index ["highlightable_type"], name: "index_highlights_on_highlightable_type", using: :btree
  end

  create_table "ncbi_citation_nodes", force: :cascade do |t|
    t.integer  "ncbi_citation_id"
    t.integer  "ncbi_node_id"
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
    t.index ["ncbi_citation_id"], name: "index_ncbi_citation_nodes_on_ncbi_citation_id", using: :btree
    t.index ["ncbi_node_id"], name: "index_ncbi_citation_nodes_on_ncbi_node_id", using: :btree
  end

  create_table "ncbi_citations", id: :integer, force: :cascade do |t|
    t.text    "citation_key"
    t.integer "pubmed_id"
    t.integer "medline_id"
    t.text    "url"
    t.text    "text"
    t.text    "taxon_id_list"
  end

  create_table "ncbi_names", id: false, force: :cascade do |t|
    t.integer "taxon_id",                null: false
    t.text    "name"
    t.string  "unique_name", limit: 255
    t.string  "name_class",  limit: 255
    t.index ["name_class"], name: "index_ncbi_names_on_name_class", using: :btree
    t.index ["taxon_id"], name: "ncbi_names_taxonid_idx", using: :btree
  end

  create_table "ncbi_nodes", primary_key: "taxon_id", id: :integer, force: :cascade do |t|
    t.integer "parent_taxon_id"
    t.string  "rank",                                 limit: 255
    t.string  "embl_code",                            limit: 255
    t.integer "division_id"
    t.boolean "inherited_division"
    t.integer "genetic_code_id"
    t.boolean "inherited_genetic_code"
    t.integer "mitochondrial_genetic_code_id"
    t.boolean "inherited_mitochondrial_genetic_code"
    t.boolean "genbank_hidden"
    t.boolean "hidden_subtree_root"
    t.text    "comments"
    t.string  "canonical_name"
    t.text    "lineage",                                                       array: true
    t.jsonb   "hierarchy",                                        default: {}
    t.index ["hierarchy"], name: "index_taxa_on_hierarchy", using: :gin
    t.index ["parent_taxon_id"], name: "index_ncbi_nodes_on_parent_taxon_id", using: :btree
    t.index ["rank"], name: "index_ncbi_nodes_on_rank", using: :btree
  end

  create_table "pg_search_documents", force: :cascade do |t|
    t.text     "content"
    t.string   "searchable_type"
    t.integer  "searchable_id"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
    t.index ["searchable_type", "searchable_id"], name: "index_pg_search_documents_on_searchable_type_and_searchable_id", using: :btree
  end

  create_table "photos", force: :cascade do |t|
    t.string   "source_url"
    t.string   "file_name"
    t.integer  "sample_id"
    t.jsonb    "kobo_payload"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
    t.integer  "height"
    t.integer  "width"
    t.index ["sample_id"], name: "index_photos_on_sample_id", using: :btree
  end

  create_table "research_project_extractions", force: :cascade do |t|
    t.integer  "research_project_id"
    t.integer  "extraction_id"
    t.datetime "created_at",          null: false
    t.datetime "updated_at",          null: false
    t.index ["extraction_id"], name: "index_research_project_extractions_on_extraction_id", using: :btree
    t.index ["research_project_id"], name: "index_research_project_extractions_on_research_project_id", using: :btree
  end

  create_table "research_projects", force: :cascade do |t|
    t.string   "name"
    t.string   "description"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  create_table "researchers", force: :cascade do |t|
    t.string   "email",                  default: "",                 null: false
    t.string   "encrypted_password",     default: "",                 null: false
    t.string   "username",               default: "",                 null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,                  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet     "current_sign_in_ip"
    t.inet     "last_sign_in_ip"
    t.datetime "created_at",                                          null: false
    t.datetime "updated_at",                                          null: false
    t.string   "invitation_token"
    t.datetime "invitation_created_at"
    t.datetime "invitation_sent_at"
    t.datetime "invitation_accepted_at"
    t.integer  "invitation_limit"
    t.string   "invited_by_type"
    t.integer  "invited_by_id"
    t.integer  "invitations_count",      default: 0
    t.string   "role_cd",                default: "sample_processor"
    t.boolean  "active",                 default: true
    t.index ["email"], name: "index_researchers_on_email", unique: true, using: :btree
    t.index ["invitation_token"], name: "index_researchers_on_invitation_token", unique: true, using: :btree
    t.index ["invitations_count"], name: "index_researchers_on_invitations_count", using: :btree
    t.index ["invited_by_id"], name: "index_researchers_on_invited_by_id", using: :btree
    t.index ["reset_password_token"], name: "index_researchers_on_reset_password_token", unique: true, using: :btree
  end

  create_table "samples", force: :cascade do |t|
    t.integer  "field_data_project_id"
    t.integer  "kobo_id"
    t.decimal  "latitude"
    t.decimal  "longitude"
    t.datetime "submission_date"
    t.string   "barcode"
    t.jsonb    "kobo_data",              default: "{}"
    t.text     "field_notes"
    t.datetime "created_at",                                   null: false
    t.datetime "updated_at",                                   null: false
    t.datetime "collection_date"
    t.string   "status_cd",              default: "submitted"
    t.string   "substrate_cd"
    t.string   "ecosystem_category_cd"
    t.string   "alt_id"
    t.decimal  "altitude"
    t.integer  "gps_precision"
    t.string   "location"
    t.decimal  "elevatr_altitude"
    t.text     "director_notes"
    t.string   "habitat"
    t.string   "depth"
    t.string   "environmental_features"
    t.string   "environmental_settings"
    t.index ["field_data_project_id"], name: "index_samples_on_field_data_project_id", using: :btree
    t.index ["status_cd"], name: "index_samples_on_status_cd", using: :btree
  end

  create_table "taxa", primary_key: "taxonID", id: :integer, force: :cascade do |t|
    t.string  "datasetID",                limit: 255
    t.integer "parentNameUsageID"
    t.integer "acceptedNameUsageID"
    t.integer "originalNameUsageID"
    t.text    "scientificName"
    t.text    "scientificNameAuthorship"
    t.string  "canonicalName",            limit: 255
    t.string  "genericName",              limit: 255
    t.string  "specificEpithet",          limit: 255
    t.string  "infraspecificEpithet",     limit: 255
    t.string  "taxonRank",                limit: 255
    t.string  "nameAccordingTo",          limit: 255
    t.text    "namePublishedIn"
    t.string  "taxonomicStatus",          limit: 255
    t.string  "nomenclaturalStatus",      limit: 255
    t.string  "taxonRemarks",             limit: 255
    t.string  "kingdom",                  limit: 255
    t.string  "phylum",                   limit: 255
    t.string  "className",                limit: 255
    t.string  "order",                    limit: 255
    t.string  "family",                   limit: 255
    t.string  "genus",                    limit: 255
    t.jsonb   "hierarchy"
    t.integer "asvs_count",                           default: 0
    t.integer "rank_order"
    t.string  "iucn_status"
    t.integer "iucn_taxonid"
    t.index "lower((\"canonicalName\")::text) text_pattern_ops", name: "canonicalname_prefix", using: :btree
    t.index "lower((\"canonicalName\")::text)", name: "taxon_canonicalname_idx", using: :btree
    t.index ["acceptedNameUsageID"], name: "taxa_acceptedNameUsageID_idx", using: :btree
    t.index ["asvs_count"], name: "index_taxa_on_asvs_count", using: :btree
    t.index ["canonicalName", "taxonRank"], name: "index_taxa_on_canonicalName_and_taxonRank", using: :btree
    t.index ["genus"], name: "index_taxa_on_genus", using: :btree
    t.index ["hierarchy"], name: "taxa_heirarchy_idx", using: :gin
    t.index ["iucn_status"], name: "index_taxa_on_iucn_status", using: :btree
    t.index ["kingdom"], name: "index_taxa_on_kingdom", using: :btree
    t.index ["phylum"], name: "index_taxa_on_phylum", using: :btree
    t.index ["scientificName"], name: "index_taxa_on_scientificName", using: :btree
    t.index ["taxonRank"], name: "index_taxa_on_taxonRank", using: :btree
    t.index ["taxonomicStatus"], name: "taxon_taxonomicstatus_idx", using: :btree
  end

  create_table "taxa_datasets", primary_key: "datasetID", id: :string, force: :cascade do |t|
    t.string "name"
    t.text   "citation"
  end

  create_table "vernaculars", id: false, force: :cascade do |t|
    t.integer "taxonID",                    null: false
    t.text    "vernacularName"
    t.string  "language",       limit: 255
    t.string  "country",        limit: 255
    t.string  "countryCode",    limit: 255
    t.string  "sex",            limit: 255
    t.string  "lifeStage",      limit: 255
    t.text    "source"
    t.index "lower(\"vernacularName\")", name: "vernacular_vernacularname_idx", using: :btree
    t.index ["language"], name: "index_vernaculars_on_language", using: :btree
    t.index ["taxonID"], name: "vernacular_taxonid_idx", using: :btree
  end

  add_foreign_key "asvs", "extractions"
  add_foreign_key "extractions", "extraction_types"
  add_foreign_key "extractions", "researchers", column: "local_fastq_storage_adder_id"
  add_foreign_key "extractions", "researchers", column: "processor_id"
  add_foreign_key "extractions", "researchers", column: "sra_adder_id"
  add_foreign_key "extractions", "samples"
  add_foreign_key "photos", "samples"
  add_foreign_key "research_project_extractions", "extractions"
  add_foreign_key "research_project_extractions", "research_projects"
  add_foreign_key "samples", "field_data_projects"
end
