class AddNotesToCalTaxa < ActiveRecord::Migration[5.0]
  def change
    add_column :cal_taxa, :notes, :text
  end
end
