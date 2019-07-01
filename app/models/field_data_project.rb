# frozen_string_literal: true

class FieldDataProject < ApplicationRecord
  DEFAULT_PROJECT = FieldDataProject.find_by(name: 'unknown')
  MULTI_SAMPLE_PROJECTS = [95_481, 87_534, 95_664, 83_937].freeze
  SINGLE_SAMPLE_PROJECTS_V1 = [136_577, 130_560, 138_676, 170_620].freeze

  validates :kobo_id, uniqueness: true

  has_many :samples, dependent: :destroy
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
