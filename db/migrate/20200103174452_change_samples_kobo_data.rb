class ChangeSamplesKoboData < ActiveRecord::Migration[5.2]
  def change
    change_column_default :samples, :kobo_data, from: '{}', to: {}
  end
end
