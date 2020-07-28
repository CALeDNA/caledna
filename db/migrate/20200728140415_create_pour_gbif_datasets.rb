class CreatePourGbifDatasets < ActiveRecord::Migration[5.2]
  def up
    create_table 'pour.gbif_datasets' do |t|
      t.string :dataset_key
      t.string :institution_code
      t.string :collection_code
      t.timestamps
    end

    PourGbifDataset.create(dataset_key: '50c9509d-22c7-4a22-a47d-8c48425ef4a7',
                           institution_code: 'iNaturalist',
                           collection_code: 'Observations')
  end

  def down
    drop_table 'pour.gbif_datasets'
  end
end
