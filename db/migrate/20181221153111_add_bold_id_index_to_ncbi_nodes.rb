class AddBoldIdIndexToNcbiNodes < ActiveRecord::Migration[5.2]
  def change
    add_index :ncbi_nodes, :bold_id
  end
end
