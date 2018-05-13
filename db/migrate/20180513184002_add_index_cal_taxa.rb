class AddIndexCalTaxa < ActiveRecord::Migration[5.0]
  def change
    add_index :cal_taxa, :original_taxonomy
  end
end
