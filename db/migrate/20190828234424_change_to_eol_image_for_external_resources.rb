class ChangeToEolImageForExternalResources < ActiveRecord::Migration[5.2]
  def change
    rename_column :external_resources, :temp_image, :eol_image
    rename_column :external_resources, :temp_image_source, :eol_image_source
  end
end
