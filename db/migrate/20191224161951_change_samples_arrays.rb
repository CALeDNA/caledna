class ChangeSamplesArrays < ActiveRecord::Migration[5.2]
  require_relative('../raw_sql')
  include RawSql

  def up
    execute 'DROP VIEW IF EXISTS ggbn_completed_samples;'
    remove_column :samples, :environmental_features
    add_column :samples, :environmental_features, :string, array: true, default: []
    remove_column :samples, :environmental_settings
    add_column :samples, :environmental_settings, :string,  array: true, default: []
    execute create_ggbn_completed_samples_view
  end

  def down
    execute 'DROP VIEW IF EXISTS ggbn_completed_samples;'
    change_column :samples, :environmental_features, :string
    change_column :samples, :environmental_settings, :string
    execute create_ggbn_completed_samples_view
  end
end
