class AddMetadataToResearchProject < ActiveRecord::Migration[5.2]
  def change
    add_column :research_projects, :reference_barcode_database, :text
    add_column :research_projects, :dryad_link, :string
    add_column :research_projects, :decontamination_method, :string
    add_column :research_projects, :primers, :string
    add_column :research_projects, :metadata, :jsonb, default: {}
  end
end
