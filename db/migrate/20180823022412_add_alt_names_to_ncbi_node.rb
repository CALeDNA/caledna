class AddAltNamesToNcbiNode < ActiveRecord::Migration[5.2]
  def change
    add_column :ncbi_nodes, :alt_names, :string
  end
end
