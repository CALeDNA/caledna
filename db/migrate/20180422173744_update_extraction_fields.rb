class UpdateExtractionFields < ActiveRecord::Migration[5.0]
  def up
    add_column :extractions, :sum_taxonomy_example, :string
    add_column :extractions, :priority_sequencing, :boolean

    change_column :extractions, :reamps_needed, :string
    change_column :extractions, :cleaned_concentration, :string
    change_column :extractions, :index_cleaned_concentration, :string
    change_column :extractions, :assoc_extraction_blank, :text
    change_column :extractions, :assoc_field_blank, :text
    change_column :extractions, :assoc_pcr_blank, :text

    rename_column :extractions, :sequencing_platform_cd, :sequencing_platform
    rename_column :extractions, :notes_sample_processor, :sample_processor_notes
    rename_column :extractions, :notes_lab_manager, :lab_manager_notes
    rename_column :extractions, :notes_director, :director_notes

    rename_column :samples, :notes_director, :director_notes
  end

  def down
    remove_column :extractions, :sum_taxonomy_example, :string
    remove_column :extractions, :priority_sequencing, :boolean

    change_column :extractions, :reamps_needed, 'boolean USING CAST(reamps_needed AS boolean)'
    change_column :extractions, :cleaned_concentration, 'decimal USING CAST(cleaned_concentration AS decimal)'
    change_column :extractions, :index_cleaned_concentration, 'decimal USING CAST(index_cleaned_concentration AS decimal)'
    change_column :extractions, :assoc_extraction_blank, :string
    change_column :extractions, :assoc_field_blank, :string
    change_column :extractions, :assoc_pcr_blank, :string

    rename_column :extractions, :sequencing_platform, :sequencing_platform_cd
    rename_column :extractions, :sample_processor_notes, :notes_sample_processor
    rename_column :extractions, :lab_manager_notes, :notes_lab_manager
    rename_column :extractions, :director_notes, :notes_director

    rename_column :samples, :director_notes, :notes_director
  end
end
