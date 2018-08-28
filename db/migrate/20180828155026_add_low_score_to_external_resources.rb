class AddLowScoreToExternalResources < ActiveRecord::Migration[5.2]
  def change
    add_column :external_resources, :low_score, :boolean
    add_column :external_resources, :vernaculars, :string, array: true,
               default: []
    add_column :external_resources, :search_term, :string
  end
end
