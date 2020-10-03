class AddOccurenceCountGbifTaxa < ActiveRecord::Migration[5.2]
  def change
    add_column 'pour.gbif_taxa', :occurrence_count, :integer
  end
end
