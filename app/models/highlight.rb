class Highlight < ApplicationRecord
  belongs_to :highlightable, polymorphic: true

  def project
    return if highlightable_type == 'Taxon'
    highlightable.extraction.sample.field_data_project
  end

  def sample
    return if highlightable_type == 'Taxon'
    highlightable.extraction.sample
  end
end
