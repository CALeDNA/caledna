class ChangeExternalResourcesPrimaryKey < ActiveRecord::Migration[5.2]
  def up
    execute "ALTER TABLE external_resources DROP CONSTRAINT external_resources_pkey;"
    add_column :external_resources, :id, :primary_key
  end

  def down
    execute 'ALTER TABLE external_resources ADD PRIMARY KEY ("taxon_id");'
    remove_column :external_resources, :id
  end
end
