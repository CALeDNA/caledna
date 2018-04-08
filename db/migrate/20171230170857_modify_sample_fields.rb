# frozen_string_literal: true

class ModifySampleFields < ActiveRecord::Migration[5.0]
  def change
    rename_column :samples, :letter_code, :location_letter
    add_column :samples, :site_number, :string
    add_column :samples, :collection_date, :datetime
    add_column :projects, :last_import_date, :datetime
  end
end
