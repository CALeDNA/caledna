class AddInfraspecificGbifOccurences < ActiveRecord::Migration[5.2]
  def change
    add_column "pour.gbif_occurrences", :infraspecific_epithet, :string
    add_column "pour.gbif_taxa", :verbatim_scientific_name, :string
    add_column "pour.gbif_common_names", :scientific_name, :string
    add_column "pour.gbif_common_names", :taxonomic_status, :string
    add_column "pour.gbif_common_names", :taxon_rank, :string
    add_column "pour.gbif_common_names", :accepted_taxon_id, :bigint
  end
end
