class AddTaxaIndexIucn < ActiveRecord::Migration[5.0]
  def change
    add_index :taxa, :iucn_status
    add_column :taxa, :iucn_taxonid, :integer
  end
end
