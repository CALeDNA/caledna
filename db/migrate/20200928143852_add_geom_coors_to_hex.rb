class AddGeomCoorsToHex < ActiveRecord::Migration[5.2]
  def change
    add_column 'pour.hexbin_1km', :geom, :geometry, srid: Geospatial::SRID
    execute "UPDATE pour.hexbin_1km SET geom = ST_Transform(ST_SetSRID(geom_projected, #{Geospatial::SRID_PROJECTED}), #{Geospatial::SRID});"
    add_column 'pour.hexbin_1km', :latitude, :decimal
    add_column 'pour.hexbin_1km', :longitude, :decimal
    execute "UPDATE pour.hexbin_1km SET longitude=ST_X(ST_Centroid(geom)), latitude=ST_Y(ST_Centroid(geom));"
  end
end
