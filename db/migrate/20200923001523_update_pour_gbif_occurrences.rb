class UpdatePourGbifOccurrences < ActiveRecord::Migration[5.2]
  def change
    remove_column 'pour.gbif_occurrences', :infraspecific_epithet, :string
    add_column 'pour.gbif_occurrences', :verbatim_scientific_name_authorship, :string
    add_column 'pour.gbif_occurrences', :locality, :string
    add_column 'pour.gbif_occurrences', :occurrence_status, :string
    add_column 'pour.gbif_occurrences', :individual_count, :integer
    add_column 'pour.gbif_occurrences', :publishing_org_key, :string
    add_column 'pour.gbif_occurrences', :coordinate_precision, :decimal
    add_column 'pour.gbif_occurrences', :elevation, :integer
    add_column 'pour.gbif_occurrences', :elevation_accuracy, :integer
    add_column 'pour.gbif_occurrences', :depth, :integer
    add_column 'pour.gbif_occurrences', :depth_accuracy, :integer
    add_column 'pour.gbif_occurrences', :day, :integer
    add_column 'pour.gbif_occurrences', :month, :integer
    add_column 'pour.gbif_occurrences', :year, :integer
    add_column 'pour.gbif_occurrences', :institution_code, :string
    add_column 'pour.gbif_occurrences', :collection_code, :string
    add_column 'pour.gbif_occurrences', :record_number, :integer
    add_column 'pour.gbif_occurrences', :type_status, :string
    add_column 'pour.gbif_occurrences', :establishment_means, :string
  end
end
