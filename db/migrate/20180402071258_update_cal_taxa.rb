class UpdateCalTaxa < ActiveRecord::Migration[5.0]
  def up
    add_column :cal_taxa, :original_taxonomy, :string
    add_column :cal_taxa, :original_hierarchy, :jsonb
    add_column :cal_taxa, :normalized, :boolean, default: false
    add_column :cal_taxa, :genericName, :string

    rename_column :cal_taxa, :taxonID, :id
    add_column :cal_taxa, :taxonID, :integer

    drop_table :normalize_taxa
  end

  def down
    remove_column :cal_taxa, :original_taxonomy
    remove_column :cal_taxa, :original_hierarchy
    remove_column :cal_taxa, :normalized
    remove_column :cal_taxa, :genericName

    remove_column :cal_taxa, :taxonID, :integer
    rename_column :cal_taxa, :id, :taxonID

    create_table :normalize_taxa do |t|
      t.string :rank_cd
      t.jsonb :hierarchy, default: {}
      t.string :taxonomy_string
      t.boolean :normalized, default: false
    end
  end
end
