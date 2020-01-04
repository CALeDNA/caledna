class AddResearchProjectToAsv < ActiveRecord::Migration[5.2]
  def change
    add_reference :asvs, :research_project, type: :integer
    add_column :asvs, :primer, :string, index: true
  end
end
