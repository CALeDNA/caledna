class AddFieldsToInatTaxa < ActiveRecord::Migration[5.2]
  def change
    add_column 'external.inat_taxa', :ids, :string, array: true, default: []
    add_column 'external.inat_taxa', :photo, :jsonb, default: {}
    add_column 'external.inat_taxa', :wikipedia_url, :string
  end
end

