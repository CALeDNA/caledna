class RenameAsvsTaxonId < ActiveRecord::Migration[5.2]
  def change
    rename_column :asvs, 'taxonID', :taxon_id
  end
end
