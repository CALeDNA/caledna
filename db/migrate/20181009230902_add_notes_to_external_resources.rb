class AddNotesToExternalResources < ActiveRecord::Migration[5.2]
  def change
    add_column :external_resources, :notes, :string
  end
end
