class AddPhylumMatchTypeToResultTaxa < ActiveRecord::Migration[5.2]
  def up
    add_column :result_taxa, :match_type_cd, :string
    add_column :result_taxa, :clean_taxonomy_string_phylum, :string
    execute 'UPDATE result_taxa set clean_taxonomy_string_phylum = ' \
      "regexp_replace(clean_taxonomy_string, '^.*?;' , '');"
  end

  def down
    remove_column :result_taxa, :match_type_cd, :string
    remove_column :result_taxa, :clean_taxonomy_string_phylum, :string
  end
end
