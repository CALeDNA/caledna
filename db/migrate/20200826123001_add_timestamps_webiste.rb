class AddTimestampsWebiste < ActiveRecord::Migration[5.2]
  def change
    # https://stackoverflow.com/a/46521142
    add_timestamps :websites, null: true

    now = DateTime.now
    Website.update_all(created_at: now, updated_at: now)

    change_column_null :websites, :created_at, false
    change_column_null :websites, :updated_at, false
  end
end
