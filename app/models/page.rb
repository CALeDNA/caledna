# frozen_string_literal: true

class Page < ApplicationRecord
  belongs_to :research_project, optional: true

  before_save :set_slug

  validate :unique_slugs

  as_enum :menu, %i[
    about
    explore_data
    get_involved
    get_involved_community_scientist
    get_involved_researcher
  ], map: :string

  scope :published, -> { where(published: true) }

  def menu_display
    menu_text || title
  end

  def show_project_map?
    return false unless research_project.present?

    self == research_project.default_page
  end

  private

  def unique_slugs
    pages = Page.where(slug: slug)
    return unless pages.count == 1

    research_page = Page.where(slug: slug)
                        .where(research_project_id: research_project_id)
    return unless research_page.count == 1

    errors.add(:slug, 'has already been taken')
  end

  def set_slug
    return if try(:slug).present?
    self.slug = title.parameterize.truncate(80, omission: '')
  end
end
