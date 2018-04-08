# frozen_string_literal: true

class AddRolesToResearcher < ActiveRecord::Migration[5.0]
  def change
    add_column :researchers, :role_cd, :string, default: :sample_processor
  end
end
