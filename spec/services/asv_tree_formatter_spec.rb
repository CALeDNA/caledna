# frozen_string_literal: true

require 'rails_helper'

describe AsvTreeFormatter do
  let(:dummy_class) { Class.new { extend AsvTreeFormatter } }

  describe '#create_tree_objects' do
    def subject(taxon_object, rank)
      dummy_class.create_tree_objects(taxon_object, rank)
    end

    let(:taxon_object) do
      {
        superkingdom: 'su', kingdom: 'k', phylum: 'p', class: 'c', order: 'o',
        family: 'f', genus: 'g', species: 'sp',
        superkingdom_id: 1, kingdom_id: 2, phylum_id: 3, class_id: 4,
        order_id: 5, family_id: 6, genus_id: 7, species_id: 8,
        common_name: 'cn'
      }
    end

    it 'creates tree objects for species' do
      rank = 'species'
      expected = [
        { name: 'sp', parent: 7, id: 8, common_name: nil },
        { name: 'g', parent: 6, id: 7, common_name: nil },
        { name: 'f', parent: 5, id: 6, common_name: nil },
        { name: 'o', parent: 4, id: 5, common_name: nil },
        { name: 'c', parent: 3, id: 4, common_name: nil },
        { name: 'p', parent: 2, id: 3, common_name: nil },
        { name: 'k', parent: 'Life', id: 2, common_name: nil }
      ]
      expect(subject(taxon_object, rank)).to eq(expected)
    end

    it 'creates tree objects for genus' do
      rank = 'genus'
      expected = [
        { name: 'g', parent: 6, id: 7, common_name: nil },
        { name: 'f', parent: 5, id: 6, common_name: nil },
        { name: 'o', parent: 4, id: 5, common_name: nil },
        { name: 'c', parent: 3, id: 4, common_name: nil },
        { name: 'p', parent: 2, id: 3, common_name: nil },
        { name: 'k', parent: 'Life', id: 2, common_name: nil }
      ]
      expect(subject(taxon_object, rank)).to eq(expected)
    end

    it 'creates tree objects for family' do
      rank = 'family'
      expected = [
        { name: 'f', parent: 5, id: 6, common_name: nil },
        { name: 'o', parent: 4, id: 5, common_name: nil },
        { name: 'c', parent: 3, id: 4, common_name: nil },
        { name: 'p', parent: 2, id: 3, common_name: nil },
        { name: 'k', parent: 'Life', id: 2, common_name: nil }
      ]
      expect(subject(taxon_object, rank)).to eq(expected)
    end

    it 'creates tree objects for order' do
      rank = 'order'
      expected = [
        { name: 'o', parent: 4, id: 5, common_name: nil },
        { name: 'c', parent: 3, id: 4, common_name: nil },
        { name: 'p', parent: 2, id: 3, common_name: nil },
        { name: 'k', parent: 'Life', id: 2, common_name: nil }
      ]
      expect(subject(taxon_object, rank)).to eq(expected)
    end

    it 'creates tree objects for class' do
      rank = 'class'
      expected = [
        { name: 'c', parent: 3, id: 4, common_name: nil },
        { name: 'p', parent: 2, id: 3, common_name: nil },
        { name: 'k', parent: 'Life', id: 2, common_name: nil }
      ]
      expect(subject(taxon_object, rank)).to eq(expected)
    end

    it 'creates tree objects for phylum' do
      rank = 'phylum'
      expected = [
        { name: 'p', parent: 2, id: 3, common_name: nil },
        { name: 'k', parent: 'Life', id: 2, common_name: nil }
      ]
      expect(subject(taxon_object, rank)).to eq(expected)
    end

    it 'creates tree objects for kingdom' do
      rank = 'kingdom'
      expected = [
        { name: 'k', parent: 'Life', id: 2, common_name: nil }
      ]
      expect(subject(taxon_object, rank)).to eq(expected)
    end

    it 'returns [] for superkingdom' do
      rank = 'superkingdom'
      expected = []
      expect(subject(taxon_object, rank)).to eq(expected)
    end
  end

  describe '#create_tree_object' do
    def subject(taxon_object, rank, parent_id, id)
      dummy_class.create_tree_object(taxon_object, rank, parent_id, id)
    end

    let(:taxon_object) do
      {
        superkingdom: 'su', kingdom: 'k', phylum: 'p', class: 'c', order: 'o',
        family: 'f', genus: 'g', species: 'sp',
        superkingdom_id: 1, kingdom_id: 2, phylum_id: 3, class_id: 4,
        order_id: 5, family_id: 6, genus_id: 7, species_id: 8,
        common_name: 'cn'
      }
    end

    it 'returns an object for a specified rank' do
      expected = { name: 'g', parent: 6, id: 7, common_name: nil }

      expect(subject(taxon_object, :genus, :family_id, :genus_id))
        .to eq(expected)
    end

    it 'add common name if specified rank matches original rank' do
      taxon_object[:original_rank] = 'genus'
      expected = { name: 'g (cn)', parent: 6, id: 7, common_name: 'cn' }

      expect(subject(taxon_object, :genus, :family_id, :genus_id))
        .to eq(expected)
    end

    it 'does not add common name if specified rank != original rank' do
      taxon_object[:original_rank] = 'species'
      expected = { name: 'g', parent: 6, id: 7, common_name: nil }

      expect(subject(taxon_object, :genus, :family_id, :genus_id))
        .to eq(expected)
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

    def append_taxon(taxon, common_name = nil)
      OpenStruct.new(taxon.attributes
                          .merge(domain: 'division', common_name: common_name))
    end

    it 'converts taxons that are species' do
      rank = 'species'
      taxon = create(:ncbi_node, hierarchy_names: names, hierarchy: ids,
                                 rank: rank, cal_division_id: division.id)
      taxon = append_taxon(taxon)

      expected = {
        kingdom: 'division', phylum: 'p', class: 'c', order: 'o',
        family: 'f', genus: 'g', species: 'sp',
        kingdom_id: 100, phylum_id: 3, class_id: 4,
        order_id: 5, family_id: 6, genus_id: 7, species_id: 8,
        common_name: nil,
        original_rank: rank
      }

      expect(subject(taxon)).to eq(expected)
    end

    it 'converts taxons that are genus' do
      rank = 'genus'
      remove_keys([:species])

      taxon = create(:ncbi_node, hierarchy_names: names, hierarchy: ids,
                                 rank: rank, cal_division_id: division.id)
      taxon = append_taxon(taxon)
      expected = {
        kingdom: 'division', phylum: 'p', class: 'c', order: 'o',
        family: 'f', genus: 'g',
        kingdom_id: 100, phylum_id: 3, class_id: 4,
        order_id: 5, family_id: 6, genus_id: 7,
        common_name: nil,
        original_rank: rank
      }

      expect(subject(taxon)).to eq(expected)
    end

    it 'converts taxons that are family' do
      rank = 'family'
      remove_keys(%i[species genus])

      taxon = create(:ncbi_node, hierarchy_names: names, hierarchy: ids,
                                 rank: rank, cal_division_id: division.id)
      taxon = append_taxon(taxon)
      expected = {
        kingdom: 'division', phylum: 'p', class: 'c', order: 'o',
        family: 'f',
        kingdom_id: 100, phylum_id: 3, class_id: 4,
        order_id: 5, family_id: 6,
        common_name: nil,
        original_rank: rank
      }

      expect(subject(taxon)).to eq(expected)
    end

    it 'converts taxons that are order' do
      rank = 'order'
      remove_keys(%i[species genus family])

      taxon = create(:ncbi_node, hierarchy_names: names, hierarchy: ids,
                                 rank: rank, cal_division_id: division.id)
      taxon = append_taxon(taxon)
      expected = {
        kingdom: 'division', phylum: 'p', class: 'c', order: 'o',
        kingdom_id: 100, phylum_id: 3, class_id: 4,
        order_id: 5,
        common_name: nil, original_rank: rank
      }

      expect(subject(taxon)).to eq(expected)
    end

    it 'converts taxons that are class' do
      rank = 'class'
      remove_keys(%i[species genus family order])

      taxon = create(:ncbi_node, hierarchy_names: names, hierarchy: ids,
                                 rank: rank, cal_division_id: division.id)
      taxon = append_taxon(taxon)
      expected = {
        kingdom: 'division', phylum: 'p', class: 'c',
        kingdom_id: 100, phylum_id: 3, class_id: 4,
        common_name: nil, original_rank: rank
      }

      expect(subject(taxon)).to eq(expected)
    end

    it 'converts taxons that are phylum' do
      rank = 'phylum'
      remove_keys(%i[species genus family order class])

      taxon = create(:ncbi_node, hierarchy_names: names, hierarchy: ids,
                                 rank: rank, cal_division_id: division.id)
      taxon = append_taxon(taxon)
      expected = {
        kingdom: 'division', phylum: 'p',
        kingdom_id: 100, phylum_id: 3,
        common_name: nil, original_rank: rank
      }

      expect(subject(taxon)).to eq(expected)
    end

    it 'converts taxons that are kingdom' do
      rank = 'kingdom'
      remove_keys(%i[species genus family order class phylum])

      taxon = create(:ncbi_node, hierarchy_names: names, hierarchy: ids,
                                 rank: rank, cal_division_id: division.id)
      taxon = append_taxon(taxon)
      expected = {
        kingdom: 'division',
        kingdom_id: 100,
        common_name: nil,
        original_rank: rank
      }

      expect(subject(taxon)).to eq(expected)
    end

    it 'converts taxons for superkingdom' do
      rank = 'superkingdom'
      remove_keys(%i[species genus family order class phylum kingdom])

      taxon = create(:ncbi_node, hierarchy_names: names, hierarchy: ids,
                                 rank: rank, cal_division_id: division.id)
      taxon = append_taxon(taxon)
      expected = {
        common_name: nil,
        original_rank: rank
      }

      expect(subject(taxon)).to eq(expected)
    end

    it 'adds common name if common name exists' do
      rank = 'superkingdom'
      remove_keys(%i[species genus family order class phylum kingdom])

      taxon = create(:ncbi_node, hierarchy_names: names, hierarchy: ids,
                                 rank: rank, cal_division_id: division.id)
      taxon = append_taxon(taxon, 'cn')
      expected = {
        common_name: 'cn',
        original_rank: rank
      }
      expect(subject(taxon)).to eq(expected)
    end

    it 'converts taxons with only species' do
      rank = 'species'
      names = { species: 'sp' }
      ids = { species: 8 }

      taxon = create(:ncbi_node, hierarchy_names: names, hierarchy: ids,
                                 rank: rank, cal_division_id: division.id)
      taxon = append_taxon(taxon)
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
        species_id: 8,
        common_name: nil,
        original_rank: rank
      }

      expect(subject(taxon)).to eq(expected)
    end

    it 'converts taxons with one blank rank' do
      rank = 'species'
      remove_keys(%i[genus])

      taxon = create(:ncbi_node, hierarchy_names: names, hierarchy: ids,
                                 rank: rank, cal_division_id: division.id)
      taxon = append_taxon(taxon)
      expected = {
        kingdom: 'division', phylum: 'p', class: 'c', order: 'o',
        family: 'f', genus: 'genus for sp', species: 'sp',
        kingdom_id: 100, phylum_id: 3, class_id: 4,
        order_id: 5, family_id: 6, genus_id: 'g_8', species_id: 8,
        common_name: nil,
        original_rank: rank
      }

      expect(subject(taxon)).to eq(expected)
    end

    it 'converts taxons with back-to-back blank ranks' do
      rank = 'species'
      remove_keys(%i[genus family])

      taxon = create(:ncbi_node, hierarchy_names: names, hierarchy: ids,
                                 rank: rank, cal_division_id: division.id)
      taxon = append_taxon(taxon)
      expected = {
        kingdom: 'division', phylum: 'p', class: 'c', order: 'o',
        family: 'family for sp', genus: 'genus for sp', species: 'sp',
        kingdom_id: 100, phylum_id: 3, class_id: 4,
        order_id: 5, family_id: 'f_g_8', genus_id: 'g_8', species_id: 8,
        common_name: nil, original_rank: rank
      }

      expect(subject(taxon)).to eq(expected)
    end

    it 'converts taxons with multiple back-to-back blank rank' do
      rank = 'species'
      remove_keys(%i[genus family phylum kingdom])

      taxon = create(:ncbi_node, hierarchy_names: names, hierarchy: ids,
                                 rank: rank, cal_division_id: division.id)
      taxon = append_taxon(taxon)
      expected = {
        kingdom: 'division', phylum: 'phylum for c', class: 'c',
        order: 'o', family: 'family for sp', genus: 'genus for sp',
        species: 'sp',
        kingdom_id: 100, phylum_id: 'p_4', class_id: 4,
        order_id: 5, family_id: 'f_g_8', genus_id: 'g_8', species_id: 8,
        common_name: nil,
        original_rank: rank
      }

      expect(subject(taxon)).to eq(expected)
    end
  end
end
