class RenameResearchProjectExtractions < ActiveRecord::Migration[5.2]
  def change
    rename_table :research_project_extractions, :research_project_sources
    add_column :research_project_sources, :sourceable_type, :string
    rename_column :research_project_sources, :extraction_id, :sourceable_id
  end
end
