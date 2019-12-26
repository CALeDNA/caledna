class CreateGgbnSamplesView < ActiveRecord::Migration[5.2]
  require_relative('../raw_sql')
  include RawSql

  def up
    execute create_ggbn_completed_samples_view
  end

  def down
    execute 'DROP VIEW IF EXISTS ggbn_completed_samples;'
  end
end
