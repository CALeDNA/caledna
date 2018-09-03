class AddIndexForPillarPoint < ActiveRecord::Migration[5.2]
  def change
    add_index :external_resources, :source
    add_index :external_resources, :ncbi_id
    add_index :external_resources, :gbif_id
    add_index 'external.gbif_occurrences', :phylum
    add_index 'external.gbif_occurrences', :classname
    add_index 'external.gbif_occurrences', :order
    add_index 'external.gbif_occurrences', :family
    add_index 'external.gbif_occurrences', :genus
    add_index 'external.gbif_occurrences', :species
    add_index :research_project_sources, :sourceable_type
  end
end
