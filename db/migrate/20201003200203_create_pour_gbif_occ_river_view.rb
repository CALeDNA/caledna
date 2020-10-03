class CreatePourGbifOccRiverView < ActiveRecord::Migration[5.2]
  def up
    sql = <<~SQL
      CREATE MATERIALIZED VIEW pour.gbif_occurrences_river AS
      SELECT gbif_id, occurrence_id, scientific_name, verbatim_scientific_name,
      taxon_rank, taxon_id, event_date, recorded_by, rights_holder,
      gbif_occurrences.latitude, gbif_occurrences.longitude,
      gbif_occurrences.geom, gbif_occurrences.geom_projected,
      institution_code, gbif_dataset_id, 1000 as distance
      FROM pour.gbif_occurrences
      JOIN places
        ON ST_DWithin(places.geom_projected,
        gbif_occurrences.geom_projected, 1000)
      AND places.place_source_type_cd = 'LA_river'
      AND places.place_type_cd = 'river'
      GROUP BY gbif_id;
    SQL
    execute sql

    add_index 'pour.gbif_occurrences_river', :geom, using: :gist
    add_index 'pour.gbif_occurrences_river', :geom_projected, using: :gist
    add_index 'pour.gbif_occurrences_river', :gbif_id
  end

  def down
    execute 'DROP MATERIALIZED VIEW IF EXISTS pour.gbif_occurrences_river;'
  end
end
