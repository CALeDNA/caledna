class AddIndexIucnStatus < ActiveRecord::Migration[5.2]
  def change
    add_index :ncbi_nodes, :iucn_status
  end
end
