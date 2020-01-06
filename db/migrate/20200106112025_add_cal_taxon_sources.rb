class AddCalTaxonSources < ActiveRecord::Migration[5.2]
  def change
    add_column :cal_taxa, :sources, :text, array: true, default: []
  end
end
