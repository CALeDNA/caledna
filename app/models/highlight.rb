# frozen_string_literal: true

class Highlight < ApplicationRecord
  belongs_to :highlightable, polymorphic: true

  scope :asv, -> { where(highlightable_type: 'Asv') }

  def project
    return unless highlightable_type == 'Asv'
    highlightable.extraction.sample.field_data_project
  end

  def sample
    return unless highlightable_type == 'Asv'
    highlightable.extraction.sample
  end
end
