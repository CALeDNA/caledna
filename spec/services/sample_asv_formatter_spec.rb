# frozen_string_literal: true

require 'rails_helper'

describe SampleAsvFormatter do
  let(:dummy_class) { Class.new { extend SampleAsvFormatter } }

  describe '#create_tree_objects' do
    def subject(taxon_object, rank)
      dummy_class.create_tree_objects(taxon_object, rank)
    end

    let(:taxon_object) do
      {
        superkingdom: 'su', kingdom: 'k', phylum: 'p', class: 'c', order: 'o',
        family: 'f', genus: 'g', species: 'sp',
        superkingdom_id: 1, kingdom_id: 2, phylum_id: 3, class_id: 4,
        order_id: 5, family_id: 6, genus_id: 7, species_id: 8
      }
    end

    it 'creates tree objects for species' do
      rank = 'species'
      taxon_object[:rank] = rank
      expected = [
        { name: 'sp', parent: 7, id: 8 },
        { name: 'g', parent: 6, id: 7 },
        { name: 'f', parent: 5, id: 6 },
        { name: 'o', parent: 4, id: 5 },
        { name: 'c', parent: 3, id: 4 },
        { name: 'p', parent: 2, id: 3 },
        { name: 'k', parent: 'Life', id: 2 }
      ]
      expect(subject(taxon_object, rank)).to eq(expected)
    end

    it 'creates tree objects for genus' do
      rank = 'genus'
      taxon_object[:rank] = rank
      expected = [
        { name: 'g', parent: 6, id: 7 },
        { name: 'f', parent: 5, id: 6 },
        { name: 'o', parent: 4, id: 5 },
        { name: 'c', parent: 3, id: 4 },
        { name: 'p', parent: 2, id: 3 },
        { name: 'k', parent: 'Life', id: 2 }
      ]
      expect(subject(taxon_object, rank)).to eq(expected)
    end

    it 'creates tree objects for family' do
      rank = 'family'
      taxon_object[:rank] = rank
      expected = [
        { name: 'f', parent: 5, id: 6 },
        { name: 'o', parent: 4, id: 5 },
        { name: 'c', parent: 3, id: 4 },
        { name: 'p', parent: 2, id: 3 },
        { name: 'k', parent: 'Life', id: 2 }
      ]
      expect(subject(taxon_object, rank)).to eq(expected)
    end

    it 'creates tree objects for order' do
      rank = 'order'
      taxon_object[:rank] = rank
      expected = [
        { name: 'o', parent: 4, id: 5 },
        { name: 'c', parent: 3, id: 4 },
        { name: 'p', parent: 2, id: 3 },
        { name: 'k', parent: 'Life', id: 2 }
      ]
      expect(subject(taxon_object, rank)).to eq(expected)
    end

    it 'creates tree objects for class' do
      rank = 'class'
      taxon_object[:rank] = rank
      expected = [
        { name: 'c', parent: 3, id: 4 },
        { name: 'p', parent: 2, id: 3 },
        { name: 'k', parent: 'Life', id: 2 }
      ]
      expect(subject(taxon_object, rank)).to eq(expected)
    end

    it 'creates tree objects for phylum' do
      rank = 'phylum'
      taxon_object[:rank] = rank
      expected = [
        { name: 'p', parent: 2, id: 3 },
        { name: 'k', parent: 'Life', id: 2 }
      ]
      expect(subject(taxon_object, rank)).to eq(expected)
    end

    it 'creates tree objects for kingdom' do
      rank = 'kingdom'
      taxon_object[:rank] = rank
      expected = [
        { name: 'k', parent: 'Life', id: 2 }
      ]
      expect(subject(taxon_object, rank)).to eq(expected)
    end

    it 'returns [] for superkingdom' do
      rank = 'superkingdom'
      taxon_object[:rank] = rank
      expected = []
      expect(subject(taxon_object, rank)).to eq(expected)
    end
  end

  describe '#create_taxon_object' do
    def subject(taxon)
      dummy_class.create_taxon_object(taxon)
    end

    let(:names) do
      {
        superkingdom: 'su', kingdom: 'k', phylum: 'p', class: 'c', order: 'o',
        family: 'f', genus: 'g', species: 'sp'
      }
    end

    let(:ids) do
      {
        superkingdom: 1, kingdom: 2, phylum: 3, class: 4, order: 5,
        family: 6, genus: 7, species: 8
      }
    end

    let(:division) { create(:ncbi_division, id: 100, name: 'division') }

    def remove_keys(keys)
      keys.each do |key|
        names.delete(key)
        ids.delete(key)
      end
    end

    it 'converts taxons that are species' do
      rank = 'species'
      taxon = create(:ncbi_node, hierarchy_names: names, hierarchy: ids,
                                 rank: rank, cal_division_id: division.id)
      expected = {
        kingdom: 'division', phylum: 'p', class: 'c', order: 'o',
        family: 'f', genus: 'g', species: 'sp',
        kingdom_id: 100, phylum_id: 3, class_id: 4,
        order_id: 5, family_id: 6, genus_id: 7, species_id: 8
      }
      # debugger

      expect(subject(taxon)).to eq(expected)
    end

    it 'converts taxons that are genus' do
      rank = 'genus'
      remove_keys([:species])

      taxon = create(:ncbi_node, hierarchy_names: names, hierarchy: ids,
                                 rank: rank, cal_division_id: division.id)
      expected = {
        kingdom: 'division', phylum: 'p', class: 'c', order: 'o',
        family: 'f', genus: 'g',
        kingdom_id: 100, phylum_id: 3, class_id: 4,
        order_id: 5, family_id: 6, genus_id: 7
      }

      expect(subject(taxon)).to eq(expected)
    end

    it 'converts taxons that are family' do
      rank = 'family'
      remove_keys(%i[species genus])

      taxon = create(:ncbi_node, hierarchy_names: names, hierarchy: ids,
                                 rank: rank, cal_division_id: division.id)
      expected = {
        kingdom: 'division', phylum: 'p', class: 'c', order: 'o',
        family: 'f',
        kingdom_id: 100, phylum_id: 3, class_id: 4,
        order_id: 5, family_id: 6
      }

      expect(subject(taxon)).to eq(expected)
    end

    it 'converts taxons that are order' do
      rank = 'order'
      remove_keys(%i[species genus family])

      taxon = create(:ncbi_node, hierarchy_names: names, hierarchy: ids,
                                 rank: rank, cal_division_id: division.id)
      expected = {
        kingdom: 'division', phylum: 'p', class: 'c', order: 'o',
        kingdom_id: 100, phylum_id: 3, class_id: 4,
        order_id: 5
      }

      expect(subject(taxon)).to eq(expected)
    end

    it 'converts taxons that are class' do
      rank = 'class'
      remove_keys(%i[species genus family order])

      taxon = create(:ncbi_node, hierarchy_names: names, hierarchy: ids,
                                 rank: rank, cal_division_id: division.id)
      expected = {
        kingdom: 'division', phylum: 'p', class: 'c',
        kingdom_id: 100, phylum_id: 3, class_id: 4
      }

      expect(subject(taxon)).to eq(expected)
    end

    it 'converts taxons that are phylum' do
      rank = 'phylum'
      remove_keys(%i[species genus family order class])

      taxon = create(:ncbi_node, hierarchy_names: names, hierarchy: ids,
                                 rank: rank, cal_division_id: division.id)
      expected = {
        kingdom: 'division', phylum: 'p',
        kingdom_id: 100, phylum_id: 3
      }

      expect(subject(taxon)).to eq(expected)
    end

    it 'converts taxons that are kingdom' do
      rank = 'kingdom'
      remove_keys(%i[species genus family order class phylum])

      taxon = create(:ncbi_node, hierarchy_names: names, hierarchy: ids,
                                 rank: rank, cal_division_id: division.id)
      expected = {
        kingdom: 'division',
        kingdom_id: 100
      }

      expect(subject(taxon)).to eq(expected)
    end

    it 'returns {} for superkingdom' do
      rank = 'superkingdom'
      remove_keys(%i[species genus family order class phylum kingdom])

      taxon = create(:ncbi_node, hierarchy_names: names, hierarchy: ids,
                                 rank: rank, cal_division_id: division.id)
      expected = {}

      expect(subject(taxon)).to eq(expected)
    end

    it 'converts taxons with only species' do
      rank = 'species'
      names = { species: 'sp' }
      ids = { species: 8 }

      taxon = create(:ncbi_node, hierarchy_names: names, hierarchy: ids,
                                 rank: rank, cal_division_id: division.id)
      expected = {
        kingdom: 'division',
        phylum: 'phylum for sp',
        class: 'class for sp',
        order: 'order for sp',
        family: 'family for sp',
        genus: 'genus for sp',
        species: 'sp',
        kingdom_id: 100,
        phylum_id: 'p_c_o_f_g_8',
        class_id: 'c_o_f_g_8',
        order_id: 'o_f_g_8',
        family_id: 'f_g_8',
        genus_id: 'g_8',
        species_id: 8
      }

      expect(subject(taxon)).to eq(expected)
    end

    it 'converts taxons with one blank rank' do
      rank = 'species'
      remove_keys(%i[genus])

      taxon = create(:ncbi_node, hierarchy_names: names, hierarchy: ids,
                                 rank: rank, cal_division_id: division.id)
      expected = {
        kingdom: 'division', phylum: 'p', class: 'c', order: 'o',
        family: 'f', genus: 'genus for sp', species: 'sp',
        kingdom_id: 100, phylum_id: 3, class_id: 4,
        order_id: 5, family_id: 6, genus_id: 'g_8', species_id: 8
      }

      expect(subject(taxon)).to eq(expected)
    end

    it 'converts taxons with back-to-back blank ranks' do
      rank = 'species'
      remove_keys(%i[genus family])

      taxon = create(:ncbi_node, hierarchy_names: names, hierarchy: ids,
                                 rank: rank, cal_division_id: division.id)
      expected = {
        kingdom: 'division', phylum: 'p', class: 'c', order: 'o',
        family: 'family for sp', genus: 'genus for sp', species: 'sp',
        kingdom_id: 100, phylum_id: 3, class_id: 4,
        order_id: 5, family_id: 'f_g_8', genus_id: 'g_8', species_id: 8
      }

      expect(subject(taxon)).to eq(expected)
    end

    it 'converts taxons with multiple back-to-back blank rank' do
      rank = 'species'
      remove_keys(%i[genus family phylum kingdom])

      taxon = create(:ncbi_node, hierarchy_names: names, hierarchy: ids,
                                 rank: rank, cal_division_id: division.id)
      expected = {
        kingdom: 'division', phylum: 'phylum for c', class: 'c',
        order: 'o', family: 'family for sp', genus: 'genus for sp',
        species: 'sp',
        kingdom_id: 100, phylum_id: 'p_4', class_id: 4,
        order_id: 5, family_id: 'f_g_8', genus_id: 'g_8', species_id: 8
      }

      expect(subject(taxon)).to eq(expected)
    end
  end
end
