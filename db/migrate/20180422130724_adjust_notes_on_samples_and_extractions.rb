class AdjustNotesOnSamplesAndExtractions < ActiveRecord::Migration[5.0]
  def change
    add_column :samples, :notes_director, :text
    change_column :samples, :notes, :text
    rename_column :samples, :notes, :field_notes
    change_column :extractions, :notes_sample_processor, :text
    change_column :extractions, :notes_lab_manager, :text
    change_column :extractions, :notes_director, :text
  end
end
