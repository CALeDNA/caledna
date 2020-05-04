# frozen_string_literal: true

class Page < ApplicationRecord
  belongs_to :research_project, optional: true
  belongs_to :website

  validates :website, :body, :title, :slug, presence: true
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

  def show_edit_link?(current_researcher)
    return false if current_researcher.blank?

    if research_project_id.present?
      return true if current_researcher.director?
      return true if current_researcher.superadmin?
      research_page_author?(current_researcher)
    else
      current_researcher.director? || current_researcher.superadmin?
    end
  end

  private

  def research_page_author?(user)
    return if research_project_id.blank?

    project = ResearchProject.find(research_project_id)
    authors = project.research_project_authors
                     .where(authorable_id: user.id)
    authors.present?
  end

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
end
