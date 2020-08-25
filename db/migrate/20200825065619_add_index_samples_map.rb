class AddIndexSamplesMap < ActiveRecord::Migration[5.2]
  def change
    add_index :samples_map, :id
    add_index :samples_map, :status
    add_index :samples_map, :substrate
    add_index :samples_map, :primer_ids, using: :gin
    add_index :samples_map, :research_project_ids, using: :gin
  end
end
