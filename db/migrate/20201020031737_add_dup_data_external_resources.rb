class AddDupDataExternalResources < ActiveRecord::Migration[5.2]
  def change
    add_column :external_resources, :dup_data, :jsonb, default: {}
  end
end
