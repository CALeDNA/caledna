class RemovePgheroTables < ActiveRecord::Migration[5.2]
  def change
    drop_table :pghero_query_stats
    drop_table :pghero_space_stats
  end
end
