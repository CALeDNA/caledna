class AddIucnStatusToNcbiNodes < ActiveRecord::Migration[5.2]
  def change
    add_column :ncbi_nodes, :iucn_status, :string, index: true
  end
end
