class AddInactiveToExternalResources < ActiveRecord::Migration[5.2]
  def change
    add_column :external_resources, :active, :boolean, default: true
  end
end
