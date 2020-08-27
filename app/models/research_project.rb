# frozen_string_literal: true

class ResearchProject < ApplicationRecord
  has_many :research_project_sources
  has_many :research_project_authors
  has_many :research_project_pages
  has_many :researcher_authors, through: :research_project_authors,
                                source: :authorable, source_type: 'Researcher'
  has_many :user_authors, through: :research_project_authors,
                          source: :authorable, source_type: 'User'
  has_many :sample_primers

  validates :slug, uniqueness: true
  validates :name, presence: true
  validates :slug, presence: true

  scope :published, -> { where(published: true) }
  scope :la_river, -> { find_by(name: 'Los Angeles River') }
  scope :pillar_point, -> { find_by(name: 'Pillar Point') }

  def project_pages
    @project_pages ||= begin
      research_project_pages
        .published.order('display_order ASC NULLS LAST') || []
    end
  end

  def default_page
    @default_page ||= project_pages.first
  end

  def show_pages?
    research_project_pages.published.present?
  end

  def metadata_display
    return {} if metadata == '{}'

    metadata.except(
      'reference_barcode_database',
      'Dryad_link',
      'decontamination_method',
      'primers'
    )
  end

  def primers_string
    sample_primers.joins(:primer).select('distinct(primers.name)')
                  .map(&:name).join(', ')
  end
end
