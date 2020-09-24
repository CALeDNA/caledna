class AddNamesToPourGbif < ActiveRecord::Migration[5.2]
  def change
    add_column 'pour.gbif_taxa', :names, :text, array:true, default: []
    add_index 'pour.gbif_taxa', :names, using: :gin
  end
end
