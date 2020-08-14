class RemoveResaerchFieldsFromPages < ActiveRecord::Migration[5.2]
  def change
    execute "DELETE from pages WHERE research_project_id IS NOT NULL;"

    remove_reference :pages, :research_project
    remove_column :pages, :show_map, :boolean
    remove_column :pages, :show_edna_results_metadata, :boolean
  end
end
