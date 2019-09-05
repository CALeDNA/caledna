class AddIdToGlobiInteractions < ActiveRecord::Migration[5.2]
  def change
    add_column 'external.globi_interactions', :id, :primary_key
    add_column 'external.globi_interactions', :target_ncbi_id, :bigint
    add_column 'external.globi_interactions', :target_gbif_id, :bigint
    add_column 'external.globi_interactions', :source_ncbi_id, :bigint
    add_column 'external.globi_interactions', :source_gbif_id, :bigint

    add_index 'external.globi_interactions', :target_ncbi_id,
              name: 'globi_interactions_on_targetNcbiId'
    add_index 'external.globi_interactions', :target_gbif_id,
              name: 'globi_interactions_on_targetGbifId'
    add_index 'external.globi_interactions', :source_ncbi_id,
              name: 'globi_interactions_on_sourceNcbiId'
    add_index 'external.globi_interactions', :source_gbif_id,
              name: 'globi_interactions_on_sourceGbifId'
  end
end
