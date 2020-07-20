class CreatePlaces < ActiveRecord::Migration[5.2]
  def up
    create_table :places do |t|
      t.string :name
      t.integer :state_fips
      t.integer :county_fips
      t.integer :place_fips
      t.integer :lsad
      t.string :place_type_cd
      t.decimal :latitude
      t.decimal :longitude
      t.geometry :geom, srid: Geospatial::SRID
      t.string :place_source_type_cd
      t.references :place_source
      t.timestamp
    end

    execute 'CREATE INDEX index_places_on_name ON places USING btree ( lower ("name") text_pattern_ops);'
    add_index :places, :geom, using: :gist
  end

  def down
    drop_table :places
  end
end


