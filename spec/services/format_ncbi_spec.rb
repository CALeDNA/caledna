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
    let!(:node1) do
      create(:ncbi_node, rank: 'rank1', canonical_name: 'name1',
                         parent_taxon_id: 1)
    end
    let!(:node2) do
      create(:ncbi_node, rank: 'rank2', canonical_name: 'name2',
                         parent_taxon_id: node1.taxon_id)
    end
    let!(:node3) do
      create(:ncbi_node, rank: 'rank3', canonical_name: 'name3',
                         parent_taxon_id: node2.taxon_id)
    end
    let!(:node10) do
      create(:ncbi_node, rank: 'rank10', canonical_name: 'name10',
                         parent_taxon_id: 1)
    end
    let!(:node11) do
      create(:ncbi_node, rank: 'rank11', canonical_name: 'name11',
                         parent_taxon_id: node10.taxon_id)
    end

    context 'when node is a non-root node' do
      it 'adds lineage' do
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

      it 'adds hierarchy when rank is valid' do
        subject

        hierarchy1 = { 'rank1' => node1.taxon_id }
        hierarchy2 = { 'rank2' => node2.taxon_id }
        hierarchy3 = { 'rank3' => node3.taxon_id }
        hierarchy10 = { 'rank10' => node10.taxon_id }
        hierarchy11 = { 'rank11' => node11.taxon_id }

        expect(node1.reload.hierarchy).to eq(hierarchy1)
        expect(node2.reload.hierarchy).to eq(hierarchy1.merge(hierarchy2))
        expect(node3.reload.hierarchy)
          .to eq([hierarchy1, hierarchy2, hierarchy3].inject(&:merge))
        expect(node10.reload.hierarchy).to eq(hierarchy10)
        expect(node11.reload.hierarchy).to eq(hierarchy10.merge(hierarchy11))
      end

      it 'does not add hierarchy when rank is "no rank"' do
        node = create(:ncbi_node, rank: 'no rank', canonical_name: 'name1',
                                  parent_taxon_id: 1)
        subject

        expect(node.reload.hierarchy).to eq({})
      end

      it 'adds hierarchy but skips "no rank"' do
        node1 = create(:ncbi_node, rank: 'rank1', canonical_name: 'name_a',
                                   parent_taxon_id: 1)
        node2 = create(:ncbi_node, rank: 'no rank', canonical_name: 'name_b',
                                   parent_taxon_id: node1.taxon_id)
        node3 = create(:ncbi_node, rank: 'rank3', canonical_name: 'name_c',
                                   parent_taxon_id: node2.taxon_id)
        subject

        hierarchy1 = { 'rank1' => node1.taxon_id }
        hierarchy3 = { 'rank3' => node3.taxon_id }

        expect(node1.reload.hierarchy).to eq(hierarchy1)
        expect(node2.reload.hierarchy).to eq(hierarchy1)
        expect(node3.reload.hierarchy).to eq(hierarchy1.merge(hierarchy3))
      end
    end

    context 'when node is a root node' do
      let(:node) do
        create(:ncbi_node, rank: 'rank1', canonical_name: 'name1',
                           parent_taxon_id: 1, taxon_id: 1)
      end

      it 'does not add lineage' do
        subject

        expect(node.reload.lineage).to eq(nil)
      end

      it 'does not add hierarchy' do
        subject

        expect(node.reload.hierarchy).to eq({})
      end
    end
  end

  describe '#create_taxonomy_strings' do
    def subject
      dummy_class.create_taxonomy_strings
    end
    let!(:node1) do
      create(:ncbi_node, rank: 'superkingdom', canonical_name: 'Superkingdom',
                         parent_taxon_id: 1)
    end
    let!(:node2) do
      create(:ncbi_node, rank: 'kingdom', canonical_name: 'Kingdom',
                         parent_taxon_id: node1.taxon_id)
    end
    let!(:node3) do
      create(:ncbi_node, rank: 'no rank', canonical_name: 'node3',
                         parent_taxon_id: node2.taxon_id)
    end
    let!(:node4) do
      create(:ncbi_node, rank: 'phylum', canonical_name: 'Phylum',
                         parent_taxon_id: node3.taxon_id)
    end
    let!(:node5) do
      create(:ncbi_node, rank: 'no rank', canonical_name: 'node5',
                         parent_taxon_id: node4.taxon_id)
    end
    let!(:node6) do
      create(:ncbi_node, rank: 'family', canonical_name: 'Family',
                         parent_taxon_id: node5.taxon_id)
    end
    let!(:node7) do
      create(:ncbi_node, rank: 'species', canonical_name: 'Species',
                         parent_taxon_id: node6.taxon_id)
    end

    it 'updates taxonomy string for superkingdoms' do
      subject
      node1.reload

      expect(node1.short_taxonomy_string).to eq(nil)
      expect(node1.full_taxonomy_string).to eq('Superkingdom')
    end

    it 'updates taxonomy string for kingdoms' do
      subject
      node2.reload

      expect(node2.short_taxonomy_string).to eq(nil)
      expect(node2.full_taxonomy_string).to eq('Superkingdom;Kingdom')
    end

    it 'updates taxonomy string for "no ranks" before phlyum' do
      subject
      node3.reload

      expect(node3.short_taxonomy_string).to eq(nil)
      expect(node3.full_taxonomy_string)
        .to eq('Superkingdom;Kingdom;node3')
    end

    it 'updates taxonomy string for phylums' do
      subject
      node4.reload

      expect(node4.short_taxonomy_string).to eq('Phylum')
      expect(node4.full_taxonomy_string)
        .to eq('Superkingdom;Kingdom;node3;Phylum')
    end

    it 'updates taxonomy string for "no ranks" after phlyum' do
      subject
      node5.reload

      expect(node5.short_taxonomy_string).to eq('Phylum')
      expect(node5.full_taxonomy_string)
        .to eq('Superkingdom;Kingdom;node3;Phylum;node5')
    end

    it 'updates taxonomy string for family' do
      subject
      node6.reload

      expect(node6.short_taxonomy_string).to eq('Phylum;;;Family')
      expect(node6.full_taxonomy_string)
        .to eq('Superkingdom;Kingdom;node3;Phylum;node5;Family')
    end

    it 'updates taxonomy string for species' do
      subject
      node7.reload

      expect(node7.short_taxonomy_string)
        .to eq('Phylum;;;Family;;Species')
      expect(node7.full_taxonomy_string)
        .to eq('Superkingdom;Kingdom;node3;Phylum;node5;Family;Species')
    end
  end

  describe '#create_citations_nodes' do
    def subject
      dummy_class.create_citations_nodes
    end

    it 'creates NcbiCitationNode for list of taxon ids' do
      citation = create(:ncbi_citation, taxon_id_list: '1 2 3')
      node1 = create(:ncbi_node, taxon_id: 1)
      node2 = create(:ncbi_node, taxon_id: 2)
      node3 = create(:ncbi_node, taxon_id: 3)

      expect { subject }.to change(NcbiCitationNode, :count).by(3)

      expect(NcbiCitationNode.first.ncbi_node).to eq(node1)
      expect(NcbiCitationNode.second.ncbi_node).to eq(node2)
      expect(NcbiCitationNode.third.ncbi_node).to eq(node3)

      NcbiCitationNode.all.each do |cn|
        expect(cn.ncbi_citation).to eq(citation)
      end
    end
  end
end
