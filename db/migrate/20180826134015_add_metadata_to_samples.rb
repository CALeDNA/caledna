class AddMetadataToSamples < ActiveRecord::Migration[5.2]
  def change
    add_column :samples, :metadata, :jsonb, default: {}
  end
end
