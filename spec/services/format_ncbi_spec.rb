# frozen_string_literal: true

require 'rails_helper'

describe FormatNcbi do
  let(:dummy_class) { Class.new { extend FormatNcbi } }

  describe '#create_alt_names' do
    def subject
      dummy_class.create_alt_names
    end

    it 'adds one name to alt_name when there is one related name' do
      node = create(:ncbi_node, taxon_id: 1)
      create(:ncbi_name, taxon_id: 1, name: 'name', name_class: 'synonym')
      subject

      expect(node.reload.alt_names).to eq('name')
    end

    it 'adds multiple names to alt_name when there arme many related names' do
      node = create(:ncbi_node, taxon_id: 1)
      create(:ncbi_name, taxon_id: 1, name: 'name1', name_class: 'synonym')
      create(:ncbi_name, taxon_id: 1, name: 'name2', name_class: 'synonym')
      subject

      expect(node.reload.alt_names).to eq('name2 | name1')
    end

    it 'appends new name to alt_name when alt_name has content' do
      node = create(:ncbi_node, taxon_id: 1, alt_names: 'name1')
      create(:ncbi_name, taxon_id: 1, name: 'name2', name_class: 'synonym')
      create(:ncbi_name, taxon_id: 1, name: 'name3', name_class: 'synonym')
      subject

      expect(node.reload.alt_names).to eq('name3 | name2 | name1')
    end

    it 'does not change alt_name when name_class is invalid' do
      node = create(:ncbi_node, taxon_id: 1)
      create(:ncbi_name, taxon_id: 1, name: 'name', name_class: 'random')
      subject

      expect(node.reload.alt_names).to eq(nil)
    end

    it 'ignores names for other taxons' do
      node = create(:ncbi_node, taxon_id: 1)
      create(:ncbi_node, taxon_id: 2)
      create(:ncbi_name, taxon_id: 2, name: 'name', name_class: 'synonym')
      subject

      expect(node.reload.alt_names).to eq(nil)
    end

    it 'updates multiple ncbi_nodes' do
      node1 = create(:ncbi_node, taxon_id: 1)
      create(:ncbi_name, taxon_id: 1, name: 'name1', name_class: 'synonym')

      node2 = create(:ncbi_node, taxon_id: 2)
      create(:ncbi_name, taxon_id: 2, name: 'name2', name_class: 'synonym')
      subject

      expect(node1.reload.alt_names).to eq('name1')
      expect(node2.reload.alt_names).to eq('name2')
    end

    it 'removes quotes before adding to alt_name' do
      node = create(:ncbi_node, taxon_id: 1)
      create(:ncbi_name, taxon_id: 1, name: "name 'a'", name_class: 'synonym')
      subject

      expect(node.reload.alt_names).to eq('name a')
    end
  end

  describe 'create_taxa_tree' do
    def subject
      dummy_class.create_taxa_tree
    end
    let!(:node1) do
      create(:ncbi_node, rank: 'rank1', canonical_name: 'name1',
                         parent_taxon_id: 1, ncbi_id: 100)
    end
    let!(:node2) do
      create(:ncbi_node, rank: 'rank2', canonical_name: 'name2',
                         parent_taxon_id: node1.ncbi_id, ncbi_id: 200)
    end
    let!(:node3) do
      create(:ncbi_node, rank: 'rank3', canonical_name: 'name3',
                         parent_taxon_id: node2.ncbi_id, ncbi_id: 300)
    end

    let!(:node4) do
      create(:ncbi_node, rank: 'rank4', canonical_name: 'name4',
                         parent_taxon_id: node1.ncbi_id, ncbi_id: 400)
    end
    let!(:node5) do
      create(:ncbi_node, rank: 'rank5', canonical_name: 'name5',
                         parent_taxon_id: node4.ncbi_id, ncbi_id: 500)
    end

    context 'when node is a non-root node' do
      it 'adds ids' do
        subject
        id1 = node1.reload.ncbi_id
        id2 = node2.reload.ncbi_id
        id3 = node3.reload.ncbi_id
        id4 = node4.reload.ncbi_id
        id5 = node5.reload.ncbi_id

        expect(node1.ids).to eq([id1])
        expect(node2.ids).to eq([id1, id2])
        expect(node3.ids).to eq([id1, id2, id3])
        expect(node4.ids).to eq([id1, id4])
        expect(node5.ids).to eq([id1, id4, id5])

        expect(node1.ranks).to eq(['rank1'])
        expect(node2.ranks).to eq(%w[rank1 rank2])
        expect(node3.ranks).to eq(%w[rank1 rank2 rank3])
        expect(node4.ranks).to eq(%w[rank1 rank4])
        expect(node5.ranks).to eq(%w[rank1 rank4 rank5])

        expect(node1.names).to eq(['name1'])
        expect(node2.names).to eq(%w[name1 name2])
        expect(node3.names).to eq(%w[name1 name2 name3])
        expect(node4.names).to eq(%w[name1 name4])
        expect(node5.names).to eq(%w[name1 name4 name5])

        expect(node1.full_taxonomy_string).to eq('name1')
        expect(node2.full_taxonomy_string).to eq('name1|name2')
        expect(node3.full_taxonomy_string).to eq('name1|name2|name3')
        expect(node4.full_taxonomy_string).to eq('name1|name4')
        expect(node5.full_taxonomy_string).to eq('name1|name4|name5')

        expect(node1.hierarchy).to eq('rank1' => id1)
        expect(node2.hierarchy).to eq('rank1' => id1, 'rank2' => id2)
        expect(node3.hierarchy)
          .to eq('rank1' => id1, 'rank2' => id2, 'rank3' => id3)
        expect(node4.hierarchy).to eq('rank1' => id1, 'rank4' => id4)
        expect(node5.hierarchy)
          .to eq('rank1' => id1, 'rank4' => id4, 'rank5' => id5)

        expect(node1.hierarchy_names).to eq('rank1' => 'name1')
        expect(node2.hierarchy_names)
          .to eq('rank1' => 'name1', 'rank2' => 'name2')
        expect(node3.hierarchy_names)
          .to eq('rank1' => 'name1', 'rank2' => 'name2', 'rank3' => 'name3')
        expect(node4.hierarchy_names)
          .to eq('rank1' => 'name1', 'rank4' => 'name4')
        expect(node5.hierarchy_names)
          .to eq('rank1' => 'name1', 'rank4' => 'name4', 'rank5' => 'name5')
      end
    end

    context 'when node is a root node' do
      let(:node) do
        create(:ncbi_node, rank: 'rank1', canonical_name: 'name1',
                           parent_taxon_id: 1, taxon_id: 1)
      end

      it 'does not add ids' do
        subject

        expect(node.reload.ids).to eq([])
      end
    end
  end
end
