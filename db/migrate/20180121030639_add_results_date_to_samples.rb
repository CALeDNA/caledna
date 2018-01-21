class AddResultsDateToSamples < ActiveRecord::Migration[5.0]
  def change
    add_column :samples, :results_date, :datetime
    add_column :samples, :with_results, :boolean, default: false
  end
end
