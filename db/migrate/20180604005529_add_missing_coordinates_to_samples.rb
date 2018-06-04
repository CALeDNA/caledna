class AddMissingCoordinatesToSamples < ActiveRecord::Migration[5.0]
  def up
    add_column :samples, :missing_coordinates, :boolean, default: false
    samples = Sample.where(status_cd: 'missing_coordinates')
    samples.update(missing_coordinates: true)
  end

  def down
    remove_column :samples, :missing_coordinates
  end
end
