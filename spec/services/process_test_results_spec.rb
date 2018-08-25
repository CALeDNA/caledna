# frozen_string_literal: true

require 'rails_helper'

describe ProcessTestResults do
  let(:dummy_class) { Class.new { extend ProcessTestResults } }

  describe '#find_taxon_from_string_phylum' do
    def subject(string)
      dummy_class.find_taxon_from_string_phylum(string)
    end

    it 'returns a hash of taxon info when all ranks are present' do
      string = 'Phylum;Class;Order;Family;Genus;Species'
      lineage = [
        [1, 'Superkingdom', 'superkingdom'],
        [2, 'Kingdom', 'kingdom'],
        [3, 'Phylum', 'phylum'],
        [4, 'Class', 'class'],
        [5, 'Order', 'order'],
        [6, 'Family', 'family'],
        [7, 'Genus', 'genus'],
        [8, 'Species', 'species']
      ]
      taxon = create(:ncbi_node, lineage: lineage, canonical_name: 'Species',
                                 rank: 'species')
      create(:ncbi_name, name: 'Species', taxon_id: taxon.id)

      expect(subject(string)[:original_taxonomy_phylum]).to eq(string)
      expect(subject(string)[:complete_taxonomy])
        .to eq("Superkingdom;Kingdom;#{string}")
      expect(subject(string)[:taxon_id]).to eq(taxon.id)
      expect(subject(string)[:rank]).to eq('species')
      expect(subject(string)[:original_hierarchy]).to include(
        superkingdom: 'Superkingdom', kingdom: 'Kingdom', class: 'Class',
        order: 'Order', family: 'Family', genus: 'Genus', species: 'Species'
      )
    end

    it 'returns a hash of taxon info when there are missing ranks' do
      string = ';Class;Order;;Genus;'
      lineage = [
        [1, 'Superkingdom', 'superkingdom'],
        [4, 'Class', 'class'],
        [5, 'Order', 'order'],
        [7, 'Genus', 'genus']
      ]
      taxon = create(:ncbi_node, lineage: lineage, canonical_name: 'Genus',
                                 rank: 'genus')
      create(:ncbi_name, name: 'Genus', taxon_id: taxon.id)

      expect(subject(string)[:original_taxonomy_phylum])
        .to eq(';Class;Order;;Genus;')
      expect(subject(string)[:complete_taxonomy])
        .to eq("Superkingdom;;#{string}")
      expect(subject(string)[:taxon_id]).to eq(taxon.id)
      expect(subject(string)[:rank]).to eq('genus')
      expect(subject(string)[:original_hierarchy]).to include(
        superkingdom: 'Superkingdom', class: 'Class',
        order: 'Order', genus: 'Genus'
      )
    end

    it 'returns a hash of taxon info when there are NA ranks' do
      string = 'NA;Class;Order;NA;Genus;'
      lineage = [
        [1, 'Superkingdom', 'superkingdom'],
        [4, 'Class', 'class'],
        [5, 'Order', 'order'],
        [7, 'Genus', 'genus']
      ]
      taxon = create(:ncbi_node, lineage: lineage, canonical_name: 'Genus',
                                 rank: 'genus')
      create(:ncbi_name, name: 'Genus', taxon_id: taxon.id)

      expect(subject(string)[:original_taxonomy_phylum])
        .to eq('NA;Class;Order;NA;Genus;')
      expect(subject(string)[:complete_taxonomy])
        .to eq("Superkingdom;;#{string}")
      expect(subject(string)[:taxon_id]).to eq(taxon.id)
      expect(subject(string)[:rank]).to eq('genus')
      expect(subject(string)[:original_hierarchy]).to include(
        superkingdom: 'Superkingdom', class: 'Class',
        order: 'Order', genus: 'Genus'
      )
    end
  end

  describe '#get_taxon_rank_phylum' do
    def subject(string)
      dummy_class.get_taxon_rank_phylum(string)
    end

    it 'returns species if it exists' do
      string = 'Phylum;Class;Order;Family;Genus;Species'
      expect(subject(string)).to eq('species')
    end

    it 'returns species if only species exists' do
      string = ';;;;;Species'
      expect(subject(string)).to eq('species')
    end

    it 'returns genus if it exists' do
      string = 'Phylum;Class;Order;Family;Genus;'
      expect(subject(string)).to eq('genus')
    end

    it 'returns family if it exists' do
      string = 'Phylum;Class;Order;Family;;'
      expect(subject(string)).to eq('family')
    end

    it 'returns order if it exists' do
      string = 'Phylum;Class;Order;;;'
      expect(subject(string)).to eq('order')
    end

    it 'returns class if it exists' do
      string = 'Phylum;Class;;;;'
      expect(subject(string)).to eq('class')
    end

    it 'returns phylum if it exists' do
      string = 'Phylum;;;;;'
      expect(subject(string)).to eq('phylum')
    end

    it 'ignores "NA"' do
      string = 'Phylum;Class;Order;Family;NA;NA'
      expect(subject(string)).to eq('family')
    end

    it 'retuns "unknown" when entire string is "NA"' do
      string = 'NA'
      expect(subject(string)).to eq('unknown')
    end

    it 'retuns "unknown" when entire string is ";;;;;"' do
      string = ';;;;;'
      expect(subject(string)).to eq('unknown')
    end
  end

  describe '#get_hierarchy_phylum' do
    def subject(string, rank)
      dummy_class.get_hierarchy_phylum(string, rank)
    end

    it 'returns taxon data when taxon has long lineage' do
      lineage = [
        [131_567, 'cellular organisms', 'no rank'],
        [2_759, 'Eukaryota', 'superkingdom'],
        [33_154, 'Opisthokonta', 'no rank'],
        [33_208, 'Metazoa', 'kingdom'],
        [6_072, 'Eumetazoa', 'no rank'],
        [33_213, 'Bilateria', 'no rank'],
        [33_317, 'Protostomia', 'no rank'],
        [1_206_794, 'Ecdysozoa', 'no rank'],
        [88_770, 'Panarthropoda', 'no rank'],
        [6_656, 'Arthropoda', 'phylum'],
        [6_843, 'Chelicerata', 'subphylum'],
        [6_854, 'Arachnida', 'class'],
        [6_933, 'Acari', 'subclass'],
        [6_946, 'Acariformes', 'superorder'],
        [83_136, 'Trombidiformes', 'order'],
        [6_947, 'Prostigmata', 'suborder'],
        [83_138, 'Anystina', 'infraorder'],
        [83_141, 'Parasitengona', 'no rank'],
        [92_068, 'Hydracarina', 'no rank'],
        [257_018, 'Lebertioidea', 'superfamily'],
        [1_046_929, 'Teutoniidae', 'family'],
        [1_046_930, 'Teutonia', 'genus']
      ]
      taxon = create(:ncbi_node, lineage: lineage, canonical_name: 'Teutonia',
                                 rank: 'genus')
      create(:ncbi_name, name: 'Teutonia', taxon_id: taxon.id)

      string = 'Arthropoda;Arachnida;Trombidiformes;Teutoniidae;Teutonia;'
      rank = 'genus'

      expect(subject(string, rank)).to eq(
        superkingdom: 'Eukaryota', kingdom: 'Metazoa', phylum: 'Arthropoda',
        class: 'Arachnida',
        order: 'Trombidiformes', family: 'Teutoniidae', genus: 'Teutonia'
      )
    end

    it 'returns a hash of taxonomy names' do
      taxon = create(
        :ncbi_node,
        canonical_name: 'Species',
        rank: 'species',
        lineage: [
          [1, 'Superkingdom', 'superkingdom'],
          [2, 'Kingdom', 'kingdom'],
          [3, 'Phylum', 'phylum'],
          [4, 'Class', 'class'],
          [5, 'Order', 'order'],
          [6, 'Family', 'family'],
          [7, 'Genus', 'genus'],
          [8, 'Species', 'species']
        ]
      )
      create(:ncbi_name, name: 'Species', taxon_id: taxon.id)

      string = 'Phylum;Class;Order;Family;Genus;Species'
      rank = 'species'
      expected = {
        superkingdom: 'Superkingdom',
        kingdom: 'Kingdom',
        phylum: 'Phylum',
        class: 'Class',
        order: 'Order',
        family: 'Family',
        genus: 'Genus',
        species: 'Species'
      }

      expect(subject(string, rank)).to eq(expected)
    end

    it 'returns hash that does not contain missing taxa' do
      taxon = create(
        :ncbi_node,
        canonical_name: 'Genus',
        rank: 'genus',
        lineage: [
          [1, 'Superkingdom', 'superkingdom'],
          [2, 'Kingdom', 'kingdom'],
          [3, 'Phylum', 'phylum'],
          [4, 'Class', 'class'],
          [6, 'Family', 'family'],
          [7, 'Genus', 'genus']
        ]
      )
      create(:ncbi_name, name: 'Genus', taxon_id: taxon.id)

      string = 'Phylum;Class;;Family;Genus;'
      rank = 'genus'
      expected = {
        superkingdom: 'Superkingdom',
        kingdom: 'Kingdom',
        phylum: 'Phylum',
        class: 'Class',
        family: 'Family',
        genus: 'Genus'
      }

      expect(subject(string, rank)).to eq(expected)
    end

    it 'returns hash that does not contain "NA" taxa' do
      taxon = create(
        :ncbi_node,
        canonical_name: 'Genus',
        rank: 'genus',
        lineage: [
          [1, 'Superkingdom', 'superkingdom'],
          [2, 'Kingdom', 'kingdom'],
          [3, 'Phylum', 'phylum'],
          [4, 'Class', 'class'],
          [6, 'Family', 'family'],
          [7, 'Genus', 'genus']
        ]
      )
      create(:ncbi_name, name: 'Genus', taxon_id: taxon.id)

      string = 'Phylum;Class;NA;Family;Genus;NA'
      rank = 'genus'
      expected = {
        superkingdom: 'Superkingdom',
        kingdom: 'Kingdom',
        phylum: 'Phylum',
        class: 'Class',
        family: 'Family',
        genus: 'Genus'
      }

      expect(subject(string, rank)).to eq(expected)
    end

    it 'retuns empty hash when entire string is "NA"' do
      string = 'NA'
      rank = nil
      expect(subject(string, rank)).to eq({})
    end

    it 'retuns empty hash when entire string is ";;;;;"' do
      string = ';;;;;'
      rank = nil
      expect(subject(string, rank)).to eq({})
    end
  end

  describe '#find_taxon_from_string_superkingdom' do
    def subject(string)
      dummy_class.find_taxon_from_string_superkingdom(string)
    end

    it 'returns a hash of taxon info when all ranks are present' do
      string = 'Superkingdom;Phylum;Class;Order;Family;Genus;Species'
      lineage = [
        [1, 'Superkingdom', 'superkingdom'],
        [2, 'Kingdom', 'kingdom'],
        [3, 'Phylum', 'phylum'],
        [4, 'Class', 'class'],
        [5, 'Order', 'order'],
        [6, 'Family', 'family'],
        [7, 'Genus', 'genus'],
        [8, 'Species', 'species']
      ]
      taxon = create(:ncbi_node, lineage: lineage, canonical_name: 'Species',
                                 rank: 'species')
      create(:ncbi_name, name: 'Species', taxon_id: taxon.id)

      expect(subject(string)[:original_taxonomy_superkingdom]).to eq(string)
      expect(subject(string)[:original_taxonomy_phylum])
        .to eq('Phylum;Class;Order;Family;Genus;Species')
      expect(subject(string)[:complete_taxonomy]).to eq(string)
      expect(subject(string)[:taxon_id]).to eq(taxon.id)
      expect(subject(string)[:rank]).to eq('species')
      expect(subject(string)[:original_hierarchy]).to include(
        superkingdom: 'Superkingdom', kingdom: 'Kingdom', class: 'Class',
        order: 'Order', family: 'Family', genus: 'Genus', species: 'Species'
      )
    end

    it 'returns a hash of taxon info when there are missing ranks' do
      string = 'Superkingdom;;Class;Order;;Genus;'
      lineage = [
        [1, 'Superkingdom', 'superkingdom'],
        [4, 'Class', 'class'],
        [5, 'Order', 'order'],
        [7, 'Genus', 'genus']
      ]
      taxon = create(:ncbi_node, lineage: lineage, canonical_name: 'Genus',
                                 rank: 'genus')
      create(:ncbi_name, name: 'Genus', taxon_id: taxon.id)

      expect(subject(string)[:original_taxonomy_superkingdom]).to eq(string)
      expect(subject(string)[:original_taxonomy_phylum])
        .to eq(';Class;Order;;Genus;')
      expect(subject(string)[:complete_taxonomy]).to eq(string)
      expect(subject(string)[:taxon_id]).to eq(taxon.id)
      expect(subject(string)[:rank]).to eq('genus')
      expect(subject(string)[:original_hierarchy]).to include(
        superkingdom: 'Superkingdom', class: 'Class',
        order: 'Order', genus: 'Genus'
      )
    end

    it 'returns a hash of taxon info when there are NA ranks' do
      string = 'Superkingdom;NA;Class;Order;NA;Genus;'
      lineage = [
        [1, 'Superkingdom', 'superkingdom'],
        [4, 'Class', 'class'],
        [5, 'Order', 'order'],
        [7, 'Genus', 'genus']
      ]
      taxon = create(:ncbi_node, lineage: lineage, canonical_name: 'Genus',
                                 rank: 'genus')
      create(:ncbi_name, name: 'Genus', taxon_id: taxon.id)

      expect(subject(string)[:original_taxonomy_superkingdom]).to eq(string)
      expect(subject(string)[:original_taxonomy_phylum])
        .to eq('NA;Class;Order;NA;Genus;')
      expect(subject(string)[:complete_taxonomy]).to eq(string)
      expect(subject(string)[:taxon_id]).to eq(taxon.id)
      expect(subject(string)[:rank]).to eq('genus')
      expect(subject(string)[:original_hierarchy]).to include(
        superkingdom: 'Superkingdom', class: 'Class',
        order: 'Order', genus: 'Genus'
      )
    end
  end

  describe '#get_taxon_rank_superkingdom' do
    def subject(string)
      dummy_class.get_taxon_rank_superkingdom(string)
    end

    it 'returns species if it exists' do
      string = 'Superkingdom;Phylum;Class;Order;Family;Genus;Species'
      expect(subject(string)).to eq('species')
    end

    it 'returns species if only species exists' do
      string = ';;;;;;Species'
      expect(subject(string)).to eq('species')
    end

    it 'returns genus if it exists' do
      string = 'Superkingdom;Phylum;Class;Order;Family;Genus;'
      expect(subject(string)).to eq('genus')
    end

    it 'returns family if it exists' do
      string = 'Superkingdom;Phylum;Class;Order;Family;;'
      expect(subject(string)).to eq('family')
    end

    it 'returns order if it exists' do
      string = 'Superkingdom;Phylum;Class;Order;;;'
      expect(subject(string)).to eq('order')
    end

    it 'returns class if it exists' do
      string = 'Superkingdom;Phylum;Class;;;;'
      expect(subject(string)).to eq('class')
    end

    it 'returns phylum if it exists' do
      string = 'Superkingdom;Phylum;;;;;'
      expect(subject(string)).to eq('phylum')
    end

    it 'returns superkingdom if it exists' do
      string = 'Superkingdom;;;;;;'
      expect(subject(string)).to eq('superkingdom')
    end

    it 'ignores "NA"' do
      string = 'Superkingdom;Phylum;Class;Order;Family;NA;NA'
      expect(subject(string)).to eq('family')
    end

    it 'retuns "unknown" when entire string is "NA"' do
      string = 'NA'
      expect(subject(string)).to eq('unknown')
    end

    it 'retuns "unknown" when entire string is ";;;;;;"' do
      string = ';;;;;;'
      expect(subject(string)).to eq('unknown')
    end
  end

  describe '#get_hierarchy_superkingdom' do
    def subject(string, rank)
      dummy_class.get_hierarchy_superkingdom(string, rank)
    end

    it 'returns taxon data when taxon has long lineage' do
      lineage = [
        [131_567, 'cellular organisms', 'no rank'],
        [2_759, 'Eukaryota', 'superkingdom'],
        [33_154, 'Opisthokonta', 'no rank'],
        [33_208, 'Metazoa', 'kingdom'],
        [6_072, 'Eumetazoa', 'no rank'],
        [33_213, 'Bilateria', 'no rank'],
        [33_317, 'Protostomia', 'no rank'],
        [1_206_794, 'Ecdysozoa', 'no rank'],
        [88_770, 'Panarthropoda', 'no rank'],
        [6_656, 'Arthropoda', 'phylum'],
        [6_843, 'Chelicerata', 'subphylum'],
        [6_854, 'Arachnida', 'class'],
        [6_933, 'Acari', 'subclass'],
        [6_946, 'Acariformes', 'superorder'],
        [83_136, 'Trombidiformes', 'order'],
        [6_947, 'Prostigmata', 'suborder'],
        [83_138, 'Anystina', 'infraorder'],
        [83_141, 'Parasitengona', 'no rank'],
        [92_068, 'Hydracarina', 'no rank'],
        [257_018, 'Lebertioidea', 'superfamily'],
        [1_046_929, 'Teutoniidae', 'family'],
        [1_046_930, 'Teutonia', 'genus']
      ]
      taxon = create(:ncbi_node, lineage: lineage, canonical_name: 'Teutonia',
                                 rank: 'genus')
      create(:ncbi_name, name: 'Teutonia', taxon_id: taxon.id)

      string =
        'Eukaryota;Arthropoda;Arachnida;Trombidiformes;Teutoniidae;Teutonia;'
      rank = 'genus'

      expect(subject(string, rank)).to eq(
        superkingdom: 'Eukaryota', kingdom: 'Metazoa', phylum: 'Arthropoda',
        class: 'Arachnida',
        order: 'Trombidiformes', family: 'Teutoniidae', genus: 'Teutonia'
      )
    end

    it 'returns a hash of taxonomy names' do
      taxon = create(
        :ncbi_node,
        canonical_name: 'Species',
        rank: 'species',
        lineage: [
          [1, 'Superkingdom', 'superkingdom'],
          [2, 'Kingdom', 'kingdom'],
          [3, 'Phylum', 'phylum'],
          [4, 'Class', 'class'],
          [5, 'Order', 'order'],
          [6, 'Family', 'family'],
          [7, 'Genus', 'genus'],
          [8, 'Species', 'species']
        ]
      )
      create(:ncbi_name, name: 'Species', taxon_id: taxon.id)

      string = 'Superkingdom;Phylum;Class;Order;Family;Genus;Species'
      rank = 'species'
      expected = {
        superkingdom: 'Superkingdom',
        kingdom: 'Kingdom',
        phylum: 'Phylum',
        class: 'Class',
        order: 'Order',
        family: 'Family',
        genus: 'Genus',
        species: 'Species'
      }

      expect(subject(string, rank)).to eq(expected)
    end

    it 'returns hash that does not contain missing taxa' do
      taxon = create(
        :ncbi_node,
        canonical_name: 'Genus',
        rank: 'genus',
        lineage: [
          [1, 'Superkingdom', 'superkingdom'],
          [2, 'Kingdom', 'kingdom'],
          [3, 'Phylum', 'phylum'],
          [4, 'Class', 'class'],
          [6, 'Family', 'family'],
          [7, 'Genus', 'genus']
        ]
      )
      create(:ncbi_name, name: 'Genus', taxon_id: taxon.id)

      string = 'Superkingdom;Phylum;Class;;Family;Genus;'
      rank = 'genus'
      expected = {
        superkingdom: 'Superkingdom',
        kingdom: 'Kingdom',
        phylum: 'Phylum',
        class: 'Class',
        family: 'Family',
        genus: 'Genus'
      }

      expect(subject(string, rank)).to eq(expected)
    end

    it 'returns hash that does not contain "NA" taxa' do
      taxon = create(
        :ncbi_node,
        canonical_name: 'Genus',
        rank: 'genus',
        lineage: [
          [1, 'Superkingdom', 'superkingdom'],
          [2, 'Kingdom', 'kingdom'],
          [3, 'Phylum', 'phylum'],
          [4, 'Class', 'class'],
          [6, 'Family', 'family'],
          [7, 'Genus', 'genus']
        ]
      )
      create(:ncbi_name, name: 'Genus', taxon_id: taxon.id)

      string = 'Superkingdom;Phylum;Class;NA;Family;Genus;NA'
      rank = 'genus'
      expected = {
        superkingdom: 'Superkingdom',
        kingdom: 'Kingdom',
        phylum: 'Phylum',
        class: 'Class',
        family: 'Family',
        genus: 'Genus'
      }

      expect(subject(string, rank)).to eq(expected)
    end

    it 'retuns empty hash when entire string is "NA"' do
      string = 'NA'
      rank = nil
      expect(subject(string, rank)).to eq({})
    end

    it 'retuns empty hash when entire string is ";;;;;;"' do
      string = ';;;;;;'
      rank = nil
      expect(subject(string, rank)).to eq({})
    end
  end

  describe '#find_exact_taxon' do
    def subject(hierarchy, rank)
      dummy_class.find_exact_taxon(hierarchy, rank)
    end

    def hierarchy
      {
        superkingdom: 'Superkingdom', kingdom: 'Kingdom',
        phylum: 'Phylum', class: 'Class',  order: 'Order', family: 'Family',
        genus: 'Genus', species: 'Species'
      }
    end

    context 'when taxons have different lineages but same hierarchy' do
      # rubocop:disable Metrics/MethodLength
      def create_taxons(rank, name)
        lineage1 = [
          [1, 'Superkingdom', 'superkingdom'],
          [4, 'node1', 'no rank'],
          [3, name, rank]
        ]
        lineage2 = [
          [1, 'Superkingdom', 'superkingdom'],
          [3, name, rank]
        ]

        taxon1 = create(:ncbi_node, rank: rank, lineage: lineage1,
                                    canonical_name: name)
        create(:ncbi_name, taxon_id: taxon1.id, name: name)
        taxon2 = create(:ncbi_node, rank: rank, lineage: lineage2,
                                    canonical_name: name)
        create(:ncbi_name, taxon_id: taxon2.id, name: name)

        [taxon1, taxon2]
      end
      # rubocop:enable Metrics/MethodLength

      it 'returns nil for phylums' do
        name = 'Phylum'
        rank = 'phylum'
        hierarchy = {
          superkingdom: 'Superkingdom', kingdom: nil,
          phylum: name, class: nil, order: nil, family: nil,
          genus: nil, species: nil
        }

        create_taxons(rank, name)

        expect(subject(hierarchy, rank)).to eq(nil)
      end

      it 'returns nil for classes' do
        name = 'Class'
        rank = 'class'
        hierarchy = {
          superkingdom: 'Superkingdom', kingdom: nil,
          phylum: nil, class: name, order: nil, family: nil,
          genus: nil, species: nil
        }

        create_taxons(rank, name)

        expect(subject(hierarchy, rank)).to eq(nil)
      end

      it 'returns nil for orders' do
        name = 'Order'
        rank = 'order'
        hierarchy = {
          superkingdom: 'Superkingdom', kingdom: nil,
          phylum: nil, class: nil, order: name, family: nil,
          genus: nil, species: nil
        }

        create_taxons(rank, name)

        expect(subject(hierarchy, rank)).to eq(nil)
      end

      it 'returns nil for families' do
        name = 'Family'
        rank = 'family'
        hierarchy = {
          superkingdom: 'Superkingdom', kingdom: nil,
          phylum: nil, class: nil, order: nil, family: name,
          genus: nil, species: nil
        }

        create_taxons(rank, name)

        expect(subject(hierarchy, rank)).to eq(nil)
      end

      it 'returns nil for genus' do
        name = 'Genus'
        rank = 'genus'
        hierarchy = {
          superkingdom: 'Superkingdom', kingdom: nil,
          phylum: nil, class: nil, order: nil, family: nil,
          genus: name, species: nil
        }

        create_taxons(rank, name)

        expect(subject(hierarchy, rank)).to eq(nil)
      end

      it 'returns nil for species' do
        name = 'Species'
        rank = 'species'
        hierarchy = {
          superkingdom: 'Superkingdom', kingdom: nil,
          phylum: nil, class: nil, order: nil, family: nil,
          genus: nil, species: name
        }

        create_taxons(rank, name)

        expect(subject(hierarchy, rank)).to eq(nil)
      end
    end

    context 'when taxon name has quotes' do
      it 'returns matching NcbiNode' do
        hierarchy = {
          superkingdom: 'Superkingdom', kingdom: nil,
          phylum: "'Phylum'", class: nil, order: nil, family: nil,
          genus: nil, species: nil
        }
        rank = 'phylum'
        taxon = create(:ncbi_node, rank: 'phylum', canonical_name: "'Phylum'")
        create(:ncbi_name, taxon_id: taxon.id, name: "'Phylum'")

        expect(subject(hierarchy, rank)).to eq(taxon)
      end
    end

    context 'when rank has unique taxon names' do
      def create_taxons(canonical_name, rank)
        t = create(:ncbi_node, rank: rank, canonical_name: 'random1')
        create(:ncbi_name, name: 'random1', taxon_id: t.id)

        taxon = create(:ncbi_node, rank: rank, canonical_name: canonical_name)
        create(:ncbi_name, name: canonical_name, taxon_id: taxon.id)

        t = create(:ncbi_node, rank: rank, canonical_name: 'random2')
        create(:ncbi_name, name: 'random2', taxon_id: t.id)

        taxon
      end

      it 'returns matching NcbiNode when rank is phylum' do
        hierarchy = {
          superkingdom: 'Superkingdom', kingdom: nil,
          phylum: 'Phylum', class: nil, order: nil, family: nil,
          genus: nil, species: nil
        }
        rank = 'phylum'
        taxon = create_taxons('Phylum', rank)

        expect(subject(hierarchy, rank)).to eq(taxon)
      end

      it 'returns matching NcbiNode when rank is class' do
        hierarchy = {
          superkingdom: 'Superkingdom', kingdom: nil,
          phylum: nil, class: 'Class',  order: nil, family: nil,
          genus: nil, species: nil
        }
        rank = 'class'
        taxon = create_taxons('Class', rank)

        expect(subject(hierarchy, rank)).to eq(taxon)
      end

      it 'returns matching NcbiNode when rank is order' do
        hierarchy = {
          superkingdom: 'Superkingdom', kingdom: nil,
          phylum: nil, class: nil, order: 'Order', family: nil,
          genus: nil, species: nil
        }
        rank = 'order'
        taxon = create_taxons('Order', rank)

        expect(subject(hierarchy, rank)).to eq(taxon)
      end

      it 'returns matching NcbiNode when rank is species' do
        hierarchy = {
          superkingdom: 'Superkingdom', kingdom: nil,
          phylum: nil, class: nil, order: nil, family: nil,
          genus: nil, species: 'Species'
        }
        rank = 'species'
        taxon = create_taxons('Species', rank)

        expect(subject(hierarchy, rank)).to eq(taxon)
      end
    end

    context 'when rank is family' do
      def create_taxon(rank, lineage)
        taxon = create(:ncbi_node, rank: rank, canonical_name: 'Family',
                                   lineage: lineage)
        create(:ncbi_name, name: 'Family', taxon_id: taxon.id)
        taxon
      end

      it 'returns matching NcbiNode when phylum exists' do
        hierarchy = {
          superkingdom: nil, kingdom: nil,
          phylum: 'Phylum', class: nil, order: nil, family: 'Family',
          genus: nil, species: nil
        }
        rank = 'family'

        family_lineage = [6, 'Family', 'family']
        create_taxon(rank, [[3, 'bad', 'phylum'], family_lineage])
        taxon = create_taxon(rank, [[3, 'Phylum', 'phylum'], family_lineage])
        create_taxon(rank, [family_lineage])

        expect(subject(hierarchy, rank)).to eq(taxon)
      end

      it 'returns matching NcbiNode when phylum does not exist' do
        hierarchy = {
          superkingdom: nil, kingdom: nil,
          phylum: nil, class: nil, order: nil, family: 'Family',
          genus: nil, species: nil
        }
        rank = 'family'

        family_lineage = [6, 'Family', 'family']
        create_taxon(rank, [[1, 'bad', 'phylum'], family_lineage])
        create_taxon(rank, [[2, 'Phylum', 'phylum'], family_lineage])
        taxon = create_taxon(rank, [family_lineage])

        expect(subject(hierarchy, rank)).to eq(taxon)
      end
    end

    context 'when rank is genus' do
      def create_taxon(rank, lineage)
        taxon = create(:ncbi_node, rank: rank, canonical_name: 'Genus',
                                   lineage: lineage)
        create(:ncbi_name, name: 'Genus', taxon_id: taxon.id)
        taxon
      end

      it 'returns matching NcbiNode when all main ranks are present' do
        hierarchy = {
          superkingdom: 'Superkingdom', kingdom: 'Kingdom',
          phylum: 'Phylum', class: 'Class',  order: 'Order', family: 'Family',
          genus: 'Genus', species: nil
        }
        rank = 'genus'

        lineage = [
          [1, 'Superkingdom', 'superkingdom'],
          [2, 'Kingdom', 'kingdom'],
          [3, 'Phylum', 'phylum'],
          [4, 'Class', 'class'],
          [5, 'random', 'order'],
          [6, 'Family', 'family'],
          [7, 'Genus', 'genus']
        ]
        create_taxon(rank, lineage)
        lineage = [
          [1, 'Superkingdom', 'superkingdom'],
          [2, 'Kingdom', 'kingdom'],
          [3, 'Phylum', 'phylum'],
          [4, 'Class', 'class'],
          [5, 'Order', 'order'],
          [6, 'Family', 'family'],
          [7, 'Genus', 'genus']
        ]
        taxon = create_taxon(rank, lineage)
        create_taxon(rank, [])

        expect(subject(hierarchy, rank)).to eq(taxon)
      end

      it 'returns matching NcbiNode when kingdom is missing' do
        hierarchy = {
          superkingdom: nil, kingdom: nil,
          phylum: 'Phylum', class: 'Class', order: 'Order', family: 'Family',
          genus: 'Genus', species: nil
        }
        rank = 'genus'

        lineage = [
          [3, 'Phylum', 'phylum'],
          [4, 'Class', 'class'],
          [5, 'random', 'order'],
          [6, 'Family', 'family'],
          [7, 'Genus', 'genus']
        ]
        create_taxon(rank, lineage)
        lineage = [
          [3, 'Phylum', 'phylum'],
          [4, 'Class', 'class'],
          [5, 'Order', 'order'],
          [6, 'Family', 'family'],
          [7, 'Genus', 'genus']
        ]
        taxon = create_taxon(rank, lineage)
        create_taxon(rank, [])

        expect(subject(hierarchy, rank)).to eq(taxon)
      end

      it 'returns matching NcbiNode when phylum is missing' do
        hierarchy = {
          superkingdom: 'Superkingdom', kingdom: 'Kingdom',
          phylum: nil, class: 'Class',  order: 'Order', family: 'Family',
          genus: 'Genus', species: nil
        }
        rank = 'genus'

        lineage = [
          [1, 'Superkingdom', 'superkingdom'],
          [2, 'Kingdom', 'kingdom'],
          [4, 'Class', 'class'],
          [5, 'random', 'order'],
          [6, 'Family', 'family'],
          [7, 'Genus', 'genus']
        ]
        create_taxon(rank, lineage)
        lineage = [
          [1, 'Superkingdom', 'superkingdom'],
          [2, 'Kingdom', 'kingdom'],
          [4, 'Class', 'class'],
          [5, 'Order', 'order'],
          [6, 'Family', 'family'],
          [7, 'Genus', 'genus']
        ]
        taxon = create_taxon(rank, lineage)
        create_taxon(rank, [])

        expect(subject(hierarchy, rank)).to eq(taxon)
      end

      it 'returns matching NcbiNode when class is missing' do
        hierarchy = {
          superkingdom: 'Superkingdom', kingdom: 'Kingdom',
          phylum: 'Phylum', class: nil, order: 'Order', family: 'Family',
          genus: 'Genus', species: nil
        }
        rank = 'genus'

        lineage = [
          [1, 'Superkingdom', 'superkingdom'],
          [2, 'Kingdom', 'kingdom'],
          [3, 'Phylum', 'phylum'],
          [5, 'random', 'order'],
          [6, 'Family', 'family'],
          [7, 'Genus', 'genus']
        ]
        create_taxon(rank, lineage)
        lineage = [
          [1, 'Superkingdom', 'superkingdom'],
          [2, 'Kingdom', 'kingdom'],
          [3, 'Phylum', 'phylum'],
          [5, 'Order', 'order'],
          [6, 'Family', 'family'],
          [7, 'Genus', 'genus']
        ]
        taxon = create_taxon(rank, lineage)
        create_taxon(rank, [])

        expect(subject(hierarchy, rank)).to eq(taxon)
      end

      it 'returns matching NcbiNode when order is missing' do
        hierarchy = {
          superkingdom: 'Superkingdom', kingdom: 'Kingdom',
          phylum: 'Phylum', class: 'Class',  order: nil, family: 'Family',
          genus: 'Genus', species: nil
        }
        rank = 'genus'

        lineage = [
          [1, 'Superkingdom', 'superkingdom'],
          [2, 'Kingdom', 'kingdom'],
          [3, 'Phylum', 'phylum'],
          [4, 'Class', 'class'],
          [6, 'random', 'family'],
          [7, 'Genus', 'genus']
        ]
        create_taxon(rank, lineage)
        lineage = [
          [1, 'Superkingdom', 'superkingdom'],
          [2, 'Kingdom', 'kingdom'],
          [3, 'Phylum', 'phylum'],
          [4, 'Class', 'class'],
          [6, 'Family', 'family'],
          [7, 'Genus', 'genus']
        ]
        taxon = create_taxon(rank, lineage)
        create_taxon(rank, [])

        expect(subject(hierarchy, rank)).to eq(taxon)
      end

      it 'returns matching NcbiNode when family is missing' do
        hierarchy = {
          superkingdom: 'Superkingdom', kingdom: 'Kingdom',
          phylum: 'Phylum', class: 'Class',  order: 'Order', family: nil,
          genus: 'Genus', species: nil
        }
        rank = 'genus'

        lineage = [
          [1, 'Superkingdom', 'superkingdom'],
          [2, 'Kingdom', 'kingdom'],
          [3, 'Phylum', 'phylum'],
          [4, 'Class', 'class'],
          [5, 'random', 'order'],
          [7, 'Genus', 'genus']
        ]
        create_taxon(rank, lineage)
        lineage = [
          [1, 'Superkingdom', 'superkingdom'],
          [2, 'Kingdom', 'kingdom'],
          [3, 'Phylum', 'phylum'],
          [4, 'Class', 'class'],
          [5, 'Order', 'order'],
          [7, 'Genus', 'genus']
        ]
        taxon = create_taxon(rank, lineage)
        create_taxon(rank, [])

        expect(subject(hierarchy, rank)).to eq(taxon)
      end
    end
  end

  describe '#get_complete_taxon_string' do
    def subject(string)
      dummy_class.get_complete_taxon_string(string)
    end

    it 'adds kingdoms to taxomony string if matching NcbiNode has kingdoms' do
      lineage = [
        [1, 'Superkingdom', 'superkingdom'],
        [2, 'Kingdom', 'kingdom'],
        [3, 'Phylum', 'phylum'],
        [5, 'Order', 'order']
      ]
      taxon = create(:ncbi_node, rank: 'order', canonical_name: 'Order',
                                 lineage: lineage)
      create(:ncbi_name, name: 'Order', taxon_id: taxon.id)

      string = 'Phylum;;Order;;;'
      expected = 'Superkingdom;Kingdom;Phylum;;Order;;;'

      expect(subject(string)).to eq(expected)
    end

    it 'adds kingdom to taxomony string if matching NcbiNode has kingdom' do
      lineage = [
        [2, 'Kingdom', 'kingdom'],
        [4, 'Class', 'class']
      ]
      taxon = create(:ncbi_node, rank: 'class', canonical_name: 'Class',
                                 lineage: lineage)
      create(:ncbi_name, name: 'Class', taxon_id: taxon.id)
      string = ';Class;;;;'
      expected = ';Kingdom;;Class;;;;'

      expect(subject(string)).to eq(expected)
    end

    it 'adds superkingdom to string if matching NcbiNode has superkingdom' do
      lineage = [
        [1, 'Superkingdom', 'superkingdom'],
        [4, 'Class', 'class']
      ]
      taxon = create(:ncbi_node, rank: 'class', canonical_name: 'Class',
                                 lineage: lineage)
      create(:ncbi_name, name: 'Class', taxon_id: taxon.id)
      string = ';Class;;;;'
      expected = 'Superkingdom;;;Class;;;;'

      expect(subject(string)).to eq(expected)
    end

    it 'adds ";;" to string if matching NcbiNode does not have "kingdoms"' do
      lineage = [
        [3, 'Phylum', 'phylum'],
        [4, 'Class', 'class']
      ]
      taxon = create(:ncbi_node, rank: 'class', canonical_name: 'Class',
                                 lineage: lineage)
      create(:ncbi_name, name: 'Class', taxon_id: taxon.id)
      string = 'Phylum;Class;;;;'
      expected = ';;Phylum;Class;;;;'

      expect(subject(string)).to eq(expected)
    end
  end

  describe '#find_sample_from_barcode' do
    let(:barcode) { 'K0001-LA-S1' }
    let(:project) { create(:field_data_project, name: 'unknown') }
    let(:status) { :processing_sample }

    def subject
      dummy_class.find_sample_from_barcode(barcode, status)
    end

    context 'there are no samples for a given bar code' do
      it 'creates a new sample' do
        stub_const('FieldDataProject::DEFAULT_PROJECT', project)

        expect { subject }.to change { Sample.count }.by(1)
      end

      it 'returns the created sample' do
        stub_const('FieldDataProject::DEFAULT_PROJECT', project)
        result = subject

        expect(result.barcode).to eq(barcode)
        expect(result.field_data_project).to eq(project)
        expect(result.missing_coordinates).to eq(true)
        expect(result.status).to eq(status)
      end
    end

    context 'there is one valid sample for a given barcode' do
      it 'returns the matching sample' do
        sample = create(:sample, status_cd: :approved, barcode: barcode)
        result = subject

        expect(result).to eq(sample)
      end

      it 'updates status' do
        create(:sample, status_cd: :approved, barcode: barcode)
        result = subject

        expect(result.status).to eq(status)
      end
    end

    context 'there is one valid and one invalid sample for a given barcode' do
      it 'returns the matching  valid sample' do
        sample = create(:sample, status_cd: :approved, barcode: barcode)
        create(:sample, status_cd: :rejected, barcode: barcode)
        result = subject

        expect(result).to eq(sample)
      end

      it 'updates status' do
        create(:sample, status_cd: :approved, barcode: barcode)
        create(:sample, status_cd: :rejected, barcode: barcode)
        result = subject

        expect(result.status).to eq(status)
      end
    end

    context 'there are multiple valid samples for a given barcode' do
      it 'raises an error' do
        create(:sample, status_cd: :approved, barcode: barcode)
        create(:sample, status_cd: :results_completed, barcode: barcode)

        message = /multiple samples with barcode/
        expect { subject }.to raise_error(TaxaError, message)
      end
    end

    context 'all samples are rejected for a given barcode' do
      it 'raises an error when there is one sample' do
        create(:sample, status_cd: :rejected, barcode: barcode)

        message = /was previously rejected/
        expect { subject }.to raise_error(TaxaError, message)
      end

      it 'raises an error when there are multiple samples' do
        create(:sample, status_cd: :rejected, barcode: barcode)
        create(:sample, status_cd: :rejected, barcode: barcode)

        message = /was previously rejected/
        expect { subject }.to raise_error(TaxaError, message)
      end
    end

    context 'all samples are duplicate_barcode for a given bar code' do
      it 'raises an error when there is one sample' do
        create(:sample, status_cd: :duplicate_barcode, barcode: barcode)

        message = /was previously rejected/
        expect { subject }.to raise_error(TaxaError, message)
      end

      it 'raises an error when there are multiple samples' do
        create(:sample, status_cd: :duplicate_barcode, barcode: barcode)
        create(:sample, status_cd: :duplicate_barcode, barcode: barcode)

        message = /was previously rejected/
        expect { subject }.to raise_error(TaxaError, message)
      end
    end
  end

  describe '#get_kingdom_superkingdom' do
    def subject(taxon)
      dummy_class.get_kingdom_superkingdom(taxon)
    end

    it 'returns a hash with kingdoms' do
      lineages = [
        [1, 'Kingdom', 'kingdom'], [2, 'Superkingdom', 'superkingdom']
      ]
      taxon = create(:ncbi_node, lineage: lineages)

      expect(subject(taxon))
        .to eq(kingdom: 'Kingdom', superkingdom: 'Superkingdom')
    end

    it 'returns hash with nil kingdoms when no kingdoms lineage' do
      taxon = create(:ncbi_node, lineage: [])

      expect(subject(taxon)).to eq(kingdom: nil, superkingdom: nil)
    end
  end

  describe '#form_barcode' do
    def subject(string)
      dummy_class.form_barcode(string)
    end

    it 'returns a barcode when given a valid kit number with spaces' do
      string = 'K0001 B1'

      expect(subject(string)).to eq('K0001-LB-S1')
    end

    it 'returns a barcode when given a valid kit number w/o spaces' do
      string = 'K0001B1'

      expect(subject(string)).to eq('K0001-LB-S1')
    end

    it 'otherwise returns the original string' do
      string = 'abc'

      expect(subject(string)).to eq(string)
    end
  end

  describe '#phylum_taxonomy_string?' do
    def subject(string)
      dummy_class.phylum_taxonomy_string?(string)
    end

    it 'returns true when taxonomy string has 6 taxa' do
      string = 'phylum;class;order;family;genus;species'

      expect(subject(string)).to eq(true)
    end

    it 'returns correct results with "NA"' do
      string = 'NA;NA;order;NA;genus;species'

      expect(subject(string)).to eq(true)
    end

    it 'returns correct results with ";"' do
      string = ';;order;;genus;species'

      expect(subject(string)).to eq(true)
    end

    it 'returns false when taxonomy string has 7 taxa' do
      string = 'superkingdom;phylum;class;order;family;genus;species'

      expect(subject(string)).to eq(false)
    end

    it 'correctly analyzes phlyum string when taxa is missing' do
      string = ';class;order;family;;'

      expect(subject(string)).to eq(true)
    end

    it 'correctly analyzes superkingdom string when taxa is missing' do
      string = ';phylum;class;order;family;genus;'

      expect(subject(string)).to eq(false)
    end

    it 'correctly analyzes phlyum string when not taxa' do
      string = ';;;;;'

      expect(subject(string)).to eq(true)
    end

    it 'correctly analyzes superkingdom string when no taxa' do
      string = ';;;;;;'

      expect(subject(string)).to eq(false)
    end

    it 'correctly counts missing taxa for superkingdoms' do
      string = ';phylum;class;order;family;genus;'

      expect(subject(string)).to eq(false)
    end

    it 'it raise an error when there are invalid number of taxa' do
      string = 'random;string;will;fail'

      message = /invalid taxonomy string/
      expect { subject(string) }.to raise_error(TaxaError, message)
    end
  end

  describe '#convert_superkingdom_taxonomy_string' do
    def subject(string)
      dummy_class.convert_superkingdom_taxonomy_string(string)
    end

    it 'converts a superkingdom taxonomy string to a phlymum string' do
      phylum_string = 'phylum;class;order;family;genus;species'
      superkingdom_string = "superkingdom;#{phylum_string}"

      expect(subject(superkingdom_string)).to eq(phylum_string)
    end

    it 'returns valid string when there are ; in string' do
      phylum_string = ';class;;family;genus;species'
      superkingdom_string = "superkingdom;#{phylum_string}"

      expect(subject(superkingdom_string)).to eq(phylum_string)
    end

    it 'returns valid string when string ends in ;' do
      phylum_string = ';class;;family;genus;'
      superkingdom_string = "superkingdom;#{phylum_string}"

      expect(subject(superkingdom_string)).to eq(phylum_string)
    end

    it 'returns ";;;;;" for ";;;;;;"' do
      phylum_string = ';;;;;'
      superkingdom_string = ";#{phylum_string}"

      expect(subject(superkingdom_string)).to eq(phylum_string)
    end
  end
end
