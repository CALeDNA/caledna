class CreateTaxaDatasets < ActiveRecord::Migration[5.0]
  def up
    create_table :taxa_datasets, id: false do |t|
      t.string :name
      t.string :datasetID
      t.text :citation
    end
    execute 'ALTER TABLE taxa_datasets ADD PRIMARY KEY ("datasetID");'
  end

  def down
    drop_table :taxa_datasets
  end
end
