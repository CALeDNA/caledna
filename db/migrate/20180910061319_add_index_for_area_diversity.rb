class AddIndexForAreaDiversity < ActiveRecord::Migration[5.2]
  def up
    execute "CREATE INDEX idx_samples_metadata_month ON samples((metadata->>'month'));"
    execute "CREATE INDEX idx_rps_metadata_location ON research_project_sources((metadata->>'location'));"
  end

  def down
    remove_index :samples, name: :idx_samples_metadata_month
    remove_index :research_project_sources, name: :idx_rps_metadata_location
  end
end
