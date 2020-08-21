class AddPrimerIdsToSamples < ActiveRecord::Migration[5.2]
  def change
    add_column :samples, :primer_ids, :integer, array: true, default: '{}'
  end
end
