class AddNcbiImageToExternalResources < ActiveRecord::Migration[5.2]
  def change
    add_column :external_resources, :inat_image, :string
    add_column :external_resources, :inat_image_source, :string
  end
end
