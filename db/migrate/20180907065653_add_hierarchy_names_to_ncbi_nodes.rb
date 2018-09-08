class AddHierarchyNamesToNcbiNodes < ActiveRecord::Migration[5.2]
  def change
    add_column :ncbi_nodes, :hierarchy_names, :jsonb, default: {}
  end
end
