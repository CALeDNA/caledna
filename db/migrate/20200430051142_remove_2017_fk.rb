class Remove2017Fk < ActiveRecord::Migration[5.2]
  def change
    remove_foreign_key 'external.asvs_2017', :samples
    remove_foreign_key 'external.asvs_2017', :primers
    remove_foreign_key 'external.asvs_2017', :research_projects
    remove_foreign_key 'external.ncbi_nodes_2017', :ncbi_divisions
  end
end
