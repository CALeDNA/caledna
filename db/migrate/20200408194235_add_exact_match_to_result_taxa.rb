class AddExactMatchToResultTaxa < ActiveRecord::Migration[5.2]
  def change
    add_column :result_taxa, :exact_match, :boolean, default: true
  end
end
