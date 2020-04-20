class CreatePpNcbiNames < ActiveRecord::Migration[5.2]
  def up
    execute <<-SQL
    CREATE TABLE pillar_point.ncbi_names AS
      SELECT external.ncbi_names_2017.*
      FROM external.ncbi_names_2017
      WHERE name IN (
        SELECT (unnest(array[superkingdom, kingdom, phylum, class_name,
          "order", family, genus, species]))
        FROM pillar_point.combine_taxa
        WHERE source IN ('gbif')
      );
    SQL

    execute "ALTER TABLE pillar_point.ncbi_names ADD PRIMARY KEY (id);"
    add_index 'pillar_point.ncbi_names', :name_class
    add_index 'pillar_point.ncbi_names', :taxon_id
    add_index 'pillar_point.ncbi_names', "(lower(name))"
  end

  def down
    drop_table 'pillar_point.ncbi_names'
  end
end
