class RemoveForeignKeyResearchProjectSources < ActiveRecord::Migration[5.2]
  def up
    remove_foreign_key :research_project_sources, name: "fk_rails_70e7da1386"
  end

  def down; end
end
