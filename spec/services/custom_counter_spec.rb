# frozen_string_literal: true

require 'rails_helper'

describe 'CustomCounter' do
  let(:dummy_class) { Class.new { extend CustomCounter } }

  describe '#update_asvs_count' do
    def subject
      dummy_class.update_asvs_count
    end
    let(:ncbi_node1) do
      create(:ncbi_node, taxon_id: 1, ids: [1])
    end
    let(:ncbi_node2) do
      create(
        :ncbi_node,
        taxon_id: 2,
        ids: [1, 2]
      )
    end
    let(:ncbi_node3) do
      create(:ncbi_node, taxon_id: 3, ids: [3])
    end
    let(:ncbi_node4) do
      create(:ncbi_node, taxon_id: 4, ids: [4])
    end
    let(:extraction1) do
      create(:extraction, sample: sample1)
    end
    let(:extraction2) do
      create(:extraction, sample: sample2)
    end
    let(:extraction3) do
      create(:extraction, sample: sample3)
    end
    let(:extraction4) do
      create(:extraction, sample: sample3)
    end

    let(:sample1) do
      create(:sample, missing_coordinates: false)
    end
    let(:sample2) do
      create(:sample, missing_coordinates: false)
    end
    let(:sample3) { create(:sample, missing_coordinates: false) }

    it 'updates asvs_count when NcbiNode has many related asvs' do
      create(:asv, extraction: extraction1, sample: sample1,
                   taxonID: ncbi_node2.taxon_id)
      create(:asv, extraction: extraction3, sample: sample3,
                   taxonID: ncbi_node2.taxon_id)
      subject

      expect(ncbi_node2.reload.asvs_count).to eq(2)
    end

    it 'updates asvs_count when NcbiNode has one related asvs' do
      create(:asv, extraction: extraction2, sample: sample2,
                   taxonID: ncbi_node3.taxon_id)
      subject

      expect(ncbi_node3.reload.asvs_count).to eq(1)
    end

    it 'only counts a NcbiNode once per sample' do
      create(:asv, extraction: extraction3, sample: sample3,
                   taxonID: ncbi_node1.taxon_id)
      create(:asv, extraction: extraction4, sample: sample3,
                   taxonID: ncbi_node1.taxon_id)
      subject

      expect(ncbi_node1.reload.asvs_count).to eq(1)
    end

    it 'includes descendant NcbiNode in asvs_count' do
      create(:asv, extraction: extraction1, sample: sample1,
                   taxonID: ncbi_node1.taxon_id)
      create(:asv, extraction: extraction2, sample: sample2,
                   taxonID: ncbi_node1.taxon_id)
      create(:asv, extraction: extraction3, sample: sample3,
                   taxonID: ncbi_node2.taxon_id)
      subject

      expect(ncbi_node1.reload.asvs_count).to eq(3)
    end

    it 'does not update asvs_count when NcbiNode does not have related asvs' do
      subject

      expect(ncbi_node4.reload.asvs_count).to eq(0)
    end
  end
end
