class AddSlugToResearchProject < ActiveRecord::Migration[5.2]
  def up
    add_column :research_projects, :slug, :string

    ResearchProject.all.each do |p|
      p.update(updated_at: DateTime.now)
    end

  end

  def down
    remove_column :research_projects, :slug
  end
end
