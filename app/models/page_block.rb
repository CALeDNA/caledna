# frozen_string_literal: true

class PageBlock < ApplicationRecord
  belongs_to :page, optional: true
  belongs_to :website
  has_one_attached :image

  as_enum :image_position, %i[
    left
    right
  ], map: :string

end
