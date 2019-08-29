class ChangeExternalResourcesImageSource < ActiveRecord::Migration[5.2]
  def change
    rename_column :external_resources, :eol_image_source, :eol_image_attribution
    rename_column :external_resources, :inat_image_source,
                  :inat_image_attribution
  end
end
