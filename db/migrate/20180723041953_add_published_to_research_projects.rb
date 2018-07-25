class AddPublishedToResearchProjects < ActiveRecord::Migration[5.2]
  def up
    add_column :research_projects, :published, :boolean, default: false
    ResearchProject.all.each do |p|
      p.update(published: true)
    end
  end

  def down
    remove_column :research_projects, :published
  end
end
