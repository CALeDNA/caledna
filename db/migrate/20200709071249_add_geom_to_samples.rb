class AddGeomToSamples < ActiveRecord::Migration[5.2]
  def up
    add_column :samples, :geom, :st_point, srid: Geospatial::SRID
    execute "UPDATE samples SET geom = ST_SetSRID(ST_MakePoint(longitude, latitude),#{Geospatial::SRID});"
    add_index :samples, :geom, using: :gist
  end

  def down
    remove_column :samples, :geom
  end
end
