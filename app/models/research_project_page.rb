# frozen_string_literal: true

class ResearchProjectPage < ApplicationRecord
  belongs_to :research_project

  validates :body, :title, :slug, :menu_text, presence: true
  validate :unique_slugs

  scope :published, -> { where(published: true) }

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
    return if existing_research_pages.count <= limit

    errors.add(:slug, 'has already been taken')
  end

  def existing_research_pages
    @existing_research_pages ||= begin
      ResearchProjectPage
        .where(slug: slug)
        .where(research_project: research_project)
    end
  end
end
