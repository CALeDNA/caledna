# frozen_string_literal: true

class GlobiRequest < ApplicationRecord
  self.table_name = 'external.globi_requests'

  has_many :globi_interactions
end
