class UpdateResearchProjects < ActiveRecord::Migration[5.2]
  require_relative('../raw_sql')
  include RawSql

  def up
    remove_column :research_projects, :description, :text
    execute 'DROP VIEW IF EXISTS ggbn_completed_samples;'
    change_column :research_projects, :decontamination_method, :text
    execute create_ggbn_completed_samples_view
  end

  def down
    add_column :research_projects, :description, :text

    execute 'DROP VIEW IF EXISTS ggbn_completed_samples;'
    change_column :research_projects, :decontamination_method, :string
    execute create_ggbn_completed_samples_view
  end
end
