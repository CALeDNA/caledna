class AddAsvsCountLaRiver < ActiveRecord::Migration[5.2]
  def change
    add_column :ncbi_nodes, :asvs_count_5, :integer, default: 0
    add_column :ncbi_nodes, :asvs_count_la_river, :integer, default: 0
    add_column :ncbi_nodes, :asvs_count_la_river_5, :integer, default: 0
    add_index :ncbi_nodes, :asvs_count_5
    add_index :ncbi_nodes, :asvs_count_la_river
    add_index :ncbi_nodes, :asvs_count_la_river_5
  end
end
