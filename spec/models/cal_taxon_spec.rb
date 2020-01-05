# frozen_string_literal: true

require 'rails_helper'

describe CalTaxon, type: :model do
  describe 'validations' do
    it 'passes when taxon rank is valid' do
      should validate_inclusion_of(:taxon_rank).in_array(CalTaxon::TAXON_RANK)
    end
  end
end
