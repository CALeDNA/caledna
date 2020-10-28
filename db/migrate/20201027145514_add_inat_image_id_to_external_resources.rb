class AddInatImageIdToExternalResources < ActiveRecord::Migration[5.2]
  def change
    add_column :external_resources, :inat_image_id, :bigint
  end
end
