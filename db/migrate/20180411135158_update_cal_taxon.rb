class UpdateCalTaxon < ActiveRecord::Migration[5.0]
  def change
    add_column :cal_taxa, :complete_taxonomy, :string
  end
end
