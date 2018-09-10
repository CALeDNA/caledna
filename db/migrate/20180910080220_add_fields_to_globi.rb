class AddFieldsToGlobi < ActiveRecord::Migration[5.2]
  def change
    rename_column 'external.globi_interactions', :source_taxon_external_id, :source_taxon_id
    add_column 'external.globi_interactions', :source_taxon_ids, :string
    add_column 'external.globi_interactions', :source_taxon_rank, :string
    rename_column 'external.globi_interactions', :source_taxon_path, :source_taxon_path_names
    add_column 'external.globi_interactions', :source_taxon_path_ids, :string
    add_column 'external.globi_interactions', :source_taxon_path_rank_names, :string
    add_column 'external.globi_interactions', :source_id, :string
    add_column 'external.globi_interactions', :source_occurrence_id, :string
    add_column 'external.globi_interactions', :source_catalog_number, :string
    add_column 'external.globi_interactions', :source_basis_of_record_id, :string
    add_column 'external.globi_interactions', :source_basis_of_record_name, :string
    rename_column 'external.globi_interactions', :interaction_type, :interaction_type_name
    rename_column 'external.globi_interactions', :target_taxon_external_id, :target_taxon_id
    add_column 'external.globi_interactions', :target_taxon_ids, :string
    add_column 'external.globi_interactions', :target_taxon_rank, :string
    rename_column 'external.globi_interactions', :target_taxon_path, :target_taxon_path_names
    add_column 'external.globi_interactions', :target_taxon_path_ids, :string
    add_column 'external.globi_interactions', :target_taxon_path_rank_names, :string
    add_column 'external.globi_interactions', :target_id, :string
    add_column 'external.globi_interactions', :target_occurrence_id, :string
    add_column 'external.globi_interactions', :target_catalog_number, :string
    add_column 'external.globi_interactions', :target_basis_of_record_id, :string
    add_column 'external.globi_interactions', :target_basis_of_record_name, :string
  end
end
