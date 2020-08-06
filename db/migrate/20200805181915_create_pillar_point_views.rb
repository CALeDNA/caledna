class CreatePillarPointViews < ActiveRecord::Migration[5.2]

  include ResearchProjectService::PillarPointServices::BioticInteractions

  def up
    project = ResearchProject.find_by(slug: 'pillar-point')
    globi_index_sql = <<-SQL
      CREATE MATERIALIZED VIEW pillar_point.globi_index AS
      SELECT research_project_sources.metadata ->> 'image' AS image,
        research_project_sources.metadata ->> 'inat_at_pillar_point_count' AS count,
        taxon_name, gbif_id,
        inaturalist_id, external_resources.ncbi_id
      FROM external.globi_requests
      JOIN research_project_sources
      ON research_project_sources.sourceable_id = external.globi_requests.id
      LEFT JOIN external_resources
      ON  external_resources.inaturalist_id =
        (research_project_sources.metadata ->> 'inat_id')::integer
      AND external_resources.source != 'wikidata'
      WHERE research_project_id = #{project.id}
      AND sourceable_type = 'GlobiRequest'
      ORDER BY  (research_project_sources.metadata ->>
        'inat_at_pillar_point_count')::integer desc
    SQL

    execute(globi_index_sql)

    create_table 'pillar_point.globi_show' do |t|
      t.string :source_taxon_name, index: true
      t.string :source_taxon_ids
      t.string :source_taxon_path
      t.string :source_taxon_rank
      t.string :interaction_type
      t.string :target_taxon_name, index: true
      t.string :target_taxon_ids
      t.string :target_taxon_path
      t.string :target_taxon_rank
      t.boolean :is_source
      t.boolean :edna_match
      t.boolean :gbif_match
      t.string :keyword
      t.timestamp
    end
  end

  def down
    execute("DROP MATERIALIZED VIEW pillar_point.globi_index;")
    drop_table 'pillar_point.globi_show'
  end
end
