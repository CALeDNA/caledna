class DropTaxaSearchCache < ActiveRecord::Migration[5.2]
  def change
    drop_table :taxa_search_caches do |t|
    end
  end
end
