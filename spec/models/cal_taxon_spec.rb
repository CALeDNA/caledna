# frozen_string_literal: true

require 'rails_helper'

describe CalTaxon, type: :model do
  describe 'validations' do
    it 'does not require hierarchy on create' do
      taxon = build(:cal_taxon, hierarchy: nil)

      expect(taxon).to be_valid
    end

    it 'passes when at least one taxonomy field is present' do
      taxon = create(:cal_taxon)
      taxon.update(phylum: 'phylum', className: nil, order: nil,
                   family: nil, genus: nil, specificEpithet: nil,
                   hierarchy: { phylum: 'phylum' })

      expect(taxon).to be_valid
    end

    it 'passes when taxon rank is valid' do
      should validate_inclusion_of(:taxonRank).in_array(CalTaxon::TAXON_RANK)
    end

    xit 'passes when taxon status is valid' do
      should validate_inclusion_of(:taxonomicStatus)
        .in_array(CalTaxon::TAXON_STATUS)
    end

    it 'passes when kingdom and canonicalName are unique' do
      create(:cal_taxon, kingdom: 'kingdom_1', canonicalName: 'name_1')
      taxon = create(:cal_taxon)
      taxon.update(kingdom: 'kingdom_1', canonicalName: 'name_2',
                   hierarchy: { kingdom: 'kingdom_1' })

      expect(taxon).to be_valid
    end
  end
end
