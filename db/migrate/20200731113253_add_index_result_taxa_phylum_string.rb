class AddIndexResultTaxaPhylumString < ActiveRecord::Migration[5.2]
  def change
    add_index :result_taxa, :clean_taxonomy_string_phylum
    add_index :result_taxa, :taxon_rank
  end
end
