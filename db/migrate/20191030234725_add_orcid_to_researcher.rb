class AddOrcidToResearcher < ActiveRecord::Migration[5.2]
  def change
    add_column :researchers, :orcid, :string
  end
end
