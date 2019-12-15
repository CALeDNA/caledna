class CreateGgbnTaxa < ActiveRecord::Migration[5.2]
  def up
    execute <<-SQL
      CREATE VIEW ggbn_full_scientific_name AS
        SELECT COALESCE(hierarchy_names ->> 'species', hierarchy_names ->> 'genus')
        AS full_scientific_name, taxon_id
        FROM ncbi_nodes;

      CREATE VIEW ggbn_higher_taxa AS

          SELECT concat(taxon_id,'_2') AS higher_taxon_id, taxon_id,
          hierarchy_names ->> 'phylum' AS higher_taxon_name,
          'phylum' AS higher_taxon_rank
          FROM ggbn_found_taxa
          WHERE hierarchy_names ->> 'phylum' != ''

          UNION
          SELECT concat(taxon_id,'_3') AS higher_taxon_id, taxon_id,
          hierarchy_names ->> 'class' AS higher_taxon_name,
          'classis' AS higher_taxon_rank
          FROM ggbn_found_taxa
          WHERE hierarchy_names ->> 'class' != ''

          UNION
          SELECT concat(taxon_id,'_4') AS higher_taxon_id, taxon_id,
          hierarchy_names ->> 'order' AS higher_taxon_name,
          'ordo' AS higher_taxon_rank
          FROM ggbn_found_taxa
          WHERE hierarchy_names ->> 'order' != ''

          UNION
          SELECT concat(taxon_id,'_5') AS higher_taxon_id, taxon_id,
          hierarchy_names ->> 'family' AS higher_taxon_name,
          'familia' AS higher_taxon_rank
          FROM ggbn_found_taxa
          WHERE hierarchy_names ->> 'family' != ''
    SQL
  end

  def down
    execute 'DROP VIEW IF EXISTS ggbn_full_scientific_name;'
    execute 'DROP VIEW IF EXISTS ggbn_higher_taxa;'
  end
end
