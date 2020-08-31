class AddTaxonomyStringTiAsv < ActiveRecord::Migration[5.2]
  def change
    add_column :asvs, :taxonomy_string, :string
  end
end
