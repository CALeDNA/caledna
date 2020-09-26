class AddIndexExternalResources < ActiveRecord::Migration[5.2]
  def change
    add_index :external_resources, :wikidata_entity
    add_index :external_resources, :search_term
  end
end
