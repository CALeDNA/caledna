class AddBoldTaxonomy < ActiveRecord::Migration[5.2]
  def change
    add_column :ncbi_nodes, :ncbi_id, :integer
    add_index :ncbi_nodes, :ncbi_id
  end
end
