# frozen_string_literal: true

class ChangeToAsv < ActiveRecord::Migration[5.0]
  def change
    rename_table :specimens, :asvs
  end
end
