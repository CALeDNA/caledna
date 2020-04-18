class ConvertOriginalTaxonomyString < ActiveRecord::Migration[5.2]
  def up
    change_column_default(:result_taxa, :original_taxonomy_string, nil)
    change_column :result_taxa, :original_taxonomy_string, :text, array: true, using: "(string_to_array(original_taxonomy_string, ','))"
  end

  def down
    change_column :result_taxa, :original_taxonomy_string, :text
  end
end
