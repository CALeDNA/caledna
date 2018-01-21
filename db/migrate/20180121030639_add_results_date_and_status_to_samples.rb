class AddResultsDateAndStatusToSamples < ActiveRecord::Migration[5.0]
  def change
    add_column :samples, :results_completion_date, :datetime
    add_column :samples, :status_cd, :string, default: :submitted
    remove_column :samples, :analyzed, :boolean
    remove_column :samples, :approved, :boolean
  end
end
