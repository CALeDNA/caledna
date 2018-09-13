class AddIndexesToGlobi < ActiveRecord::Migration[5.2]
  def change
    add_index 'external.globi_interactions', :sourceTaxonName
    add_index 'external.globi_interactions', :targetTaxonName
    add_index 'external.globi_interactions', :targetTaxonId
  end
end
