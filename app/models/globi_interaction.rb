# frozen_string_literal: true

class GlobiInteraction < ApplicationRecord
  self.table_name = 'external.globi_interactions'

  belongs_to :globi_request
end
