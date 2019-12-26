class ChangeReseaarchProjectPrimers < ActiveRecord::Migration[5.2]
  def change
    remove_column :research_projects, :primers
    add_column :research_projects, :primers, :string, array: true, default: []
  end
end
