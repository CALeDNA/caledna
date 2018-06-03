class RemoveExtractionFields < ActiveRecord::Migration[5.0]
  def change
    remove_column :extractions, :stat_bio_reps_pooled, :boolean
    remove_column :extractions, :stat_dna_extraction, :boolean
    remove_column :extractions, :stat_barcoding_pcr_done, :boolean
    remove_column :extractions, :stat_barcoding_pcr_pooled, :boolean
    remove_column :extractions, :stat_barcoding_pcr_bead_cleaned, :boolean
    remove_column :extractions, :stat_index_pcr_done, :boolean
    remove_column :extractions, :stat_index_pcr_bead_cleaned, :boolean
    remove_column :extractions, :stat_libraries_pooled, :boolean
    remove_column :extractions, :stat_sequenced, :boolean
  end
end
