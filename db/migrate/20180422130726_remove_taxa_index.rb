class RemoveTaxaIndex < ActiveRecord::Migration[5.0]
  def up
    remove_index :taxa, name: :index_taxa_on_parentNameUsageID
    remove_index :taxa, name: :index_taxa_on_datasetID
    remove_index :taxa, name: :taxonomy_idx
  end
end
