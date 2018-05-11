class AddTaxonomyStringsToNcbiNodes < ActiveRecord::Migration[5.0]
  def change
    add_column :ncbi_nodes, :full_taxonomy_string, :text
    add_column :ncbi_nodes, :short_taxonomy_string, :text
  end
end
