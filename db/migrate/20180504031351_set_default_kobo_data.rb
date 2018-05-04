class SetDefaultKoboData < ActiveRecord::Migration[5.0]
  def up
    change_column :samples, :kobo_data, :jsonb, default: '{}'
    execute 'UPDATE samples SET kobo_data = \'{}\' WHERE kobo_data IS NULL;'
  end

  def down
  end
end
