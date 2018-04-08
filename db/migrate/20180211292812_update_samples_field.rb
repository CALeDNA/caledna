# frozen_string_literal: true

class UpdateSamplesField < ActiveRecord::Migration[5.0]
  def change
    add_column :samples, :substrate_cd, :string
    add_column :samples, :ecosystem_category_cd, :string
    add_column :samples, :alt_id, :string
    remove_column :samples, :analysis_date, :datetime
    remove_column :samples, :results_completion_date, :datetime
    rename_column :samples, :bar_code, :barcode
  end
end
