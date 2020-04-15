# frozen_string_literal: true

class FieldProject < ApplicationRecord
  DEFAULT_PROJECT = FieldProject.find_by(name: 'unknown')
  MULTI_SAMPLE_PROJECTS = [95_481, 87_534, 95_664, 83_937].freeze
  SINGLE_SAMPLE_PROJECTS_V1 = [136_577, 130_560, 138_676, 170_620].freeze
  LA_RIVER = FieldProject.find_by(name: 'Los Angeles River')

  has_one_attached :image
  has_many :samples
  has_many :events

  scope :published, -> { where(published: true) }

  def multi_sample_form?
    MULTI_SAMPLE_PROJECTS.include?(kobo_id)
  end

  def single_sample_v1_form?
    SINGLE_SAMPLE_PROJECTS_V1.include?(kobo_id)
  end

  def single_sample_v2_form?
    !(MULTI_SAMPLE_PROJECTS + SINGLE_SAMPLE_PROJECTS_V1).include?(kobo_id)
  end
end
