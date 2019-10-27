class RenameFieldProject < ActiveRecord::Migration[5.2]
  def change
    rename_column :events, :field_data_project_id, :field_project_id
    rename_table :field_data_projects, :field_projects
    rename_column :samples, :field_data_project_id, :field_project_id
  end
end
