class AddInfraspeciesPourInat < ActiveRecord::Migration[5.2]
  def change
    add_column 'pour.inat_taxa', :form, :string
    add_column 'pour.inat_taxa', :variety, :string
    add_column 'pour.inat_taxa', :subspecies, :string
    add_column 'pour.inat_taxa', :infraspecific_epithet, :string
    add_column 'pour.inat_taxa', :canonical_name, :string
  end
end
