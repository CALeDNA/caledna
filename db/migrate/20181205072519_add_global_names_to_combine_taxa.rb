class AddGlobalNamesToCombineTaxa < ActiveRecord::Migration[5.2]
  def change
    add_column :combine_taxa, :global_names, :jsonb
  end
end
