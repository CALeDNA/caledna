# frozen_string_literal: true

class Event < ApplicationRecord
  belongs_to :field_data_project, optional: true
  has_one_attached :flyer

  validates :name, :start_date, :end_date, :description, presence: true

  def flyer?
    flyer.attachment.present?
  end
end
