class AddBoldIdToNcbiNodes < ActiveRecord::Migration[5.2]
  def change
    add_column :ncbi_nodes, :bold_id, :bigint, index: true
  end
end
