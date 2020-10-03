class AddHexabin1km < ActiveRecord::Migration[5.2]
  def up
    create_table 'pour.hexbin_1km' do |t|
      t.bigint :taxon_id, index: true
      t.numeric :left
      t.numeric :bottom
      t.numeric :right
      t.numeric :top
      t.multi_polygon :geom_projected, srid: Geospatial::SRID_PROJECTED
    end
    add_index 'pour.hexbin_1km', :geom_projected, using: :gist
  end
end
