class CreateCalTaxa < ActiveRecord::Migration[5.0]
  def up
    create_table :cal_taxa, id: false do |t|
      t.integer :taxonID
      t.string :datasetID
      t.string :parentNameUsageID
      t.text :scientificName
      t.string :canonicalName
      t.string :taxonRank
      t.string :taxonomicStatus
      t.string :kingdom
      t.string :phylum
      t.string :className
      t.string :order
      t.string :family
      t.string :genus
      t.string :specificEpithet
      t.jsonb :hierarchy
      t.timestamp
    end
    execute 'ALTER TABLE cal_taxa ADD PRIMARY KEY ("taxonID");'
    execute 'CREATE SEQUENCE cal_taxa_taxonID_seq START 2000000000;'
    execute 'ALTER TABLE cal_taxa ALTER "taxonID" SET DEFAULT NEXTVAL(\'cal_taxa_taxonID_seq\');'
    add_index :cal_taxa, [:kingdom, :canonicalName], unique: true
  end

  def down
    drop_table :cal_taxa
    execute 'DROP SEQUENCE cal_taxa_taxonID_seq'
  end
end
