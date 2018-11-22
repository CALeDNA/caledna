class AddDivisionToCombineTaxa < ActiveRecord::Migration[5.2]
  def change
    add_index :combine_taxa, :taxon_id
    add_column :combine_taxa, :cal_division_id, :integer
    add_index :combine_taxa, :cal_division_id
  end
end
