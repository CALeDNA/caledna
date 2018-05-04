# frozen_string_literal: true

class FieldDataProject < ApplicationRecord
  DEFAULT_PROJECT = FieldDataProject.find_by(name: 'unknown')
  MULTI_SAMPLE_FORM_IDS = [95_481, 87_534, 95_664, 83_937].freeze
  SINGLE_SAMPLE_FORM_V1_IDS = [136_577, 130_560, 138_676, 170_620].freeze

  validates :kobo_id, uniqueness: true

  has_many :samples, dependent: :destroy

  def approved_samples_count
    samples.select do |s|
      s.status_cd != 'submitted' && s.status_cd != 'rejected'
    end.count
  end

  def analyzed_samples_count
    samples.select { |s| s.status_cd == 'analyzed' }.count
  end

  def results_completed_samples_count
    samples.select { |s| s.status_cd == 'results_completed' }.count
  end

  def multi_sample_form?
    MULTI_SAMPLE_FORM_IDS.include?(kobo_id)
  end

  def single_sample_v1_form?
    SINGLE_SAMPLE_FORM_V1_IDS.include?(kobo_id)
  end

  def single_sample_v2_form?
    !(MULTI_SAMPLE_FORM_IDS + SINGLE_SAMPLE_FORM_V1_IDS).include?(kobo_id)
  end
end
