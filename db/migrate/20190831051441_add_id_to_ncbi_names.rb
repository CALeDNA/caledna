class AddIdToNcbiNames < ActiveRecord::Migration[5.2]
  def change
    add_column :ncbi_names, :id, :primary_key
  end
end
