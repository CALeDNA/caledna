class RemoveIndexesNcbiNodes < ActiveRecord::Migration[5.2]
  def up
    remove_column :ncbi_nodes, :kingdom_r, :string
    remove_column :ncbi_nodes, :phylum_r, :string
    remove_column :ncbi_nodes, :class_r, :string
    remove_column :ncbi_nodes, :order_r, :string
    remove_index :ncbi_nodes,  name: :ncbi_nodes_expr_idx
    remove_index :ncbi_nodes, name: :ncbi_nodes_expr_idx1
    remove_index :ncbi_nodes, name: :ncbi_nodes_expr_idx2
    add_index :ncbi_nodes, :hierarchy_names, using: :gin
    add_index :ncbi_nodes, :ids, using: :gin
  end

  def down
    add_column :ncbi_nodes, :kingdom_r, :string
    add_column :ncbi_nodes, :phylum_r, :string
    add_column :ncbi_nodes, :class_r, :string
    add_column :ncbi_nodes, :order_r, :string
    remove_index :ncbi_nodes, :hierarchy_names
    remove_index :ncbi_nodes, :ids
  end
end
