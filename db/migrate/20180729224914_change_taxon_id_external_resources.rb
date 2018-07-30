class ChangeTaxonIdExternalResources < ActiveRecord::Migration[5.2]
  def change
    add_column :external_resources, :source, :string
    rename_column :external_resources, :taxon_id, :ncbi_id
    change_column :external_resources, :ncbi_id, :integer, null: true
  end
end
