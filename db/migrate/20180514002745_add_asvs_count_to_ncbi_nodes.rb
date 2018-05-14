class AddAsvsCountToNcbiNodes < ActiveRecord::Migration[5.0]
  def change
    add_column :ncbi_nodes, :asvs_count, :integer, default: 0
    add_index :ncbi_nodes, :asvs_count
  end
end
