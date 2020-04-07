class RedoGgbnViews < ActiveRecord::Migration[5.2]
  def up
    execute <<-SQL
      DROP VIEW IF EXISTS ggbn_full_scientific_name;
      DROP VIEW IF EXISTS ggbn_completed_samples;
      DROP VIEW IF EXISTS ggbn_higher_taxa;
      DROP VIEW IF EXISTS ggbn_found_taxa;

      CREATE MATERIALIZED VIEW ggbn_completed_samples AS
      SELECT
        samples.id AS sample_id,
        samples.field_project_id,
        samples.kobo_id,
        samples.latitude,
        samples.longitude,
        samples.submission_date,
        samples.barcode,
        samples.kobo_data,
        samples.field_notes,
        samples.created_at,
        samples.updated_at,
        samples.collection_date,
        samples.status_cd,
        samples.substrate_cd,
        samples.altitude,
        samples.gps_precision,
        samples.location,
        samples.director_notes,
        samples.habitat_cd,
        samples.depth_cd,
        samples.missing_coordinates,
        samples.metadata,
        samples.primers,
        samples.csv_data,
        samples.country,
        samples.country_code,
        samples.has_permit,
        samples.environmental_features,
        samples.environmental_settings,
        research_projects.decontamination_method
      FROM
        samples
        JOIN research_project_sources ON research_project_sources.sourceable_id = samples.id
        JOIN research_projects ON research_project_sources.research_project_id = research_projects.id
      WHERE
        samples.status_cd :: text = 'results_completed' :: text
        AND research_project_sources.sourceable_type :: text = 'Sample' :: text;

      CREATE INDEX ggbn_completed_samples_samples_id ON ggbn_completed_samples (sample_id);

      CREATE MATERIALIZED VIEW ggbn_full_scientific_name AS
      SELECT
        COALESCE(
          ncbi_nodes.hierarchy_names ->> 'species' :: text,
          ncbi_nodes.hierarchy_names ->> 'genus' :: text
        ) AS full_scientific_name,
        ncbi_nodes.taxon_id
      FROM
        ncbi_nodes
        JOIN asvs ON ncbi_nodes.taxon_id = asvs.taxon_id
      GROUP BY
        COALESCE(
          ncbi_nodes.hierarchy_names ->> 'species' :: text,
          ncbi_nodes.hierarchy_names ->> 'genus' :: text
        ),
        ncbi_nodes.taxon_id;

      CREATE INDEX ggbn_scientific_name_taxon_id ON ggbn_full_scientific_name (taxon_id);

      CREATE MATERIALIZED VIEW ggbn_found_taxa AS
      SELECT
        ncbi_nodes.taxon_id,
        ncbi_nodes.hierarchy_names ->> 'phylum' AS phylum,
        ncbi_nodes.hierarchy_names ->> 'class' AS class,
        ncbi_nodes.hierarchy_names ->> 'order' AS "order",
        ncbi_nodes.hierarchy_names ->> 'family' AS family,
        ncbi_nodes.rank,
        ncbi_nodes.canonical_name
      FROM
        ncbi_nodes
        JOIN asvs ON asvs.taxon_id = ncbi_nodes.taxon_id
      GROUP BY
        ncbi_nodes.taxon_id;

      CREATE INDEX ggbn_found_taxa_ranks ON ggbn_found_taxa (phylum, class, "order", family);

      CREATE MATERIALIZED VIEW ggbn_higher_taxa AS
      SELECT
        concat(ggbn_found_taxa.taxon_id, '_2') AS higher_taxon_id,
        ggbn_found_taxa.taxon_id,
        ggbn_found_taxa.phylum AS higher_taxon_name,
        'phylum' :: text AS higher_taxon_rank
      FROM
        ggbn_found_taxa AS ggbn_found_taxa
      WHERE
        ggbn_found_taxa.phylum IS NOT NULL
      UNION
      SELECT
        concat(ggbn_found_taxa.taxon_id, '_3') AS higher_taxon_id,
        ggbn_found_taxa.taxon_id,
        ggbn_found_taxa.class AS higher_taxon_name,
        'classis' :: text AS higher_taxon_rank
      FROM
        ggbn_found_taxa AS ggbn_found_taxa
      WHERE
        ggbn_found_taxa.class IS NOT NULL
      UNION
      SELECT
        concat(ggbn_found_taxa.taxon_id, '_4') AS higher_taxon_id,
        ggbn_found_taxa.taxon_id,
        ggbn_found_taxa.order AS higher_taxon_name,
        'ordo' :: text AS higher_taxon_rank
      FROM
        ggbn_found_taxa AS ggbn_found_taxa
      WHERE
        ggbn_found_taxa.order IS NOT NULL
      UNION
      SELECT
        concat(ggbn_found_taxa.taxon_id, '_5') AS higher_taxon_id,
        ggbn_found_taxa.taxon_id,
        ggbn_found_taxa.family AS higher_taxon_name,
        'familia' :: text AS higher_taxon_rank
      FROM
        ggbn_found_taxa AS ggbn_found_taxa
      WHERE
        ggbn_found_taxa.family IS NOT NULL;

      CREATE INDEX ggbn_higher_taxa_taxon_id ON ggbn_higher_taxa (taxon_id);

    SQL
  end

  def down
    execute <<-SQL
      DROP VIEW IF EXISTS ggbn_full_scientific_name;
      DROP VIEW IF EXISTS ggbn_completed_samples;
      DROP VIEW IF EXISTS ggbn_higher_taxa;
      DROP VIEW IF EXISTS ggbn_found_taxa;
    SQL
  end
end
