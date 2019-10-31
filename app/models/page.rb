# frozen_string_literal: true

class Page < ApplicationRecord
  belongs_to :research_project, optional: true
  belongs_to :website

  before_save :set_slug

  validates :website, presence: true
  validate :unique_slugs

  as_enum :menu, %i[
    about
    explore_data
    get_involved
    get_involved_community_scientist
    get_involved_researcher
  ], map: :string

  scope :published, -> { where(published: true) }
  scope :current_site, -> { where(website: Website::DEFAULT_SITE) }

  def menu_display
    menu_text || title
  end

  private

  def unique_slugs
    limit = new_record? ? 0 : 1
    if research_project_id?
      return if existing_research_pages
                .where(research_project: research_project).count <= limit
    else
      # rubocop:disable Style/IfInsideElse
      return if existing_pages.count <= limit
      # rubocop:enable Style/IfInsideElse
    end

    errors.add(:slug, 'has already been taken')
  end

  def existing_pages
    @existing_pages ||= begin
      Page.current_site
          .where(slug: slug)
          .where('research_project_id IS NULL')
    end
  end

  def existing_research_pages
    @existing_research_pages ||= begin
      Page.current_site
          .where(slug: slug)
          .where('research_project_id IS NOT NULL')
    end
  end

  def set_slug
    return if try(:slug).present?
    self.slug = title.parameterize.truncate(80, omission: '')
  end
end
