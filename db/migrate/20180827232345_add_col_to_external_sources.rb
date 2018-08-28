class AddColToExternalSources < ActiveRecord::Migration[5.2]
  def change
    add_column :external_resources, :col_id, :string
    add_column :external_resources, :wikispecies_id, :string
    add_column :external_resources, :payload, :jsonb
  end
end
