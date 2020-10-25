class UpdateExternalInatGbif < ActiveRecord::Migration[5.2]
  def change
    drop_table 'external.inat_observations'
    drop_table 'external.inat_taxa'
    drop_table 'external.gbif_datasets'
    drop_table 'external.gbif_taxa'
    drop_table 'external.gbif_vernaculars'
  end
end
