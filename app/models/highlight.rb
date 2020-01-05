# frozen_string_literal: true

class Highlight < ApplicationRecord
  belongs_to :highlightable, polymorphic: true

  scope :asv, -> { where(highlightable_type: 'Asv') }

  def project
    return unless highlightable_type == 'Asv'
    highlightable.sample.field_project
  end

  def sample
    return unless highlightable_type == 'Asv'
    highlightable.sample
  end
end
