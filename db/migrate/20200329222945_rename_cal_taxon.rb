class RenameCalTaxon < ActiveRecord::Migration[5.2]
  def change
    rename_table :cal_taxa, :result_taxa
  end
end
