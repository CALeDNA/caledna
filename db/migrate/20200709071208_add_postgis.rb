class AddPostgis < ActiveRecord::Migration[5.2]
  def up
    execute 'CREATE EXTENSION IF NOT EXISTS postgis;'
  end

  def down; end
end
