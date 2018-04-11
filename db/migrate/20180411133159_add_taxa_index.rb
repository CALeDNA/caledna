class AddTaxaIndex < ActiveRecord::Migration[5.0]
  def change
    add_index :taxa, :parentNameUsageID
    add_index :taxa, [:canonicalName, :taxonRank]
    add_index :taxa, :taxonRank
    add_index :taxa, :scientificName
    add_index :taxa, :phylum
    add_index :taxa, :kingdom
    add_index :taxa, :genus
    execute 'CREATE INDEX canonicalName_prefix ON taxa USING btree ( lower ("canonicalName") text_pattern_ops);'
  end
end
