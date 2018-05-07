class AddHierarchyToNcbiNodes < ActiveRecord::Migration[5.0]
  def up
    add_column :ncbi_nodes, :hierarchy, :jsonb, default: {}
    execute 'CREATE INDEX index_taxa_on_hierarchy ON ncbi_nodes USING gin (hierarchy);'
    add_index :ncbi_nodes, :rank
  end

  def down
    remove_column :ncbi_nodes, :hierarchy, :jsonb, default: {}
    remove_index :ncbi_nodes, :index_taxa_on_hierarchy
    remove_index :ncbi_nodes, :rank
  end
end
