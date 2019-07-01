class AddResearchProjectToPages < ActiveRecord::Migration[5.2]
  def change
    add_column :pages, :research_project_id, :integer, index: true, null: true
    rename_column :pages, :order, :display_order
  end
end
