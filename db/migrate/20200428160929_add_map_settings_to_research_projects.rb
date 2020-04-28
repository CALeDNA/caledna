class AddMapSettingsToResearchProjects < ActiveRecord::Migration[5.2]
  def change
    add_column :research_projects, :map_latitude, :decimal
    add_column :research_projects, :map_longitude, :decimal
    add_column :research_projects, :map_zoom, :integer
  end
end
