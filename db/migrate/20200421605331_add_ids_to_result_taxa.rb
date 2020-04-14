class AddIdsToResultTaxa < ActiveRecord::Migration[5.2]
  def change
    add_column :result_taxa, :ncbi_id, :integer
    add_column :result_taxa, :bold_id, :integer
    add_column :result_taxa, :ncbi_version_id, :integer
    rename_column :result_taxa, :sources, :result_sources
    add_index :result_taxa, :taxon_id
  end
end
