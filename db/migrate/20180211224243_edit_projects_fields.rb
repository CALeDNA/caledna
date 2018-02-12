class EditProjectsFields < ActiveRecord::Migration[5.0]
  def change
    remove_column :projects, :kobo_name, :string
    remove_column :projects, :start_date, :datetime
    add_column :projects, :date_range, :string
  end
end
