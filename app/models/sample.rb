# frozen_string_literal: true

class Sample < ApplicationRecord
  include PgSearch
  multisearchable against: %i[bar_code latitude longitude]

  belongs_to :project

  scope :processing, -> { where(analyzed: true) }
  scope :with_results, -> { where(with_results: true) }

end
