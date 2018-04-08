# frozen_string_literal: true

class CreateNormalizeTaxa < ActiveRecord::Migration[5.0]
  def change
    create_table :normalize_taxa do |t|
      t.string :rank_cd
      t.jsonb :hierarchy, default: {}
      t.string :taxonomy_string
      t.boolean :normalized, default: false
    end
  end
end
