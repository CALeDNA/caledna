# frozen_string_literal: true

class Event < ApplicationRecord
  belongs_to :field_data_project, optional: true

  validates :name, :start_date, :end_date, :description, presence: true
end
