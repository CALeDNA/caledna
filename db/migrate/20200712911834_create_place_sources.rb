class CreatePlaceSources < ActiveRecord::Migration[5.2]
  def change
    create_table :place_sources do |t|
      t.string :name
      t.string :url
      t.string :file_name
      t.string :place_source_type_cd
      t.timestamp
    end
  end
end
