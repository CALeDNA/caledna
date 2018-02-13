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

ActiveRecord::Schema.define(version: 20180213145628) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "asvs", force: :cascade do |t|
    t.integer  "tsn"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
    t.integer  "extraction_id"
    t.index ["extraction_id"], name: "index_asvs_on_extraction_id", using: :btree
    t.index ["tsn"], name: "index_asvs_on_tsn", using: :btree
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
    t.string   "metabarcoding_primers",                 default: [],    array: true
    t.boolean  "stat_barcoding_pcr_done",               default: false
    t.datetime "stat_barcoding_pcr_done_date"
    t.integer  "barcoding_pcr_number_of_replicates"
    t.boolean  "reamps_needed"
    t.boolean  "stat_barcoding_pcr_pooled",             default: false
    t.datetime "stat_barcoding_pcr_pooled_date"
    t.boolean  "stat_barcoding_pcr_bead_cleaned",       default: false
    t.datetime "stat_barcoding_pcr_bead_cleaned_date"
    t.string   "brand_beads_cd"
    t.decimal  "cleaned_concentration"
    t.string   "loc_stored"
    t.string   "select_indices_cd"
    t.string   "index_1_name"
    t.string   "index_2_name"
    t.boolean  "stat_index_pcr_done",                   default: false
    t.datetime "stat_index_pcr_done_date"
    t.boolean  "stat_index_pcr_bead_cleaned",           default: false
    t.datetime "stat_index_pcr_bead_cleaned_date"
    t.string   "index_brand_beads_cd"
    t.decimal  "index_cleaned_concentration"
    t.string   "index_loc_stored"
    t.boolean  "stat_libraries_pooled",                 default: false
    t.datetime "stat_libraries_pooled_date"
    t.string   "loc_libraries_pooled"
    t.boolean  "stat_sequenced",                        default: false
    t.datetime "stat_sequenced_date"
    t.string   "intended_sequencing_depth_per_barcode"
    t.string   "sequencing_platform_cd"
    t.string   "assoc_field_blank"
    t.string   "assoc_extraction_blank"
    t.string   "assoc_pcr_blank"
    t.string   "notes_sample_processor"
    t.string   "notes_lab_manager"
    t.string   "notes_director"
    t.index ["extraction_type_id"], name: "index_extractions_on_extraction_type_id", using: :btree
    t.index ["local_fastq_storage_adder_id"], name: "index_extractions_on_local_fastq_storage_adder_id", using: :btree
    t.index ["processor_id"], name: "index_extractions_on_processor_id", using: :btree
    t.index ["sample_id"], name: "index_extractions_on_sample_id", using: :btree
    t.index ["sra_adder_id"], name: "index_extractions_on_sra_adder_id", using: :btree
  end

  create_table "field_data_projects", force: :cascade do |t|
    t.integer  "kobo_id"
    t.jsonb    "kobo_payload"
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
    t.datetime "last_import_date"
    t.string   "description"
    t.string   "name"
    t.string   "date_range"
    t.index ["kobo_id"], name: "index_field_data_projects_on_kobo_id", unique: true, using: :btree
  end

  create_table "hierarchy", primary_key: "hierarchy_string", id: :string, limit: 300, force: :cascade do |t|
    t.integer "tsn",           null: false
    t.integer "parent_tsn"
    t.integer "level",         null: false
    t.integer "childrencount", null: false
  end

  create_table "kingdoms", primary_key: "kingdom_id", id: :integer, force: :cascade do |t|
    t.string "kingdom_name", limit: 10, null: false
    t.date   "update_date",             null: false
  end

  create_table "longnames", primary_key: "tsn", id: :integer, force: :cascade do |t|
    t.string "completename", limit: 300, null: false
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
    t.index ["sample_id"], name: "index_photos_on_sample_id", using: :btree
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
    t.decimal  "latitude",              precision: 15, scale: 10
    t.decimal  "longitude",             precision: 15, scale: 10
    t.datetime "submission_date"
    t.string   "barcode"
    t.jsonb    "kobo_data"
    t.text     "notes"
    t.datetime "created_at",                                                            null: false
    t.datetime "updated_at",                                                            null: false
    t.datetime "collection_date"
    t.string   "status_cd",                                       default: "submitted"
    t.integer  "processor_id"
    t.string   "substrate_cd"
    t.string   "ecosystem_category_cd"
    t.string   "alt_id"
    t.index ["field_data_project_id"], name: "index_samples_on_field_data_project_id", using: :btree
    t.index ["processor_id"], name: "index_samples_on_processor_id", using: :btree
    t.index ["status_cd"], name: "index_samples_on_status_cd", using: :btree
  end

  create_table "taxon_unit_types", primary_key: ["kingdom_id", "rank_id"], force: :cascade do |t|
    t.integer "kingdom_id",                    null: false
    t.integer "rank_id",            limit: 2,  null: false
    t.string  "rank_name",          limit: 15, null: false
    t.integer "dir_parent_rank_id", limit: 2,  null: false
    t.integer "req_parent_rank_id", limit: 2,  null: false
    t.date    "update_date",                   null: false
  end

  create_table "taxonomic_units", primary_key: "tsn", id: :bigint, force: :cascade do |t|
    t.string   "unit_ind1",          limit: 1
    t.string   "unit_name1",         limit: 35,                  null: false
    t.string   "unit_ind2",          limit: 1
    t.string   "unit_name2",         limit: 35
    t.string   "unit_ind3",          limit: 7
    t.string   "unit_name3",         limit: 35
    t.string   "unit_ind4",          limit: 7
    t.string   "unit_name4",         limit: 35
    t.string   "unnamed_taxon_ind",  limit: 1
    t.string   "name_usage",         limit: 12,                  null: false
    t.string   "unaccept_reason",    limit: 50
    t.string   "credibility_rtng",   limit: 40,                  null: false
    t.string   "completeness_rtng",  limit: 10
    t.string   "currency_rating",    limit: 7
    t.integer  "phylo_sort_seq",     limit: 2
    t.datetime "initial_time_stamp",                             null: false
    t.integer  "parent_tsn"
    t.integer  "taxon_author_id"
    t.integer  "hybrid_author_id"
    t.integer  "kingdom_id",         limit: 2,                   null: false
    t.integer  "rank_id",            limit: 2,                   null: false
    t.date     "update_date",                                    null: false
    t.string   "uncertain_prnt_ind", limit: 3
    t.text     "n_usage"
    t.string   "complete_name",      limit: 255,                 null: false
    t.boolean  "highlight",                      default: false
    t.index ["complete_name"], name: "index_taxonomic_units_on_complete_name", using: :btree
    t.index ["n_usage"], name: "index_taxonomic_units_on_n_usage", using: :btree
  end

  create_table "vernaculars", primary_key: ["tsn", "vern_id"], force: :cascade do |t|
    t.integer "tsn",                        null: false
    t.string  "vernacular_name", limit: 80, null: false
    t.string  "language",        limit: 15, null: false
    t.string  "approved_ind",    limit: 1
    t.date    "update_date",                null: false
    t.integer "vern_id",                    null: false
    t.index ["language"], name: "index_vernaculars_on_language", using: :btree
  end

  add_foreign_key "asvs", "extractions"
  add_foreign_key "asvs", "taxonomic_units", column: "tsn", primary_key: "tsn", name: "asvs_tsn_fkey"
  add_foreign_key "extractions", "extraction_types"
  add_foreign_key "extractions", "researchers", column: "local_fastq_storage_adder_id"
  add_foreign_key "extractions", "researchers", column: "processor_id"
  add_foreign_key "extractions", "researchers", column: "sra_adder_id"
  add_foreign_key "extractions", "samples"
  add_foreign_key "photos", "samples"
  add_foreign_key "samples", "field_data_projects"
  add_foreign_key "samples", "researchers", column: "processor_id"
end
