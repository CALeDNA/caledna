class AddSpeciesToInatObs < ActiveRecord::Migration[5.2]
  def change
    add_column 'external.inat_observations', :canonical_name, :string
  end
end
