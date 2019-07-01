# frozen_string_literal: true

class Page < ApplicationRecord
  belongs_to :research_project, optional: true

  as_enum :menu, %i[
    about
    explore_data
    get_involved
    get_involved_community_scientist
    get_involved_researcher
  ], map: :string

  scope :published, -> { where(published: true) }

  def menu_display
    menu_text || slug.downcase.titleize
  end

  def show_project_map?
    return false unless research_project.present?

    self == research_project.default_page
  end
end
