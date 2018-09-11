# frozen_string_literal: true

class GlobiRequest < ApplicationRecord
  self.table_name = 'external.globi_requests'

  has_many :research_project_sources, as: :sourceable
end
