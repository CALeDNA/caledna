class AddNcbiNameToExtResources < ActiveRecord::Migration[5.2]
  def change
    add_column :external_resources, :ncbi_name, :string, index: true
  end
end
