# frozen_string_literal: true

class Sample < ApplicationRecord
  include PgSearch
  multisearchable against: %i[barcode status_cd latitude longitude
                              field_data_project_name]

  belongs_to :field_data_project
  has_many :photos
  has_many :extractions

  validates :barcode,
            uniqueness: { message: 'barcode %<value>s is already taken' },
            if: proc { |a| a.approved? }

  scope :analyzed, -> { where(status_cd: :analyzed) }
  scope :results_completed, -> { where(status_cd: :results_completed) }
  scope :approved, (lambda do
    where.not(status_cd: :submitted).where.not(status_cd: :rejected)
    .where.not(status_cd: :missing_coordinates)
    .where.not(status_cd: :duplicate_barcode)
  end)

  as_enum :status,
          %i[submitted approved rejected duplicate_barcode assigned analyzed
             results_completed missing_coordinates],
          map: :string
  as_enum :substrate, %i[soil sediment water other], map: :string
  as_enum :ecosystem_category, %i[terrestrial aquatic], map: :string

  def status_display
    status.to_s.tr('_', ' ')
  end

  def field_data_project_name
    field_data_project.name
  end

  def asvs_count
    return nil if extractions.last.nil?

    extractions.sum { |e| e.asvs.count }
  end
end
