class CreateGgbnFoundTaxa < ActiveRecord::Migration[5.2]
  def up
    execute <<-SQL
      CREATE VIEW ggbn_found_taxa AS
        SELECT ncbi_nodes.taxon_id, ncbi_nodes.hierarchy_names, ncbi_nodes.rank,
        ncbi_nodes.canonical_name
        FROM ncbi_nodes
        JOIN asvs ON asvs."taxonID" = ncbi_nodes.taxon_id
        GROUP BY ncbi_nodes.taxon_id;
    SQL
  end

  def down
    execute 'DROP VIEW IF EXISTS ggbn_found_taxa;'
  end
end
