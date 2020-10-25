class RemoveUnusedTables < ActiveRecord::Migration[5.2]
  def change
    drop_table :result_raw_imports
    drop_table :highlights
  end
end
