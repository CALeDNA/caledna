# frozen_string_literal: true

class AddActiveToResearchers < ActiveRecord::Migration[5.0]
  def change
    add_column :researchers, :active, :boolean, default: true
  end
end
