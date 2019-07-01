class AddPublishToFieldDataProjects < ActiveRecord::Migration[5.2]
  def change
    add_column :field_data_projects, :published, :boolean, default: true
  end
end
