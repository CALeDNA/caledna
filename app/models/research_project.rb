# frozen_string_literal: true

class ResearchProject < ApplicationRecord
  LA_RIVER = ResearchProject.find_by(name: 'Los Angeles River')

  has_many :research_project_sources
  has_many :research_project_authors
  has_many :pages
  has_many :researcher_authors, through: :research_project_authors,
                                source: :authorable, source_type: 'Researcher'
  has_many :user_authors, through: :research_project_authors,
                          source: :authorable, source_type: 'User'

  validates :slug, uniqueness: true
  validates :name, presence: true
  validates :slug, presence: true

  scope :published, -> { where(published: true) }

  def project_pages
    @project_pages ||= pages.published
                            .order('display_order ASC NULLS LAST') || []
  end

  def default_page
    @default_page ||= project_pages.first
  end

  def show_pages?
    pages.published.present?
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
end
