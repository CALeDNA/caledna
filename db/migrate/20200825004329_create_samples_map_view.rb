class CreateSamplesMapView < ActiveRecord::Migration[5.2]
  def up
    sql = <<~SQL
      CREATE MATERIALIZED VIEW samples_map AS
      SELECT samples.id, samples.latitude, samples.longitude, samples.barcode,
      samples.status_cd as status, samples.substrate_cd as substrate,
      samples.location, samples.collection_date, samples.field_project_id,
      ARRAY_AGG(DISTINCT(primers.name)) FILTER (WHERE primers.name IS NOT NULL)
      AS primer_names,
      ARRAY_AGG(DISTINCT(primers.id)) FILTER (WHERE primers.id IS NOT NULL)
      AS primer_ids,
      COUNT(DISTINCT asvs.taxon_id) as taxa_count,
      ARRAY_AGG(DISTINCT research_project_id)
      FILTER (WHERE research_project_id IS NOT NULL) as research_project_ids

      FROM samples
      LEFT JOIN asvs ON asvs.sample_id = samples.id
      LEFT JOIN primers ON primers.id = asvs.primer_id
      LEFT JOIN research_projects
        ON asvs.research_project_id = research_projects.id
      WHERE (
        CASE
        WHEN research_projects.published IS NULL THEN status_cd = 'approved'
        ELSE status_cd = 'results_completed'
        END
      )
      GROUP BY samples.id
      ORDER BY samples.created_at ASC;
    SQL

    execute(sql)
  end

  def down
    execute('DROP MATERIALIZED VIEW samples_map;')
  end
end
