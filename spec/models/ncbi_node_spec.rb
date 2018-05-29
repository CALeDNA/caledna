# frozen_string_literal: true

require 'rails_helper'

describe NcbiNode do
  describe '#conservation_status' do
    it 'returns IUCN status if status exists' do
      status = IucnStatus::CATEGORIES.values.first
      taxon = create(:ncbi_node)
      create(:external_resource, taxon_id: taxon.id, iucn_status: status)

      expect(taxon.conservation_status).to eq(status)
    end

    it 'returns null if IUCN status does not exists' do
      taxon = create(:ncbi_node)
      create(:external_resource, taxon_id: taxon.id, iucn_status: nil)

      expect(taxon.conservation_status).to eq(nil)
    end
  end

  describe '#conservation_status?' do
    it 'returns true if taxon has IUCN status' do
      status = IucnStatus::CATEGORIES.values.first
      taxon = create(:ncbi_node)
      create(:external_resource, taxon_id: taxon.id, iucn_status: status)

      expect(taxon.conservation_status?).to eq(true)
    end

    it 'returns false if taxon does not have IUCN status' do
      taxon = create(:ncbi_node)
      create(:external_resource, taxon_id: taxon.id, iucn_status: nil)

      expect(taxon.conservation_status?).to eq(false)
    end
  end

  describe '#threatened?' do
    it 'returns true if taxon IUCN status belongs to THREATENED' do
      status = IucnStatus::THREATENED.values.first
      taxon = create(:ncbi_node)
      create(:external_resource, taxon_id: taxon.id, iucn_status: status)

      expect(taxon.threatened?).to eq(true)
    end

    it 'returns false if taxon does not belong to THREATENED' do
      status = 'random'
      taxon = create(:ncbi_node)
      create(:external_resource, taxon_id: taxon.id, iucn_status: status)

      expect(taxon.threatened?).to eq(false)
    end
  end
end
