# frozen_string_literal: true

class UserSubmission < ApplicationRecord
  has_one_attached :image
  belongs_to :user

  validates :user_display_name, :title, :content, presence: true

  scope :approved, -> { where(approved: true) }
end
