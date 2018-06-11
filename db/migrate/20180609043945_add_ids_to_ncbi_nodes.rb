class AddIdsToNcbiNodes < ActiveRecord::Migration[5.0]
  def change
    add_column :ncbi_nodes, :ids, :string, array: true, default: []
  end
end
