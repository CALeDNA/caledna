class MoveGbifToPp < ActiveRecord::Migration[5.2]
  def up
    execute 'ALTER TABLE external.gbif_occ_taxa SET SCHEMA pillar_point;'
    execute 'ALTER TABLE external.gbif_occurrences SET SCHEMA pillar_point;'
    execute 'UPDATE research_project_sources SET sourceable_type ' \
    " = 'PpGbifOccurrence' WHERE sourceable_type = 'GbifOccurrence'"
  end

  def down
    execute 'UPDATE research_project_sources SET sourceable_type ' \
    " = 'GbifOccurrence' WHERE sourceable_type = 'PpGbifOccurrence'"
     execute 'ALTER TABLE pillar_point.gbif_occ_taxa SET SCHEMA external;'
    execute 'ALTER TABLE pillar_point.gbif_occurrences SET SCHEMA external;'
  end
end
