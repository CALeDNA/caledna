# frozen_string_literal: true

class RenameProjectsToFieldDataProjects < ActiveRecord::Migration[5.0]
  def change
    rename_table :projects, :field_data_projects
    rename_column :samples, :project_id, :field_data_project_id
  end
end
