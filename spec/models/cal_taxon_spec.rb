# frozen_string_literal: true

require 'rails_helper'

describe CalTaxon, type: :model do
  describe 'validations' do
    it 'does not require hierarchy on create' do
      taxon = build(:cal_taxon, hierarchy: nil)

      expect(taxon).to be_valid
    end

    it 'requires hierarchy on update' do
      taxon = create(:cal_taxon, hierarchy: nil)
      taxon.update(phylum: 'phylum')

      expect(taxon).to_not be_valid
      expect(taxon.errors.messages).to eq(hierarchy: ["can't be blank"])
    end

    it 'passes when at least one taxonomy field is present' do
      taxon = build(:cal_taxon, phylum: 'phylum', className: nil, order: nil,
                                family: nil, genus: nil, specificEpithet: nil)

      expect(taxon).to be_valid
    end

    it 'fails when at there are no taxonomy fields' do
      taxon = build(:cal_taxon, phylum: nil, className: nil, order: nil,
                                family: nil, genus: nil, specificEpithet: nil)

      expect(taxon).to_not be_valid
      expect(taxon.errors.messages.keys).to eq([:at_least_one_taxa])
    end

    it 'passes when taxon rank is valid' do
      should validate_inclusion_of(:taxonRank).in_array(CalTaxon::TAXON_RANK)
    end

    it 'passes when taxon status is valid' do
      should validate_inclusion_of(:taxonomicStatus)
        .in_array(CalTaxon::TAXON_STATUS)
    end

    it 'passes when kingdom and canonicalName are unique' do
      create(:cal_taxon, kingdom: 'kingdom_1', canonicalName: 'name_1')
      taxon = build(:cal_taxon, kingdom: 'kingdom_1', canonicalName: 'name_2')

      expect(taxon).to be_valid
    end

    it 'fails when kingdom and canonicalName are not unique' do
      create(:cal_taxon, kingdom: 'kingdom_1', canonicalName: 'name_1')
      taxon = build(:cal_taxon, kingdom: 'kingdom_1', canonicalName: 'name_1')

      expect(taxon).to be_invalid
      expect(taxon.errors.messages)
        .to eq(canonicalName: ['has already been taken'])
    end
  end
end
