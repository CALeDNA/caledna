class AddIndexesPpTables < ActiveRecord::Migration[5.2]
  def up
    add_index 'pillar_point.asvs', :sample_id
    add_index 'pillar_point.asvs', :taxon_id
    add_index 'pillar_point.asvs', :research_project_id
    add_index 'pillar_point.asvs', :primer_id
    execute "ALTER TABLE pillar_point.asvs ADD PRIMARY KEY (id);"

    execute "ALTER TABLE pillar_point.ncbi_nodes ADD PRIMARY KEY (taxon_id);"
    add_index 'pillar_point.ncbi_nodes', '(lower("canonical_name"))'

    add_index 'pillar_point.combine_taxa', :caledna_taxon_id

    project = ResearchProject.pillar_point
    if project.present?
      execute "UPDATE pillar_point.asvs SET research_project_id = #{project.id}"
    end
  end

  def down; end
end
