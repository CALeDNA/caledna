class ImportNcbiTables < ActiveRecord::Migration[5.0]
  def up
    script = Rails.root.join('db').join('data').join('ncbi_schema.sql')
    execute File.read(script)
  end

  def down
    drop_table :ncbi_names
    drop_table :ncbi_nodes
    drop_table :ncbi_citations
  end
end
