class AddRuggerioToNcbi < ActiveRecord::Migration[5.2]
  def change
    add_column :ncbi_nodes, :kingdom_r, :string
    add_column :ncbi_nodes, :phylum_r, :string
    add_column :ncbi_nodes, :class_r, :string
    add_column :ncbi_nodes, :order_r, :string
    add_index :ncbi_nodes, :kingdom_r
  end
end
