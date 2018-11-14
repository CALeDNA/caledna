class AddCountsToAsvs < ActiveRecord::Migration[5.2]
  def change
    add_column :asvs, :counts, :jsonb, default: {}
  end
end
