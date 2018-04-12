# frozen_string_literal: true

class FieldDataProject < ApplicationRecord
  DEFAULT_PROJECT = FieldDataProject.find_by(name: 'unknown')

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
end
