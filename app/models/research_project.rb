# frozen_string_literal: true

class ResearchProject < ApplicationRecord
  has_many :research_project_sources
  has_many :pages
  before_save :set_slug

  scope :published, -> { where(published: true) }

  def extractions
    research_project_sources.where(sourceable_type: 'Extraction')
  end

  def project_pages
    pages.published.order('display_order ASC NULLS LAST') || []
  end

  def default_page
    project_pages.first
  end

  def show_pages?
    pages.published.present?
  end

  private

  def set_slug
    return if try(:slug).nil?
    self.slug = name.parameterize.truncate(80, omission: '')
  end
end
