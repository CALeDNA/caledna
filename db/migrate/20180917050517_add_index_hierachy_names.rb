class AddIndexHierachyNames < ActiveRecord::Migration[5.2]
  def change
    # execute "CREATE INDEX ON ncbi_nodes ((hierarchy_names->'kingdom'));"
    execute "CREATE INDEX ON ncbi_nodes ((hierarchy_names->'phylum'));"
    execute "CREATE INDEX ON ncbi_nodes ((hierarchy_names->'class'));"
    execute "CREATE INDEX ON ncbi_nodes ((hierarchy_names->'order'));"
    # execute "CREATE INDEX ON ncbi_nodes ((hierarchy_names->'family'));"
    # execute "CREATE INDEX ON ncbi_nodes ((hierarchy_names->'genus'));"
    # execute "CREATE INDEX ON ncbi_nodes ((hierarchy_names->'species'));"
  end
end
