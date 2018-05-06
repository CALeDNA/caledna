class AddCanonicalNameToNcbiNodes < ActiveRecord::Migration[5.0]
  def change
    add_column :ncbi_nodes, :canonical_name, :string
    add_index :ncbi_names, :name_class
  end
end
