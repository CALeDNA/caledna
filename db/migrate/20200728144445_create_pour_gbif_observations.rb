class CreatePourGbifObservations < ActiveRecord::Migration[5.2]
  def change
    create_table 'pour.gbif_occurrences', id: false do |t|
      t.bigint :gbif_id, primary_key: true
      t.string :occurrence_id
      t.references :gbif_dataset

      t.string :infraspecific_epithet
      t.string :scientific_name
      t.string :verbatim_scientific_name
      t.string :taxon_rank
      t.bigint :taxon_id
      t.bigint :species_id

      t.decimal :latitude
      t.decimal :longitude
      t.decimal :coordinate_uncertainty_in_meters
      t.string :country_code
      t.string :state_province
      t.st_point :geom, srid: Geospatial::SRID

      t.datetime :event_date
      t.string :identified_by
      t.datetime :date_identified
      t.string :license
      t.string :rights_holder
      t.string :recorded_by

      t.datetime :last_interpreted
      t.string :basis_of_record
      t.integer :catalog_number
      t.string :media_type
      t.string :issue
      t.timestamps
    end
    add_index 'pour.gbif_occurrences', :geom, using: :gist
    rename_column 'pour.gbif_taxa', :rank, :taxon_rank
  end
end

