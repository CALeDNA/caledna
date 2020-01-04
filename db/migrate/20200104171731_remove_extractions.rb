class RemoveExtractions < ActiveRecord::Migration[5.2]
  def up
    remove_reference :asvs, :extraction
    drop_table :extractions
    drop_table :extraction_types
  end

  def down
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

    add_reference :asvs, :extraction, type: :integer, index: true

    add_foreign_key "asvs", "extractions"
    add_foreign_key "extractions", "extraction_types"
    add_foreign_key "extractions", "researchers", column: "local_fastq_storage_adder_id"
    add_foreign_key "extractions", "researchers", column: "processor_id"
    add_foreign_key "extractions", "researchers", column: "sra_adder_id"
    add_foreign_key "extractions", "samples"
  end
end
