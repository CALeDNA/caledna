# frozen_string_literal: true

class FieldProject < ApplicationRecord
  MULTI_SAMPLE_PROJECTS = [95_481, 87_534, 95_664, 83_937].freeze
  SINGLE_SAMPLE_PROJECTS_V1 = [136_577, 130_560, 138_676, 170_620].freeze

  has_one_attached :image
  has_many :samples
  has_many :events

  scope :published, -> { where(published: true) }
  scope :default_project, -> { find_by(name: 'unknown') }
  scope :la_river, -> { where("name LIKE 'Los Angeles River%'") }

  def self.la_river_ids
    la_river.ids.to_s.tr('[', '(').tr(']', ')')
  end

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
