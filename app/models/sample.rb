# frozen_string_literal: true

class Sample < ApplicationRecord
  include PgSearch
  multisearchable against: %i[bar_code latitude longitude]

  belongs_to :project

  scope :analyzed, -> { where(status_cd: :analyzed) }
  scope :results_completed, -> { where(status_cd: :results_completed) }

  as_enum :status, %i[submitted approved analyzed results_completed],
          map: :string

  def status_display
    status.to_s.tr('_', ' ')
  end
end
