class AddProcessorAndStatusToExtraction < ActiveRecord::Migration[5.0]
  def change
    add_column :extractions, :status_cd, :string
    remove_reference :samples, :processor, foreign_key: { to_table: :researchers }
  end
end
