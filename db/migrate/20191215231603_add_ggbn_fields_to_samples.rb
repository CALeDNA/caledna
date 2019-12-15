class AddGgbnFieldsToSamples < ActiveRecord::Migration[5.2]
  def change
    add_column :samples, :country, :string, default: 'United States of America'
    add_column :samples, :country_code, :string, default: 'US'
    add_column :samples, :has_permit, :boolean, default: true
  end
end
