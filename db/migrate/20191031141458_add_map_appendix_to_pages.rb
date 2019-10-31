class AddMapAppendixToPages < ActiveRecord::Migration[5.2]
  def change
    add_column :pages, :show_map, :boolean
    add_column :pages, :show_edna_results_metadata, :boolean
  end
end
