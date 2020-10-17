class RenameToCanononicalGbifTaxa < ActiveRecord::Migration[5.2]
  def change
    rename_column "pour.gbif_taxa", :verbatim_scientific_name, :canonical_name
  end
end
