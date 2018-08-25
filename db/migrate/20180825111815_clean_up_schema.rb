class CleanUpSchema < ActiveRecord::Migration[5.2]
  def up
    execute 'DROP SEQUENCE IF EXISTS external_resources_taxon_id_seq CASCADE;'
    change_column_default :cal_taxa, :normalized, nil
    change_column_default :cal_taxa, :exact_gbif_match, nil
    change_column_default :cal_taxa, :taxonID, nil
  end
end
