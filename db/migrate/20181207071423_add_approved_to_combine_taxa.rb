class AddApprovedToCombineTaxa < ActiveRecord::Migration[5.2]
  def change
    add_column :combine_taxa, :approved, :boolean
    rename_column :combine_taxa, :taxon_id, :source_taxon_id
    add_column :combine_taxa, :caledna_taxon_id, :bigint
  end
end
