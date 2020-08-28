class CreateNcbiNodesEdna < ActiveRecord::Migration[5.2]
  def up
    execute('DROP MATERIALIZED VIEW IF EXISTS ncbi_nodes_edna;')

    sql =<<~SQL
      CREATE MATERIALIZED VIEW ncbi_nodes_edna AS
      SELECT taxon_id, rank, canonical_name,asvs_count, asvs_count_la_river,
      iucn_status, ids
      FROM ncbi_nodes
      WHERE  taxon_id IN (SELECT taxon_id FROM asvs)
      AND (
        ncbi_nodes.iucn_status IS NULL OR
        ncbi_nodes.iucn_status NOT IN
        ('#{IucnStatus::THREATENED.values.join("','")}')
      )
    SQL
    execute(sql)

    add_index :ncbi_nodes_edna, :taxon_id
    add_index :ncbi_nodes_edna, :asvs_count
    add_index :ncbi_nodes_edna, :asvs_count_la_river
    add_index :ncbi_nodes_edna, :ids, using: :gin
  end

  def down
    execute('DROP MATERIALIZED VIEW IF EXISTS ncbi_nodes_edna;')
  end
end
