class AddExactGbifMatchToCalTaxon < ActiveRecord::Migration[5.0]
  def up
    add_column :cal_taxa, :exact_gbif_match, :boolean, default: false
    execute 'ALTER TABLE cal_taxa ALTER "taxonID" SET DEFAULT currval(\'cal_taxa_taxonID_seq\');'
  end

  def down
    remove_column :cal_taxa, :exact_gbif_match, :boolean, default: false
    execute 'ALTER TABLE cal_taxa ALTER "taxonID" SET DEFAULT NULL;'
  end
end
