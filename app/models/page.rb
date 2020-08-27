# frozen_string_literal: true

class Page < ApplicationRecord
  belongs_to :website
  has_many :page_blocks

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
  scope :current_site, -> { where(website: Website.default_site) }

  def show_edit_link?(current_researcher)
    return false if current_researcher.blank?

    current_researcher.director? || current_researcher.superadmin?
  end

  private

  def unique_slugs
    limit = new_record? ? 0 : 1
    return if Page.current_site.where(slug: slug).count <= limit

    errors.add(:slug, 'has already been taken')
  end
end
