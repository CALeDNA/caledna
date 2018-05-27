class CreateExternalResources < ActiveRecord::Migration[5.0]
  def change
    create_table :external_resources, id: false  do |t|
      t.integer :taxon_id, primary_key: true
      t.integer :eol_id
      t.integer :gbif_id
      t.string :wikidata_image
      t.integer :bold_id
      t.integer :calflora_id
      t.integer :cites_id
      t.integer :cnps_id
      t.integer :gbif_id
      t.integer :inaturalist_id
      t.integer :itis_id
      t.integer :iucn_id
      t.integer :msw_id
      t.string :wikidata_entity
      t.integer :worms_id
      t.string :iucn_status

      t.timestamps
    end
  end
end
