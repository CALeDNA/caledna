class AddIdsToGbifTaxa < ActiveRecord::Migration[5.2]
  def change
    add_column 'pour.gbif_taxa', :ids, :integer, array: true, default: []
    add_index 'pour.gbif_taxa', :ids, using: :gin
  end
end
