class AddCanonicalNameToResultTaxa < ActiveRecord::Migration[5.2]
  def change
    add_column :result_taxa, :canonical_name, :string, index: true
  end
end
