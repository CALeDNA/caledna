class AddTaxaIndexes < ActiveRecord::Migration[5.0]
  def change
    add_index :taxa, [:kingdom, :phylum, :className, :order, :family,
      :genus, :canonicalName, :taxonRank], name: :taxonomy_idx
  end
end
