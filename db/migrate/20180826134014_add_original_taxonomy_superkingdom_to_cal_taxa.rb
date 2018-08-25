class AddOriginalTaxonomySuperkingdomToCalTaxa < ActiveRecord::Migration[5.2]
  def change
    rename_column :cal_taxa, :original_taxonomy, :original_taxonomy_phylum
    add_column :cal_taxa, :original_taxonomy_superkingdom, :string
  end
end
