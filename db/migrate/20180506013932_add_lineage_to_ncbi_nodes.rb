class AddLineageToNcbiNodes < ActiveRecord::Migration[5.0]
  def up
    execute 'ALTER TABLE ncbi_nodes ADD COLUMN lineage text[][];'
    add_index :ncbi_nodes, :parent_taxon_id
  end

  def down
    remove_column :ncbi_nodes, :lineage
  end
end
