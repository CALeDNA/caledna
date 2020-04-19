class AddIndexToNcbiNames < ActiveRecord::Migration[5.2]
  def change
    add_index :ncbi_names, 'lower(name)'
  end
end
