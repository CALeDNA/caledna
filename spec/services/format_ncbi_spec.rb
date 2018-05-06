# frozen_string_literal: true

require 'rails_helper'

describe FormatNcbi do
  let(:dummy_class) { Class.new { extend FormatNcbi } }

  describe '#insert_canonical_name' do
    def subject
      dummy_class.insert_canonical_name
    end

    it 'uses related "scientific names" to add canonical name to NcbiNode' do
      node = create(:ncbi_node, rank: 'superkingdom')
      create(:ncbi_name, name: 'name1', name_class: 'scientific name',
                         taxon_id: node.taxon_id)
      create(:ncbi_name, name: 'name2', name_class: 'random',
                         taxon_id: node.taxon_id)
      subject

      expect(node.reload.canonical_name).to eq('name1')
    end

    it 'ignores non-"scientific names"' do
      node = create(:ncbi_node, rank: 'superkingdom')
      create(:ncbi_name, name: 'name1', name_class: 'random',
                         taxon_id: node.taxon_id)
      subject

      expect(node.canonical_name).to eq(nil)
    end
  end

  describe 'update_lineages' do
    def subject
      dummy_class.update_lineages
    end

    it 'adds lineage to every non-root NcbiNode' do
      node1 = create(:ncbi_node, rank: 'rank1', canonical_name: 'name1',
                                 parent_taxon_id: 1)
      node2 = create(:ncbi_node, rank: 'rank2', canonical_name: 'name2',
                                 parent_taxon_id: node1.taxon_id)
      node3 = create(:ncbi_node, rank: 'rank3', canonical_name: 'name3',
                                 parent_taxon_id: node2.taxon_id)
      node10 = create(:ncbi_node, rank: 'rank10', canonical_name: 'name10',
                                  parent_taxon_id: 1)
      node11 = create(:ncbi_node, rank: 'rank11', canonical_name: 'name11',
                                  parent_taxon_id: node10.taxon_id)
      subject

      lineage1 = [node1.taxon_id.to_s, 'name1', 'rank1']
      lineage2 = [node2.taxon_id.to_s, 'name2', 'rank2']
      lineage3 = [node3.taxon_id.to_s, 'name3', 'rank3']
      lineage10 = [node10.taxon_id.to_s, 'name10', 'rank10']
      lineage11 = [node11.taxon_id.to_s, 'name11', 'rank11']

      expect(node1.reload.lineage).to eq([lineage1])
      expect(node2.reload.lineage).to eq([lineage1, lineage2])
      expect(node3.reload.lineage).to eq([lineage1, lineage2, lineage3])
      expect(node10.reload.lineage).to eq([lineage10])
      expect(node11.reload.lineage).to eq([lineage10, lineage11])
    end

    it 'ignores the root NcbiNode' do
      node1 = create(:ncbi_node, rank: 'rank1', canonical_name: 'name1',
                                 parent_taxon_id: 1, taxon_id: 1)
      subject

      expect(node1.reload.lineage).to eq(nil)
    end
  end
end
