# frozen_string_literal: true

class PrimerSample < ApplicationRecord
  self.table_name = 'primers_samples'
  belongs_to :sample
  belongs_to :primer
end
