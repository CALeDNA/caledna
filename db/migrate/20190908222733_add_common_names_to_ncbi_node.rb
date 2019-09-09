class AddCommonNamesToNcbiNode < ActiveRecord::Migration[5.2]
  def change
    add_column :ncbi_nodes, :common_names, :string
  end
end
