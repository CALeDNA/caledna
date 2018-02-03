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

ActiveRecord::Schema.define(version: 20180203153112) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

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

  create_table "projects", force: :cascade do |t|
    t.string   "name"
    t.text     "description"
    t.string   "kobo_name"
    t.integer  "kobo_id"
    t.jsonb    "kobo_payload"
    t.datetime "start_date"
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
    t.datetime "last_import_date"
    t.index ["kobo_id"], name: "index_projects_on_kobo_id", unique: true, using: :btree
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
    t.index ["email"], name: "index_researchers_on_email", unique: true, using: :btree
    t.index ["invitation_token"], name: "index_researchers_on_invitation_token", unique: true, using: :btree
    t.index ["invitations_count"], name: "index_researchers_on_invitations_count", using: :btree
    t.index ["invited_by_id"], name: "index_researchers_on_invited_by_id", using: :btree
    t.index ["reset_password_token"], name: "index_researchers_on_reset_password_token", unique: true, using: :btree
  end

  create_table "researchers_roles", force: :cascade do |t|
  end

  create_table "roles", force: :cascade do |t|
  end

  create_table "samples", force: :cascade do |t|
    t.integer  "project_id"
    t.integer  "kobo_id"
    t.decimal  "latitude",                precision: 15, scale: 10
    t.decimal  "longitude",               precision: 15, scale: 10
    t.datetime "submission_date"
    t.string   "bar_code"
    t.jsonb    "kobo_data"
    t.datetime "analysis_date"
    t.text     "notes"
    t.datetime "created_at",                                                              null: false
    t.datetime "updated_at",                                                              null: false
    t.datetime "collection_date"
    t.datetime "results_completion_date"
    t.string   "status_cd",                                         default: "submitted"
    t.integer  "processor_id"
    t.index ["processor_id"], name: "index_samples_on_processor_id", using: :btree
    t.index ["project_id"], name: "index_samples_on_project_id", using: :btree
  end

  add_foreign_key "photos", "samples"
  add_foreign_key "samples", "projects"
  add_foreign_key "samples", "researchers", column: "processor_id"
end
