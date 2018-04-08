# frozen_string_literal: true

class CreateExtractions < ActiveRecord::Migration[5.0]
  def change
    create_table :extractions do |t|
      t.references :sample, foreign_key: true
      t.references :extraction_type, foreign_key: true

      t.references :processor, foreign_key: { to_table: :researchers }
      t.string :priority_sequencing_cd
      t.boolean :prepub_share, default: false
      t.string :prepub_share_group
      t.boolean :prepub_filter_sensitive_info, default: false
      t.string :sra_url
      t.references :sra_adder, foreign_key: { to_table: :researchers }
      t.datetime :sra_add_date
      t.string :local_fastq_storage_url
      t.references :local_fastq_storage_adder, foreign_key: { to_table: :researchers }
      t.datetime :local_fastq_storage_add_date

      t.boolean :stat_bio_reps_pooled, default: false
      t.datetime :stat_bio_reps_pooled_date
      t.string :loc_bio_reps_pooled
      t.datetime :bio_reps_pooled_date
      t.string :protocol_bio_reps_pooled
      t.string :changes_protocol_bio_reps_pooled

      t.boolean :stat_dna_extraction, default: false
      t.datetime :stat_dna_extraction_date
      t.string :loc_dna_extracts
      t.datetime :dna_extraction_date
      t.string :protocol_dna_extraction
      t.string :changes_protocol_dna_extraction

      t.string :metabarcoding_primers, array: true, default: []
      t.boolean :stat_barcoding_pcr_done, default: false
      t.datetime :stat_barcoding_pcr_done_date
      t.integer :barcoding_pcr_number_of_replicates
      t.boolean :reamps_needed
      t.boolean :stat_barcoding_pcr_pooled, default: false
      t.datetime :stat_barcoding_pcr_pooled_date
      t.boolean :stat_barcoding_pcr_bead_cleaned, default: false
      t.datetime :stat_barcoding_pcr_bead_cleaned_date
      t.string :brand_beads_cd
      t.decimal :cleaned_concentration
      t.string :loc_stored

      t.string :select_indices_cd
      t.string :index_1_name
      t.string :index_2_name
      t.boolean :stat_index_pcr_done, default: false
      t.datetime :stat_index_pcr_done_date
      t.boolean :stat_index_pcr_bead_cleaned, default: false
      t.datetime :stat_index_pcr_bead_cleaned_date
      t.string :index_brand_beads_cd
      t.decimal :index_cleaned_concentration
      t.string :index_loc_stored

      t.boolean :stat_libraries_pooled, default: false
      t.datetime :stat_libraries_pooled_date
      t.string :loc_libraries_pooled

      t.boolean :stat_sequenced, default: false
      t.datetime :stat_sequenced_date
      t.string :intended_sequencing_depth_per_barcode
      t.string :sequencing_platform_cd

      t.string :assoc_field_blank
      t.string :assoc_extraction_blank
      t.string :assoc_pcr_blank

      t.string :notes_sample_processor
      t.string :notes_lab_manager
      t.string :notes_director
    end
  end
end
