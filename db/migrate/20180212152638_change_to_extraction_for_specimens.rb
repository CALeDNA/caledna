class ChangeToExtractionForSpecimens < ActiveRecord::Migration[5.0]
  def change
    remove_reference :specimens, :sample, foreign_key: true
    add_reference :specimens, :extraction, foreign_key: true
  end
end
