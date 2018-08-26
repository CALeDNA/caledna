class AddMetadataToResearchProjectSources < ActiveRecord::Migration[5.2]
  def change
    add_column :research_project_sources, :metadata, :jsonb, default: {}
  end
end
