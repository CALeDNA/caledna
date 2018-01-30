# frozen_string_literal: true

class Sample < ApplicationRecord
  include PgSearch
  multisearchable against: %i[bar_code status_cd latitude longitude
                              project_name]

  belongs_to :project
  belongs_to :processor, class_name: 'Researcher', foreign_key: 'processor_id',
                         optional: true
  has_many :photos

  scope :analyzed, -> { where(status_cd: :analyzed) }
  scope :results_completed, -> { where(status_cd: :results_completed) }

  as_enum :status, %i[submitted approved analyzed results_completed],
          map: :string

  def status_display
    status.to_s.tr('_', ' ')
  end

  # NOTE: project_name exists mainlly so it can be indexed for searches
  def project_name
    project.name
  end
end
