class AddImagesExternalResources < ActiveRecord::Migration[5.2]
  def change
    add_column :external_resources, :temp_image, :string
    add_column :external_resources, :temp_image_source, :string
  end
end
