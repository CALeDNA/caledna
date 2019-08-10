class ChangeTaxonIdInatObs < ActiveRecord::Migration[5.2]
  def change
      change_column :inat_observations, :taxonID,
        'integer USING CAST(inat_observations."taxonID" AS integer)'
  end
end
