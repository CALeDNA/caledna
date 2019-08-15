class AddInatPayloadToExternalSources < ActiveRecord::Migration[5.2]
  def change
    add_column :external_resources, :inat_payload, :jsonb, default: {}
  end
end
