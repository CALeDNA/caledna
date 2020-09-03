class AddGeomUnprojected < ActiveRecord::Migration[5.2]
  def up
    add_column :samples, :geom_projected, :geometry, srid: Geospatial::SRID_PROJECTED
    execute "UPDATE samples SET geom_projected = ST_Transform(ST_SetSRID(geom, #{Geospatial::SRID}), #{Geospatial::SRID_PROJECTED});"
    add_index :samples, :geom_projected, using: :gist

    add_column :places, :geom_projected, :geometry, srid: Geospatial::SRID_PROJECTED
    execute "UPDATE places SET geom_projected = ST_Transform(ST_SetSRID(geom, #{Geospatial::SRID}), #{Geospatial::SRID_PROJECTED});"
    add_index :places, :geom_projected, using: :gist

    add_column 'pour.gbif_occurrences', :geom_projected, :geometry, srid: Geospatial::SRID_PROJECTED
    execute "UPDATE pour.gbif_occurrences SET geom_projected = ST_Transform(ST_SetSRID(geom, #{Geospatial::SRID}), #{Geospatial::SRID_PROJECTED});"
    add_index 'pour.gbif_occurrences', :geom_projected, using: :gist
  end

  def down
    drop_column 'pour.gbif_occurrences', :geom_projected
    drop_column :places, :geom_projected
    drop_column :samples, :geom_projected
  end
end
