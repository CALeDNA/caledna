class CreatePillarPointTables < ActiveRecord::Migration[5.2]
  def up
    execute 'CREATE SCHEMA pillar_point;'
    execute 'ALTER TABLE combine_taxa SET SCHEMA pillar_point;'

    execute <<-SQL
      CREATE TABLE pillar_point.ncbi_nodes AS
      SELECT *
      FROM ncbi_nodes
      WHERE taxon_id IN(
        SELECT unnest(ncbi_nodes.ids)::INT AS taxon_id
        FROM asvs
        JOIN ncbi_nodes ON ncbi_nodes.taxon_id = asvs.taxon_id
        JOIN research_project_sources ON asvs.sample_id =
          research_project_sources.sourceable_id
        WHERE research_project_sources.research_project_id = 4
        AND sourceable_type = 'Sample'
        GROUP BY unnest(ncbi_nodes.ids)
      );
    SQL

    execute <<-SQL
      CREATE TABLE pillar_point.asvs AS
      SELECT asvs.*
      FROM asvs
      JOIN samples ON samples.id = asvs.sample_id
      JOIN research_project_sources ON asvs.sample_id =
        research_project_sources.sourceable_id
      WHERE research_project_sources.research_project_id = 4
      AND sourceable_type = 'Sample';
    SQL
  end

  def down
    drop_table 'pillar_point.asvs'
    drop_table 'pillar_point.ncbi_nodes'
    execute 'ALTER TABLE combine_taxa SET SCHEMA public;'
    execute 'DROP SCHEMA pillar_point;'
  end
end
