class AddTolIdToExternalResources < ActiveRecord::Migration[5.2]
  def change
    add_column :external_resources, :tol_id, :integer
  end
end
