class RenamePhotos < ActiveRecord::Migration[5.2]
  def change
    rename_table :photos, :kobo_photos
  end
end
