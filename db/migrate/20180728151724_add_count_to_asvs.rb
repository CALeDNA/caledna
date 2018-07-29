class AddCountToAsvs < ActiveRecord::Migration[5.2]
  def change
    add_column :asvs, :count, :integer, default: 0
  end
end
