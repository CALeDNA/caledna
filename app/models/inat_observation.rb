# frozen_string_literal: true

class InatObservation < ApplicationRecord
  has_many :research_project_sources, as: :sourceable
end
