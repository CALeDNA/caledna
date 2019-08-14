class AddSourceToInat < ActiveRecord::Migration[5.2]
  def change
    add_column 'external.inat_taxa', :source, :string
  end
end
