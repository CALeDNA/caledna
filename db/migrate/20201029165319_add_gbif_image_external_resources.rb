class AddGbifImageExternalResources < ActiveRecord::Migration[5.2]
  def change
    add_column :external_resources, :gbif_image, :string
    add_column :external_resources, :gbif_image_attribution, :string
  end
end
