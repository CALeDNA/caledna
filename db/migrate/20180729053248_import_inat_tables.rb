class ImportInatTables < ActiveRecord::Migration[5.2]
  def up
    script = Rails.root.join('db').join('data').join('inat_schema.sql')
    execute File.read(script)
  end

  def down
    drop_table :inat_taxa
    drop_table :inat_observations
  end
end
