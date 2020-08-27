class RecreateSampleMap < ActiveRecord::Migration[5.2]
  def up
    execute('DROP MATERIALIZED VIEW IF EXISTS samples_map;')

    sql = <<~SQL
      CREATE MATERIALIZED VIEW samples_map AS
      SELECT samples.id, samples.latitude, samples.longitude, samples.barcode,
      samples.status_cd as status, samples.substrate_cd as substrate,
      samples.location, samples.collection_date, samples.field_project_id,
      samples.geom,
      ARRAY_AGG(DISTINCT(primers.name)) FILTER (WHERE primers.name IS NOT NULL)
      AS primer_names,
      ARRAY_AGG(DISTINCT(primers.id)) FILTER (WHERE primers.id IS NOT NULL)
      AS primer_ids,
      COUNT(DISTINCT asvs.taxon_id) as taxa_count,
      ARRAY_AGG(DISTINCT research_project_id)
      FILTER (WHERE research_project_id IS NOT NULL) as research_project_ids,
      ARRAY(SELECT DISTINCT UNNEST(STRING_TO_ARRAY
        (STRING_AGG((ARRAY_TO_STRING(ids, ',')), ',') ,',')
      )) as taxon_ids


      FROM samples
      LEFT JOIN asvs ON asvs.sample_id = samples.id
      LEFT JOIN primers ON primers.id = asvs.primer_id
      LEFT JOIN research_projects
        ON asvs.research_project_id = research_projects.id
      LEFT JOIN ncbi_nodes ON asvs.taxon_id = ncbi_nodes.taxon_id
        AND ncbi_nodes.taxon_id IN (SELECT taxon_id FROM asvs)
        AND (ncbi_nodes.iucn_status IS NULL OR
          ncbi_nodes.iucn_status NOT IN
          ('#{IucnStatus::THREATENED.values.join("','")}')
        )
      WHERE (
        CASE
        WHEN research_projects.published IS NULL THEN status_cd = 'approved'
        ELSE status_cd = 'results_completed'
        END
      )
      GROUP BY samples.id
      ORDER BY samples.id ASC;
    SQL

    execute(sql)

    add_index :samples_map, :id
    add_index :samples_map, :status
    add_index :samples_map, :substrate
    add_index :samples_map, :primer_ids, using: :gin
    add_index :samples_map, :research_project_ids, using: :gin
    add_index :samples_map, :taxon_ids, using: :gin
  end

  def down
    execute('DROP MATERIALIZED VIEW IF EXISTS samples_map;')
  end
end
