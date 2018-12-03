class AddPaperMatchToCombineTaxa < ActiveRecord::Migration[5.2]
  def change
    add_column :combine_taxa, :paper_match_type, :string
  end
end
