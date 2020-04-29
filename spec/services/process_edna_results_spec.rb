# frozen_string_literal: true

require 'rails_helper'

describe ProcessEdnaResults do
  let(:dummy_class) { Class.new { extend ProcessEdnaResults } }

  describe '#convert_raw_barcode' do
    def subject(header)
      dummy_class.convert_raw_barcode(header)
    end

    context 'when v1 barcodes K0001-LA-S1' do
      it 'converts KxxxxLS' do
        headers = [
          ['k1b1', 'K0001-LB-S1'],
          ['K12B1', 'K0012-LB-S1'],
          ['k123b1', 'K0123-LB-S1'],
          ['K1234B1', 'K1234-LB-S1'],
          ['k1234b1.extra', 'K1234-LB-S1']
        ]

        headers.each do |header|
          expect(subject(header.first)).to eq(header.second)
        end
      end

      it 'converts xxxxLS' do
        headers = [
          ['1b1', 'K0001-LB-S1'],
          ['12B1', 'K0012-LB-S1'],
          ['123b1', 'K0123-LB-S1'],
          ['1234B1', 'K1234-LB-S1'],
          ['1234b1.extra', 'K1234-LB-S1']
        ]

        headers.each do |header|
          expect(subject(header.first)).to eq(header.second)
        end
      end

      it 'converts Kxxxx_L_S or Kxxxx-L-S' do
        headers = [
          ['k1_la_s1', 'K0001-LA-S1'],
          ['K12_LA_S1', 'K0012-LA-S1'],
          ['k123-la-s1', 'K0123-LA-S1'],
          ['K1234-LA-S1', 'K1234-LA-S1'],
          ['k1234_la-s1.extra', 'K1234-LA-S1']
        ]

        headers.each do |header|
          expect(subject(header.first)).to eq(header.second)
        end
      end

      # pillar point
      it 'converts PPxxxxLS' do
        headers = [
          ['pp1a1', 'K0001-LA-S1'],
          ['PP12A1', 'K0012-LA-S1'],
          ['pp123a1', 'K0123-LA-S1'],
          ['PP1234A1', 'K1234-LA-S1'],
          ['pp1234a1.extra', 'K1234-LA-S1']
        ]

        headers.each do |header|
          expect(subject(header.first)).to eq(header.second)
        end
      end
    end

    context 'when v2 barcodes K0001-A1' do
      it 'converts Kxxxx_A1 or Kxxxx-A1' do
        headers = [
          ['k1_a1', 'K0001-A1'],
          ['K12-B2', 'K0012-B2'],
          ['k123_c3', 'K0123-C3'],
          ['K1234-E4', 'K1234-E4'],
          ['k0001-g5', 'K0001-G5'],
          ['K0001_K6', 'K0001-K6'],
          ['k0001-l7', 'K0001-L7'],
          ['K0001_M8', 'K0001-M8'],
          ['k0001-t9', 'K0001-T9'],
          ['K0001_A1.extra', 'K0001-A1']
        ]

        headers.each do |header|
          expect(subject(header.first)).to eq(header.second)
        end
      end
    end

    context 'when random names' do
      it 'converts LA River water samples' do
        headers = [
          ['mwws_a1', 'MWWS-A1'],
          ['MWWS-B2', 'MWWS-B2'],
          ['mwws_m8', 'MWWS-M8'],
          ['MWWS-T9', 'MWWS-T9'],
          ['mwws_a1.extra', 'MWWS-A1'],
          ['asws-a1', 'ASWS-A1'],
          ['ASWS_B2', 'ASWS-B2'],
          ['asws-m8', 'ASWS-M8'],
          ['ASWS_T9', 'ASWS-T9'],
          ['asws-a1.extra', 'ASWS-A1']
        ]

        headers.each do |header|
          expect(subject(header.first)).to eq(header.second)
        end
      end

      it 'converts random names with underscores' do
        headers = [
          %w[Foo_1234 Foo_1234],
          ['Foo_1234.extra', 'Foo_1234']
        ]

        headers.each do |header|
          expect(subject(header.first)).to eq(header.second)
        end
      end

      it 'converts random names with dashes' do
        headers = [
          %w[Foo-1234 Foo-1234],
          ['Foo-1234.extra', 'Foo-1234']
        ]

        headers.each do |header|
          expect(subject(header.first)).to eq(header.second)
        end
      end

      it 'converts random names with spaces' do
        headers = [
          ['Foo 1234', 'Foo 1234'],
          ['Foo 1234.extra', 'Foo 1234']
        ]

        headers.each do |header|
          expect(subject(header.first)).to eq(header.second)
        end
      end

      it 'converts random names' do
        headers = [
          %w[Foo1234 Foo1234],
          ['Foo1234.extra', 'Foo1234']
        ]

        headers.each do |header|
          expect(subject(header.first)).to eq(header.second)
        end
      end
    end

    context 'when blank or neg' do
      it 'returns nil for "blank" samples' do
        headers = [
          'K0001.blank.extra', 'X16s_K0001Blank.extra', 'FooBLANK',
          'X16S_FooBlank', 'blank.Foo', 'Foo.blank'
        ]
        headers.each do |header|
          expect(subject(header)).to eq(nil)
        end
      end

      it 'returns nil for "neg" samples' do
        headers = [
          'K0001.neg.extra', 'X16s_K0001Neg.extra', 'FooNEG',
          'X16S_FooNeg', 'neg.Foo', 'Foo.neg'
        ]

        headers.each do |header|
          expect(subject(header)).to eq(nil)
        end
      end
    end
  end

  describe '#format_result_taxon_data_from_string' do
    def subject(string)
      dummy_class.format_result_taxon_data_from_string(string)
    end

    let(:taxon_id) { 100 }
    let(:ncbi_id) { 200 }
    let(:bold_id) { 300 }
    let(:ncbi_version_id) { create(:ncbi_version, id: 1).id }

    before do
      stub_const('TaxaReference::PHYLUM_SUPERKINGDOM',
                 'Phylum' => 'Superkingdom')
    end

    shared_examples 'when string matches taxon' do |options|
      let(:str) { options[:string] }
      let(:str_superkingdom) { options[:string_superkingdom] }
      let(:str_phylum) { options[:string_phylum] }
      let(:clean_str_superkingdom) { dummy_class.remove_na(str_superkingdom) }
      let(:clean_str_phylum) { dummy_class.remove_na(str_phylum) }
      let(:hier) { options[:hierarchy] }
      let(:rank) { options[:rank] }
      let(:name) { hier[rank.to_sym] }

      it 'returns a hash of taxon info' do
        create(:ncbi_node, canonical_name: name, rank: rank,
                           hierarchy_names: hier, taxon_id: taxon_id,
                           ncbi_id: ncbi_id, bold_id: bold_id,
                           ncbi_version_id: ncbi_version_id)
        results = subject(str)

        expect(results[:original_taxonomy_string]).to eq([str_superkingdom])
        expect(results[:clean_taxonomy_string]).to eq(clean_str_superkingdom)
        expect(results[:clean_taxonomy_string_phylum]).to eq(clean_str_phylum)
        expect(results[:taxon_id]).to eq(taxon_id)
        expect(results[:ncbi_id]).to eq(ncbi_id)
        expect(results[:bold_id]).to eq(bold_id)
        expect(results[:ncbi_version_id]).to eq(ncbi_version_id)
        expect(results[:taxon_rank]).to eq(rank)
        expect(results[:hierarchy]).to include(hier)
        expect(results[:canonical_name]).to eq(name)
      end
    end

    context 'when phylum string' do
      options = {
        string: 'Phylum;Class;Order;Family;Genus;Species',
        string_superkingdom:
          'Superkingdom;Phylum;Class;Order;Family;Genus;Species',
        string_phylum: 'Phylum;Class;Order;Family;Genus;Species',
        hierarchy: {
          phylum: 'Phylum', class: 'Class',
          order: 'Order', family: 'Family', genus: 'Genus', species: 'Species'
        },
        rank: 'species'
      }
      include_examples 'when string matches taxon', options

      options = {
        string: ';Class;Order;;Genus;',
        string_superkingdom: ';;Class;Order;;Genus;',
        string_phylum: ';Class;Order;;Genus;',
        hierarchy: {
          class: 'Class', order: 'Order', genus: 'Genus'
        },
        rank: 'genus'
      }
      include_examples 'when string matches taxon', options

      options = {
        string: 'NA;Class;Order;NA;Genus;Species',
        string_superkingdom: ';NA;Class;Order;NA;Genus;Species',
        string_phylum: 'NA;Class;Order;NA;Genus;Species',
        hierarchy: {
          class: 'Class', order: 'Order', genus: 'Genus', species: 'Species'
        },
        rank: 'species'
      }
      include_examples 'when string matches taxon', options

      options = {
        string: 'Phylum;;;;;',
        string_superkingdom: 'Superkingdom;Phylum;;;;;',
        string_phylum: 'Phylum;;;;;',
        hierarchy: {
          phylum: 'Phylum'
        },
        rank: 'phylum'
      }
      include_examples 'when string matches taxon', options
    end

    context 'when superkingdom string' do
      options = {
        string: 'Superkingdom;Phylum;Class;Order;Family;Genus;Species',
        string_superkingdom:
          'Superkingdom;Phylum;Class;Order;Family;Genus;Species',
        string_phylum: 'Phylum;Class;Order;Family;Genus;Species',
        hierarchy: {
          superkingdom: 'Superkingdom', phylum: 'Phylum', class: 'Class',
          order: 'Order', family: 'Family', genus: 'Genus', species: 'Species'
        },
        rank: 'species'
      }
      include_examples 'when string matches taxon', options

      options = {
        string: ';;Class;Order;;Genus;',
        string_superkingdom: ';;Class;Order;;Genus;',
        string_phylum: ';Class;Order;;Genus;',
        hierarchy: {
          class: 'Class', order: 'Order', genus: 'Genus'
        },
        rank: 'genus'
      }
      include_examples 'when string matches taxon', options

      options = {
        string: ';NA;Class;Order;NA;Genus;Species',
        string_superkingdom: ';NA;Class;Order;NA;Genus;Species',
        string_phylum: 'NA;Class;Order;NA;Genus;Species',
        hierarchy: {
          class: 'Class', order: 'Order', genus: 'Genus', species: 'Species'
        },
        rank: 'species'
      }
      include_examples 'when string matches taxon', options

      options = {
        string: 'Superkingdom;Phylum;;;;;',
        string_superkingdom: 'Superkingdom;Phylum;;;;;',
        string_phylum: 'Phylum;;;;;',
        hierarchy: {
          superkingdom: 'Superkingdom', phylum: 'Phylum'
        },
        rank: 'phylum'
      }
      include_examples 'when string matches taxon', options
    end

    it 'returns a hash of info if string is all NA or ;;' do
      results = subject(';NA;;NA;;NA;')

      expect(results[:original_taxonomy_string]).to eq([';NA;;NA;;NA;'])
      expect(results[:clean_taxonomy_string]).to eq(';;;;;;')
      expect(results[:taxon_id]).to eq(nil)
      expect(results[:ncbi_id]).to eq(nil)
      expect(results[:bold_id]).to eq(nil)
      expect(results[:ncbi_version_id]).to eq(nil)
      expect(results[:taxon_rank]).to eq('unknown')
      expect(results[:hierarchy]).to eq({})
      expect(results[:canonical_name]).to eq(';;;;;;')
    end

    it 'returns a hash of info if string is NA' do
      results = subject('NA')

      expect(results[:original_taxonomy_string]).to eq(['NA'])
      expect(results[:clean_taxonomy_string]).to eq('NA')
      expect(results[:taxon_id]).to eq(nil)
      expect(results[:ncbi_id]).to eq(nil)
      expect(results[:bold_id]).to eq(nil)
      expect(results[:ncbi_version_id]).to eq(nil)
      expect(results[:taxon_rank]).to eq('unknown')
      expect(results[:hierarchy]).to eq({})
      expect(results[:canonical_name]).to eq('NA')
    end

    it 'returns a hash with nil taxon_id if taxa not found' do
      string = 'Phylum;;;;;'
      string_amended = 'Superkingdom;Phylum;;;;;'
      hierarchy_names = {
        superkingdom: 'Superkingdom',
        kingdom: 'Kingdom',
        phylum: 'Phylum2'
      }

      create(:ncbi_node, canonical_name: 'Phylum2', rank: 'phylum',
                         hierarchy_names: hierarchy_names, taxon_id: taxon_id,
                         ncbi_id: ncbi_id, bold_id: bold_id,
                         ncbi_version_id: ncbi_version_id)
      results = subject(string)

      expect(results[:original_taxonomy_string]).to eq([string_amended])
      expect(results[:clean_taxonomy_string]).to eq(string_amended)
      expect(results[:clean_taxonomy_string_phylum]).to eq(string)
      expect(results[:taxon_id]).to eq(nil)
      expect(results[:ncbi_id]).to eq(nil)
      expect(results[:bold_id]).to eq(nil)
      expect(results[:ncbi_version_id]).to eq(nil)
      expect(results[:taxon_rank]).to eq('phylum')
      expect(results[:hierarchy]).to include(
        phylum: 'Phylum'
      )
      expect(results[:canonical_name]).to eq('Phylum')
    end

    it 'returns a hash with nil taxon_id if multiple taxa are found' do
      string = ';Class;Order;;Genus;'
      string_amended = ';;Class;Order;;Genus;'
      hierarchy_names = {
        superkingdom: 'Superkingdom',
        kingdom: 'Kingdom',
        phylum: nil,
        class: 'Class',
        order: 'Order',
        genus: 'Genus'
      }

      create(:ncbi_node, canonical_name: 'Genus', rank: 'genus',
                         hierarchy_names: hierarchy_names.merge(phylum: 'Phy1'),
                         taxon_id: 101, ncbi_id: ncbi_id, bold_id: bold_id,
                         ncbi_version_id: ncbi_version_id)
      create(:ncbi_node, canonical_name: 'Genus', rank: 'genus',
                         hierarchy_names: hierarchy_names.merge(phylum: 'Phy2'),
                         taxon_id: 102, ncbi_id: ncbi_id, bold_id: bold_id,
                         ncbi_version_id: ncbi_version_id)
      results = subject(string)

      expect(results[:original_taxonomy_string]).to eq([string_amended])
      expect(results[:clean_taxonomy_string]).to eq(string_amended)
      expect(results[:clean_taxonomy_string_phylum]).to eq(string)
      expect(results[:taxon_id]).to eq(nil)
      expect(results[:ncbi_id]).to eq(nil)
      expect(results[:bold_id]).to eq(nil)
      expect(results[:ncbi_version_id]).to eq(nil)
      expect(results[:taxon_rank]).to eq('genus')
      expect(results[:hierarchy]).to include(
        genus: 'Genus'
      )
      expect(results[:canonical_name]).to eq('Genus')
    end
  end

  describe '#invalid_taxon?' do
    def subject(string, strict: true)
      dummy_class.invalid_taxon?(string, strict: strict)
    end

    it 'returns true if string is "NA"' do
      string = 'NA'

      expect(subject(string)).to eq(true)
    end

    it 'returns true if string is all semicolons' do
      strings = [';;;;;;', ';;;;;']

      strings.each do |string|
        expect(subject(string)).to eq(true)
      end
    end

    it 'returns true if string has too many parts' do
      string = 's;p;c;o;f;g;s;x'

      expect(subject(string)).to eq(true)
    end

    it 'returns true if string has too few parts' do
      string = 'p;c;o;f;g'

      expect(subject(string)).to eq(true)
    end

    it 'returns true if empty string' do
      string = ''

      expect(subject(string)).to eq(true)
    end

    it 'returns true if string is only "NA" and semicolons' do
      strings = [';NA;;;;;', ';NA;;NA;;NA;', ';;;;;;NA', 'NA;;;;;']

      strings.each do |string|
        expect(subject(string)).to eq(true)
      end
    end

    it 'returns false otherwise' do
      strings = [
        'p;c;o;f;g;s', 'p;;;;;', ';;;;;s',
        'sk;p;c;o;f;g;s', 'sk;;;;;;', ';;;;;;s', 'sk;NA;;NA;;NA;'
      ]

      strings.each do |string|
        expect(subject(string)).to eq(false)
      end
    end

    context 'when strict is false' do
      it 'returns true if string is only "NA" and semicolons' do
        strings = [';NA;;;;;', ';NA;;NA;;NA;', ';;;;;;NA', 'NA;;;;;']

        strings.each do |string|
          expect(subject(string, strict: false)).to eq(false)
        end
      end
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
    def subject(string)
      dummy_class.get_hierarchy_phylum(string)
    end

    it 'returns taxon data when taxon has long hierarchy names' do
      hierarchy_names = {
        superkingdom: 'Superkingdom',
        kingdom: 'Kingdom',
        phylum: 'Phylum',
        subphylum: 'Subphylum',
        class: 'Class',
        subclass: 'Subclass',
        superorder: 'Superorder',
        order: 'Order',
        suborder: 'Suborder',
        infraorder: 'Infraorder',
        superfamily: 'Superfamily',
        family: 'Family',
        genus: 'Genus',
        species: 'Species'
      }
      create(:ncbi_node, canonical_name: 'Genus', rank: 'genus',
                         hierarchy_names: hierarchy_names)
      string = 'Phylum;Class;Order;Family;Genus;'

      expect(subject(string)).to eq(
        phylum: 'Phylum', class: 'Class', order: 'Order', family: 'Family',
        genus: 'Genus'
      )
    end

    it 'returns a hash of taxonomy names' do
      create(
        :ncbi_node,
        canonical_name: 'Species',
        rank: 'species',
        hierarchy_names: {
          superkingdom: 'Superkingdom',
          kingdom: 'Kingdom',
          phylum: 'Phylum',
          class: 'Class',
          order: 'Order',
          family: 'Family',
          genus: 'Genus',
          species: 'Species'
        }
      )
      string = 'Phylum;Class;Order;Family;Genus;Species'
      expected = {
        phylum: 'Phylum',
        class: 'Class',
        order: 'Order',
        family: 'Family',
        genus: 'Genus',
        species: 'Species'
      }

      expect(subject(string)).to eq(expected)
    end

    it 'returns hash that does not contain missing taxa' do
      create(
        :ncbi_node,
        canonical_name: 'Genus',
        rank: 'genus',
        hierarchy_names: {
          superkingdom: 'Superkingdom',
          kingdom: 'Kingdom',
          phylum: 'Phylum',
          class: 'Class',
          family: 'Family',
          genus: 'Genus'
        }
      )
      string = 'Phylum;Class;;Family;Genus;'
      expected = {
        phylum: 'Phylum',
        class: 'Class',
        family: 'Family',
        genus: 'Genus'
      }

      expect(subject(string)).to eq(expected)
    end

    it 'returns hash that does not contain "NA" taxa' do
      create(
        :ncbi_node,
        canonical_name: 'Genus',
        rank: 'genus',
        hierarchy_names: {
          superkingdom: 'Superkingdom',
          kingdom: 'Kingdom',
          phylum: 'Phylum',
          class: 'Class',
          family: 'Family',
          genus: 'Genus'
        }
      )
      string = 'Phylum;Class;NA;Family;Genus;NA'
      expected = {
        phylum: 'Phylum',
        class: 'Class',
        family: 'Family',
        genus: 'Genus'
      }

      expect(subject(string)).to eq(expected)
    end

    it 'retuns empty hash when entire string is "NA"' do
      string = 'NA'
      expect(subject(string)).to eq({})
    end

    it 'retuns empty hash when entire string is ";;;;;"' do
      string = ';;;;;'
      expect(subject(string)).to eq({})
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
    def subject(string)
      dummy_class.get_hierarchy_superkingdom(string)
    end

    it 'returns taxon data when taxon has long hierarchy names' do
      hierarchy_names = {
        superkingdom: 'Superkingdom',
        kingdom: 'Kingdom',
        phylum: 'Phylum',
        subphylum: 'Subphylum',
        class: 'Class',
        subclass: 'Subclass',
        superorder: 'Superorder',
        order: 'Order',
        suborder: 'Suborder',
        infraorder: 'Infraorder',
        superfamily: 'Superfamily',
        family: 'Family',
        genus: 'Genus',
        species: 'Species'
      }
      create(:ncbi_node, canonical_name: 'Genus', rank: 'genus',
                         hierarchy_names: hierarchy_names)
      string = 'Superkingdom;Phylum;Class;Order;Family;Genus;'

      expect(subject(string)).to eq(
        superkingdom: 'Superkingdom', phylum: 'Phylum', class: 'Class',
        order: 'Order', family: 'Family', genus: 'Genus'
      )
    end

    it 'returns a hash of taxonomy names' do
      create(
        :ncbi_node,
        canonical_name: 'Species',
        rank: 'species',
        hierarchy_names: {
          superkingdom: 'Superkingdom',
          kingdom: 'Kingdom',
          phylum: 'Phylum',
          class: 'Class',
          order: 'Order',
          family: 'Family',
          genus: 'Genus',
          species: 'Species'
        }
      )
      string = 'Superkingdom;Phylum;Class;Order;Family;Genus;Species'
      expected = {
        superkingdom: 'Superkingdom',
        phylum: 'Phylum',
        class: 'Class',
        order: 'Order',
        family: 'Family',
        genus: 'Genus',
        species: 'Species'
      }

      expect(subject(string)).to eq(expected)
    end

    it 'returns hash that does not contain missing taxa' do
      create(
        :ncbi_node,
        canonical_name: 'Genus',
        rank: 'genus',
        hierarchy_names: {
          superkingdom: 'Superkingdom',
          kingdom: 'Kingdom',
          phylum: 'Phylum',
          class: 'Class',
          family: 'Family',
          genus: 'Genus'
        }
      )
      string = 'Superkingdom;Phylum;Class;;Family;Genus;'
      expected = {
        superkingdom: 'Superkingdom',
        phylum: 'Phylum',
        class: 'Class',
        family: 'Family',
        genus: 'Genus'
      }

      expect(subject(string)).to eq(expected)
    end

    it 'returns hash that does not contain "NA" taxa' do
      create(
        :ncbi_node,
        canonical_name: 'Genus',
        rank: 'genus',
        hierarchy_names: {
          superkingdom: 'Superkingdom',
          kingdom: 'Kingdom',
          phylum: 'Phylum',
          class: 'Class',
          family: 'Family',
          genus: 'Genus'
        }
      )
      string = 'Superkingdom;Phylum;Class;NA;Family;Genus;NA'
      expected = {
        superkingdom: 'Superkingdom',
        phylum: 'Phylum',
        class: 'Class',
        family: 'Family',
        genus: 'Genus'
      }

      expect(subject(string)).to eq(expected)
    end

    it 'retuns empty hash when entire string is "NA"' do
      string = 'NA'
      expect(subject(string)).to eq({})
    end

    it 'retuns empty hash when entire string is ";;;;;"' do
      string = ';;;;;;'
      expect(subject(string)).to eq({})
    end
  end

  describe '#find_existing_taxa' do
    let(:taxon_data) { {} }

    def subject(hierarchy, rank)
      dummy_class.find_existing_taxa(hierarchy, rank, taxon_data)
    end

    describe 'it calls a series of find taxa methods' do
      let(:name) { 'name' }
      let(:hierarchy) { { superkingdom: 'Sk', family: name } }
      let(:rank) { 'family' }
      let(:taxon) { create(:ncbi_node) }

      it "if find_taxa_by_canonical_name works, other methods aren't called" do
        allow(dummy_class)
          .to receive_message_chain(:find_taxa_by_canonical_name)
          .and_return(taxon)

        expect(dummy_class).to receive(:find_taxa_by_canonical_name)
          .with(name, hierarchy)
        expect(dummy_class).to_not receive(:find_taxa_with_quotes)
        expect(dummy_class).to_not receive(:find_taxa_by_ncbi_names)

        subject(hierarchy, rank)
      end

      it 'if find_taxa_by_canonical_name fails, call find_taxa_with_quotes' do
        allow(dummy_class)
          .to receive_message_chain(:find_taxa_by_canonical_name)
          .and_return(nil)
        allow(dummy_class)
          .to receive_message_chain(:find_taxa_with_quotes)
          .and_return(taxon)

        expect(dummy_class).to receive(:find_taxa_by_canonical_name)
          .with(name, hierarchy)
        expect(dummy_class).to receive(:find_taxa_with_quotes)
          .with(name, hierarchy)
        expect(dummy_class).to_not receive(:find_taxa_by_ncbi_names)

        subject(hierarchy, rank)
      end

      it 'if find_taxa_with_quotes fails, call find_taxa_by_ncbi_names' do
        allow(dummy_class)
          .to receive_message_chain(:find_taxa_by_canonical_name)
          .and_return(nil)
        allow(dummy_class)
          .to receive_message_chain(:find_taxa_with_quotes)
          .and_return(nil)

        expect(dummy_class).to receive(:find_taxa_by_canonical_name)
          .with(name, hierarchy)
        expect(dummy_class).to receive(:find_taxa_with_quotes)
          .with(name, hierarchy)
        expect(dummy_class).to receive(:find_taxa_by_ncbi_names)
          .with(name, hierarchy)

        subject(hierarchy, rank)
      end
    end

    it 'returns taxa if hierarchy lowest name matches taxa canonical name' do
      name = 'Name'
      given_hierarchy = { superkingdom: 'Sk', class: 'C', family: name }
      given_rank = 'family'

      hierarchy1 = { superkingdom: 'Sk', class: 'C', sublass: name }
      rank1 = 'sublass'
      taxon = create(:ncbi_node, hierarchy_names: hierarchy1, rank: rank1,
                                 canonical_name: hierarchy1[rank1.to_sym])

      expect(subject(given_hierarchy, given_rank)).to eq([taxon])
      expect(taxon_data).to eq(match_type: :find_canonical_name)
    end

    it "returns taxa if hierarchy lowest name doesn't have " \
      'quotes, but taxa canonical name does have quote' do
      given_hierarchy = { genus: 'G', species: 'Species name' }
      rank = 'species'

      hierarchy1 = { genus: 'G', species: "Species 'name'" }
      rank1 = 'species'
      taxon = create(:ncbi_node, hierarchy_names: hierarchy1, rank: rank1,
                                 canonical_name: hierarchy1[rank1.to_sym])

      expect(subject(given_hierarchy, rank)).to eq([taxon])
      expect(taxon_data).to eq(match_type: :find_with_quotes)
    end

    it 'returns match if hierarchy lowest names matches taxa synonym' do
      given_hierarchy = { genus: 'G', species: 'alt3' }
      rank = 'species'

      hierarchy1 = { genus: 'G', species: 'Species' }
      rank1 = 'species'
      taxon = create(:ncbi_node, hierarchy_names: hierarchy1, rank: rank1,
                                 ncbi_id: 100,
                                 canonical_name: hierarchy1[rank1.to_sym])
      create(:ncbi_name, name_class: 'synonym', name: 'alt3', taxon_id: 100)

      expect(subject(given_hierarchy, rank)).to eq([taxon.reload])
      expect(taxon_data).to eq(match_type: :find_other_names)
    end

    it 'returns empty array otherwise' do
      given_hierarchy = { phylum: 'P', family: 'F1' }

      hierarchy = { phylum: 'P', family: 'F2' }
      rank = 'family'
      create(:ncbi_node, hierarchy_names: hierarchy, rank: rank,
                         canonical_name: hierarchy[rank.to_sym])

      expect(subject(given_hierarchy, rank)).to eq([])
      expect(taxon_data).to eq(match_type: nil)
    end
  end

  describe '#find_taxa_by_canonical_name' do
    def subject(name, hierarchy)
      dummy_class.find_taxa_by_canonical_name(name, hierarchy)
    end

    let(:name1) { 'name1' }
    let(:name2) { 'name2' }

    it 'returns empty array when lowest names differ' do
      given_hier = { superkingdom: 'sk', family: name1 }

      hierarchy1 = { superkingdom: 'sk', class: name1, family: name2 }
      create(:ncbi_node, canonical_name: name2, rank: 'family',
                         hierarchy_names: hierarchy1)

      expect(subject(name1, given_hier))
        .to match_array([])
    end

    context 'when there is one taxon that matches the lowest name' do
      it 'and rank is the same, returns taxon' do
        given_hier = { superkingdom: 'sk', family: name1 }

        hierarchy1 = given_hier
        taxon = create(:ncbi_node, canonical_name: name1, rank: 'family',
                                   hierarchy_names: hierarchy1)

        hierarchy2 = { superkingdom: 'sk', family: name2 }
        create(:ncbi_node, canonical_name: name2, rank: 'family',
                           hierarchy_names: hierarchy2)

        expect(subject(name1, given_hier))
          .to match_array([taxon])
      end

      it 'and rank is different, returns taxon' do
        given_hier = { superkingdom: 'sk', family: name1 }

        hierarchy1 = { superkingdom: 'sk', genus: name1 }
        taxon = create(:ncbi_node, canonical_name: name1, rank: 'genus',
                                   hierarchy_names: hierarchy1)

        hierarchy2 = { superkingdom: 'sk', family: name2 }
        create(:ncbi_node, canonical_name: name2, rank: 'family',
                           hierarchy_names: hierarchy2)

        expect(subject(name1, given_hier))
          .to match_array([taxon])
      end

      it 'and rank is no rank, returns taxon' do
        given_hier = { superkingdom: 'sk', family: name1 }

        hierarchy1 = { superkingdom: 'sk', 'no rank': name1 }
        taxon = create(:ncbi_node, canonical_name: name1, rank: 'no rank',
                                   hierarchy_names: hierarchy1)

        expect(subject(name1, given_hier))
          .to match_array([taxon])
      end

      it 'and rank is minor rank, returns taxon' do
        given_hier = { superkingdom: 'sk', family: name1 }

        hierarchy1 = { superkingdom: 'sk', subfamily: name1 }
        taxon = create(:ncbi_node, canonical_name: name1, rank: 'subfamily',
                                   hierarchy_names: hierarchy1)

        expect(subject(name1, given_hier))
          .to match_array([taxon])
      end
    end

    context 'when there are multiple taxa that have same lowest name' do
      it 'and given hierarchy is an exact match, returns matching taxa' do
        given_hier = { class: 'c', order: 'o', family: name1 }

        hierarchy1 = given_hier
        taxon1 = create(:ncbi_node, canonical_name: name1, rank: 'family',
                                    hierarchy_names: hierarchy1)
        taxon2 = create(:ncbi_node, canonical_name: name1, rank: 'family',
                                    hierarchy_names: hierarchy1)

        hierarchy2 = { class: '-', order: 'o', family: name1 }
        create(:ncbi_node, canonical_name: name1, rank: 'family',
                           hierarchy_names: hierarchy2)

        hierarchy3 = { order: '-', family: name1 }
        create(:ncbi_node, canonical_name: name1, rank: 'family',
                           hierarchy_names: hierarchy3)

        expect(subject(name1, given_hier))
          .to match_array([taxon1, taxon2])
      end

      it 'but ranks are different, returns taxa that match rank & name' do
        given_hier = { class: 'c', family: name1 }

        hierarchy1 = given_hier
        taxon1 = create(:ncbi_node, canonical_name: name1, rank: 'family',
                                    hierarchy_names: hierarchy1)
        taxon2 = create(:ncbi_node, canonical_name: name1, rank: 'family',
                                    hierarchy_names: hierarchy1)

        hierarchy2 = { class: 'c', genus: name1 }
        create(:ncbi_node, canonical_name: name1, rank: 'genus',
                           hierarchy_names: hierarchy2)

        expect(subject(name1, given_hier))
          .to match_array([taxon1, taxon2])
      end

      it 'and given hierarchy matches the lower ranks, returns matching taxa' do
        given_hier = { class: 'c', order: 'o', family: name1 }

        hierarchy1 = given_hier.merge(phylum: 'p')
        taxon1 = create(:ncbi_node, canonical_name: name1, rank: 'family',
                                    hierarchy_names: hierarchy1)

        hierarchy2 = given_hier.merge(kingdom: 'k')
        taxon2 = create(:ncbi_node, canonical_name: name1, rank: 'family',
                                    hierarchy_names: hierarchy2)

        expect(subject(name1, given_hier))
          .to match_array([taxon1, taxon2])
      end

      it 'and hierarchy matches the mid ranks, returns taxa w/ same rank' do
        given_hier = { class: 'c', order: 'o', family: name1 }

        hierarchy1 = given_hier
        taxon1 = create(:ncbi_node, canonical_name: name1, rank: 'family',
                                    hierarchy_names: hierarchy1)

        hierarchy2 = given_hier.merge(subfamily: name1)
        create(:ncbi_node, canonical_name: name1, rank: 'subfamily',
                           hierarchy_names: hierarchy2)

        expect(subject(name1, given_hier))
          .to match_array([taxon1])
      end

      it 'and ranks do not match, returns empty array' do
        given_hier = { class: 'c', order: 'o', family: name1 }

        hierarchy1 = { class: 'c', order: 'o', subfamily: name1 }
        create(:ncbi_node, canonical_name: name1, rank: 'subfamily',
                           hierarchy_names: hierarchy1)

        hierarchy2 = { class: 'c', order: 'o', genus: name1 }
        create(:ncbi_node, canonical_name: name1, rank: 'genus',
                           hierarchy_names: hierarchy2)

        hierarchy3 = { class: 'c', order: 'o', 'no rank': name1 }
        create(:ncbi_node, canonical_name: name1, rank: 'no rank',
                           hierarchy_names: hierarchy3)

        expect(subject(name1, given_hier))
          .to match_array([])
      end
    end

    context 'when hierarchy has one item' do
      it 'and multiple matches for name and rank, returns all matching taxa' do
        hierarchy = { class: name1 }

        taxon1 = create(:ncbi_node, canonical_name: name1, rank: 'class',
                                    hierarchy_names: hierarchy)
        taxon2 = create(:ncbi_node, canonical_name: name1, rank: 'class',
                                    hierarchy_names: hierarchy)

        expect(subject(name1, hierarchy))
          .to match_array([taxon1, taxon2])
      end

      it 'and multiple matches for name, returns taxa with same rank' do
        given_hier = { class: name1 }

        hierarchy1 = given_hier
        taxon1 = create(:ncbi_node, canonical_name: name1, rank: 'class',
                                    hierarchy_names: hierarchy1)

        hierarchy2 = { order: name1 }
        create(:ncbi_node, canonical_name: name1, rank: 'order',
                           hierarchy_names: hierarchy2)

        expect(subject(name1, given_hier))
          .to match_array([taxon1])
      end

      it "and multiple matches for name, but ranks don't match, returns []" do
        given_hier = { class: name1 }

        hierarchy1 = { family: name1 }
        create(:ncbi_node, canonical_name: name1, rank: 'family',
                           hierarchy_names: hierarchy1)

        hierarchy2 = { order: name1 }
        create(:ncbi_node, canonical_name: name1, rank: 'order',
                           hierarchy_names: hierarchy2)

        expect(subject(name1, given_hier))
          .to match_array([])
      end

      it 'and one match for name, returns taxa regardless of rank' do
        given_hier = { class: name1 }

        hierarchy1 = { order: name1 }
        taxon1 = create(:ncbi_node, canonical_name: name1, rank: 'order',
                                    hierarchy_names: hierarchy1)

        expect(subject(name1, given_hier))
          .to match_array([taxon1])
      end

      it 'and there are no matches for name, returns empty array' do
        hierarchy = { class: name1 }

        hierarchy1 = { class: name2 }
        create(:ncbi_node, canonical_name: name2, rank: 'class',
                           hierarchy_names: hierarchy1)

        expect(subject(name1, hierarchy)).to eq([])
      end
    end
  end

  describe '#find_taxa_by_ncbi_names' do
    def subject(name, hierarchy)
      dummy_class.find_taxa_by_ncbi_names(name, hierarchy)
    end

    let(:name1) { 'name1' }
    let(:name2) { 'name2' }

    context 'when lowest name matches only one alternative name' do
      it 'returns match' do
        alt_name = 'alt name'
        given_hierarchy = { family: 'F', species: alt_name }

        hierarchy1 = { family: 'F', species: name1 }
        rank1 = 'species'
        taxon1 = create(:ncbi_node, hierarchy_names: hierarchy1, rank: rank1,
                                    ncbi_id: 100, canonical_name: name1)
        create(:ncbi_name, name_class: 'synonym', name: alt_name, taxon_id: 100)

        expect(subject(alt_name, given_hierarchy)).to eq([taxon1.reload])
      end

      it 'returns match regardless of rank' do
        alt_name = 'alt name'
        given_hierarchy = { family: 'F', species: alt_name }

        hierarchy1 = { family: 'F', genus: name1 }
        rank1 = 'genus'
        taxon1 = create(:ncbi_node, hierarchy_names: hierarchy1, rank: rank1,
                                    ncbi_id: 100, canonical_name: name1)
        create(:ncbi_name, name_class: 'synonym', name: alt_name, taxon_id: 100)

        expect(subject(alt_name, given_hierarchy)).to eq([taxon1.reload])
      end
    end

    context 'when lowest name matches multiple alternative names' do
      it 'and given hierarchy is an exact match, returns matching taxa' do
        alt_name = 'alt name'
        given_hierarchy = { family: 'F', species: alt_name }

        hierarchy1 = { family: 'F', species: name1 }
        rank1 = 'species'
        taxon1 = create(:ncbi_node, hierarchy_names: hierarchy1, rank: rank1,
                                    ncbi_id: 100, canonical_name: name1)
        create(:ncbi_name, name_class: 'synonym', name: alt_name, taxon_id: 100)

        hierarchy2 = { family: 'F', species: name2 }
        rank2 = 'species'
        taxon2 = create(:ncbi_node, hierarchy_names: hierarchy2, rank: rank2,
                                    ncbi_id: 200, canonical_name: name2)
        create(:ncbi_name, name_class: 'synonym', name: alt_name, taxon_id: 200)

        hierarchy3 = { family: '-', species: 'name3' }
        rank3 = 'species'
        create(:ncbi_node, hierarchy_names: hierarchy3, rank: rank3,
                           ncbi_id: 300, canonical_name: 'name3')
        create(:ncbi_name, name_class: 'synonym', name: alt_name, taxon_id: 300)

        expect(subject(alt_name, given_hierarchy))
          .to match_array([taxon1.reload, taxon2.reload])
      end

      it 'but ranks are different, returns taxa that match rank & name' do
        alt_name = 'alt name'
        given_hierarchy = { family: 'F', species: alt_name }

        hierarchy1 = { family: 'F', species: name1 }
        rank1 = 'species'
        taxon1 = create(:ncbi_node, hierarchy_names: hierarchy1, rank: rank1,
                                    ncbi_id: 100, canonical_name: name1)
        create(:ncbi_name, name_class: 'synonym', name: alt_name, taxon_id: 100)

        hierarchy2 = { family: 'F', genus: name2 }
        rank2 = 'genus'
        create(:ncbi_node, hierarchy_names: hierarchy2, rank: rank2,
                           ncbi_id: 200, canonical_name: name2)
        create(:ncbi_name, name_class: 'synonym', name: alt_name, taxon_id: 200)

        expect(subject(alt_name, given_hierarchy))
          .to match_array([taxon1.reload])
      end

      it 'and given hierarchy matches the lower ranks, returns matching taxa' do
        alt_name = 'alt name'
        given_hierarchy = { family: 'F', species: alt_name }

        hierarchy1 = { order: 'O', family: 'F', species: name1 }
        rank1 = 'species'
        taxon1 = create(:ncbi_node, hierarchy_names: hierarchy1, rank: rank1,
                                    ncbi_id: 100, canonical_name: name1)
        create(:ncbi_name, name_class: 'synonym', name: alt_name, taxon_id: 100)

        hierarchy2 = { class: 'C', family: 'F', species: name2 }
        rank2 = 'species'
        taxon2 = create(:ncbi_node, hierarchy_names: hierarchy2, rank: rank2,
                                    ncbi_id: 200, canonical_name: name2)
        create(:ncbi_name, name_class: 'synonym', name: alt_name, taxon_id: 200)

        expect(subject(alt_name, given_hierarchy))
          .to match_array([taxon1.reload, taxon2.reload])
      end

      it 'and hierarchy matches the mid ranks, returns taxa w/ same rank' do
        alt_name = 'alt name'
        given_hierarchy = { family: 'F', species: alt_name }

        hierarchy1 = { family: 'F', species: name1 }
        rank1 = 'species'
        taxon1 = create(:ncbi_node, hierarchy_names: hierarchy1, rank: rank1,
                                    ncbi_id: 100, canonical_name: name1)
        create(:ncbi_name, name_class: 'synonym', name: alt_name, taxon_id: 100)

        hierarchy2 = { family: 'F', species: name2, subspecies: name2 }
        rank2 = 'subspecies'
        create(:ncbi_node, hierarchy_names: hierarchy2, rank: rank2,
                           ncbi_id: 200, canonical_name: name2)
        create(:ncbi_name, name_class: 'synonym', name: alt_name, taxon_id: 200)

        expect(subject(alt_name, given_hierarchy))
          .to match_array([taxon1.reload])
      end

      it 'and ranks do not match, returns empty array' do
        alt_name = 'alt name'
        given_hierarchy = { family: 'F', species: alt_name }

        hierarchy1 = { family: 'F', genus: name1 }
        rank1 = 'genus'
        create(:ncbi_node, hierarchy_names: hierarchy1, rank: rank1,
                           ncbi_id: 100, canonical_name: name1)
        create(:ncbi_name, name_class: 'synonym', name: alt_name, taxon_id: 100)

        hierarchy2 = { family: 'F', subgenus: name2 }
        rank2 = 'subgenus'
        create(:ncbi_node, hierarchy_names: hierarchy2, rank: rank2,
                           ncbi_id: 200, canonical_name: name2)
        create(:ncbi_name, name_class: 'synonym', name: alt_name, taxon_id: 200)

        expect(subject(alt_name, given_hierarchy))
          .to match_array([])
      end
    end
  end

  describe '#find_sample_from_barcode' do
    let(:barcode) { 'K0001-LA-S1' }
    let(:project) { create(:field_project, name: 'unknown') }
    let(:status) { :approved }

    def subject
      dummy_class.find_sample_from_barcode(barcode, status)
    end

    context 'there are no samples for a given bar code' do
      it 'creates a new sample' do
        stub_const('FieldProject::DEFAULT_PROJECT', project)

        expect { subject }.to change { Sample.count }.by(1)
      end

      it 'returns the created sample' do
        stub_const('FieldProject::DEFAULT_PROJECT', project)
        result = subject

        expect(result.barcode).to eq(barcode)
        expect(result.field_project).to eq(project)
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

  describe '#find_canonical_taxon_from_string' do
    def subject(string)
      dummy_class.find_canonical_taxon_from_string(string)
    end

    it 'returns species if it exists' do
      string = 'superkingdom;phlyum;class;order;family;genus;species'

      expect(subject(string)).to eq('species')
    end

    it 'returns genus if it exists' do
      string = 'superkingdom;phlyum;class;order;family;genus;'

      expect(subject(string)).to eq('genus')
    end

    it 'returns family if it exists' do
      string = 'superkingdom;phlyum;class;order;family;;'

      expect(subject(string)).to eq('family')
    end

    it 'returns order if it exists' do
      string = 'superkingdom;phlyum;class;order;;;'

      expect(subject(string)).to eq('order')
    end

    it 'returns class if it exists' do
      string = 'superkingdom;phlyum;class;;;;'

      expect(subject(string)).to eq('class')
    end

    it 'returns phlyum if it exists' do
      string = 'superkingdom;phlyum;;;;;'

      expect(subject(string)).to eq('phlyum')
    end

    it 'returns superkingdom if it exists' do
      string = 'superkingdom;;;;;;'

      expect(subject(string)).to eq('superkingdom')
    end

    it 'ignores species NA' do
      string = 'superkingdom;phlyum;class;order;family;genus;NA'

      expect(subject(string)).to eq('genus')
    end

    it 'ignores genus NA' do
      string = 'superkingdom;phlyum;class;order;family;NA;NA'

      expect(subject(string)).to eq('family')
    end

    it 'ignores family NA' do
      string = 'superkingdom;phlyum;class;order;NA;NA;NA'

      expect(subject(string)).to eq('order')
    end

    it 'ignores order NA' do
      string = 'superkingdom;phlyum;class;NA;NA;NA;NA'

      expect(subject(string)).to eq('class')
    end

    it 'ignores class NA' do
      string = 'superkingdom;phlyum;NA;NA;NA;NA;NA'

      expect(subject(string)).to eq('phlyum')
    end

    it 'ignores phylum NA' do
      string = 'superkingdom;NA;NA;NA;NA;NA;NA'

      expect(subject(string)).to eq('superkingdom')
    end

    it 'returns NA if string is NA' do
      string = 'NA'

      expect(subject(string)).to eq('NA')
    end

    it 'returns semicolons if string is combination of NA and ;;' do
      string = 'NA;;NA;NA;;;NA'

      expect(subject(string)).to eq(';;;;;;')
    end
  end

  describe '#remove_na' do
    def subject(string)
      dummy_class.remove_na(string)
    end

    it 'removes beginning NA' do
      string = 'NA;NA;b;NA;c'
      expect(subject(string)).to eq(';;b;;c')
    end

    it 'removes middle NA' do
      string = 'a;NA;b;NA;c'
      expect(subject(string)).to eq('a;;b;;c')
    end

    it 'removes ending NA' do
      string = 'a;NA;b;NA;NA'

      expect(subject(string)).to eq('a;;b;;')
    end

    it 'removes consecutive NA' do
      string = 'a;NA;NA;NA;c'
      expect(subject(string)).to eq('a;;;;c')
    end

    it 'does not change string' do
      string = 'a;NA;NA;NA;c'
      new_string = subject(string)

      expect(new_string).to eq('a;;;;c')
      expect(string).to eq(string)
    end
  end

  describe '#find_result_taxon_from_string' do
    def subject(string)
      dummy_class.find_result_taxon_from_string(string)
    end

    def clean_string(string)
      dummy_class.remove_na(string)
    end

    context 'phylum taxonomy string' do
      it 'handles complete taxonomy strings and returns matching ResultTaxon' do
        taxonomy_string = 'Phylum;Class;Order;Family;Genus;Species'
        clean_string = clean_string(taxonomy_string)
        rank = 'species'
        taxa = create(:result_taxon, clean_taxonomy_string_phylum: clean_string,
                                     normalized: true, taxon_rank: rank)

        expect(subject(taxonomy_string)).to eq(taxa)
      end

      it 'handles blank ranks and returns matching ResultTaxon' do
        taxonomy_string = 'Phylum;;Order;Family;;Species'
        clean_string = clean_string(taxonomy_string)
        rank = 'species'
        taxa = create(:result_taxon, clean_taxonomy_string_phylum: clean_string,
                                     normalized: true, taxon_rank: rank)

        expect(subject(taxonomy_string)).to eq(taxa)
      end

      it 'handles NA and returns matching ResultTaxon' do
        taxonomy_string = 'NA;NA;Order;Family;NA;Species'
        clean_string = clean_string(taxonomy_string)
        rank = 'species'
        taxa = create(:result_taxon, clean_taxonomy_string_phylum: clean_string,
                                     normalized: true, taxon_rank: rank)

        expect(subject(taxonomy_string)).to eq(taxa)
      end

      it 'taxonomy string with same cleaned string returns same ResultTaxon' do
        taxonomy_string1 = 'Phylum;NA;Order;;;'
        taxonomy_string2 = 'Phylum;;Order;;;'
        taxonomy_string3 = 'Phylum;NA;Order;NA;NA;'
        taxonomy_string4 = ';Order;;;;'
        clean_string = 'Phylum;;Order;;;'
        rank = 'order'

        taxa = create(:result_taxon, clean_taxonomy_string_phylum: clean_string,
                                     normalized: true, taxon_rank: rank)
        expect(subject(taxonomy_string1)).to eq(taxa)
        expect(subject(taxonomy_string2)).to eq(taxa)
        expect(subject(taxonomy_string3)).to eq(taxa)
        expect(subject(taxonomy_string4)).to eq(nil)
      end
    end

    context 'superkingdom taxonomy string' do
      it 'handles complete taxonomy strings and returns matching ResultTaxon' do
        taxonomy_string = 'Superkingdom;Phylum;Class;Order;Family;Genus;Species'
        clean_string = clean_string(taxonomy_string)
        rank = 'species'
        taxa = create(:result_taxon, clean_taxonomy_string: clean_string,
                                     normalized: true, taxon_rank: rank)

        expect(subject(taxonomy_string)).to eq(taxa)
      end

      it 'handles blank ranks and returns matching ResultTaxon' do
        taxonomy_string = ';Phylum;;Order;Family;;Species'
        clean_string = clean_string(taxonomy_string)
        rank = 'species'
        taxa = create(:result_taxon, clean_taxonomy_string: clean_string,
                                     normalized: true, taxon_rank: rank)

        expect(subject(taxonomy_string)).to eq(taxa)
      end

      it 'handles NA and returns matching ResultTaxon' do
        taxonomy_string = 'NA;NA;;Order;Family;NA;Species'
        clean_string = clean_string(taxonomy_string)
        rank = 'species'
        taxa = create(:result_taxon, clean_taxonomy_string: clean_string,
                                     normalized: true, taxon_rank: rank)

        expect(subject(taxonomy_string)).to eq(taxa)
      end
    end
  end

  describe '#process_barcodes_for_csv_table' do
    def subject(csv_data)
      dummy_class.process_barcodes_for_csv_table(csv_data, 'barcode')
    end

    let(:csv) { './spec/fixtures/import_csv/samples.csv' }
    let(:file) { fixture_file_upload(csv, 'text/csv') }
    let(:csv_data) do
      delimiter = ';'
      CSV.read(file.path, headers: true, col_sep: delimiter)
    end
    let(:barcode1) { 'K9999-A1' }
    let(:barcode2) { 'K9999-A2' }

    context 'when csv data has mix of existing and new barcodes' do
      it 'returns hash of existing and new barcodes' do
        create(:sample, barcode: barcode1)
        expected = { existing_barcodes: [barcode1], new_barcodes: [barcode2] }

        expect(subject(csv_data)).to eq(expected)
      end
    end

    context 'when csv data only has existing barcodes' do
      it 'returns hash of existing barcodes' do
        create(:sample, barcode: barcode1)
        create(:sample, barcode: barcode2)
        expected = { existing_barcodes: [barcode1, barcode2], new_barcodes: [] }

        expect(subject(csv_data)).to eq(expected)
      end
    end

    context 'when csv data only has new barcodes' do
      it 'returns hash of new barcodes' do
        expected = { existing_barcodes: [], new_barcodes: [barcode1, barcode2] }

        expect(subject(csv_data)).to eq(expected)
      end
    end
  end

  describe '#filtered_hierarchy' do
    def subject(hierarchy, ranks)
      dummy_class.filtered_hierarchy(hierarchy, ranks)
    end

    it 'returns a subset of the hierachy based on passed in ranks' do
      hierarchy = { kingdom: 'k', genus: 'g', phylum: 'p', species: 's',
                    order: 'o', superkingdom: 'sk', family: 'f', class: 'c' }
      ranks = %i[species genus family order class phylum kingdom superkingdom]

      expect(subject(hierarchy, ranks[0, 1])).to match(species: 's')

      expect(subject(hierarchy, ranks[0, 2])).to match(species: 's', genus: 'g')

      expect(subject(hierarchy, ranks[0, 3]))
        .to match(species: 's', genus: 'g', family: 'f')

      expect(subject(hierarchy, ranks[0, 4]))
        .to match(species: 's', genus: 'g', family: 'f', order: 'o')

      expect(subject(hierarchy, ranks[0, 5]))
        .to match(species: 's', genus: 'g', family: 'f', order: 'o', class: 'c')

      expect(subject(hierarchy, ranks[0, 6]))
        .to match(species: 's', genus: 'g', family: 'f', order: 'o', class: 'c',
                  phylum: 'p')

      expect(subject(hierarchy, ranks[0, 7]))
        .to match(species: 's', genus: 'g', family: 'f', order: 'o', class: 'c',
                  phylum: 'p', kingdom: 'k')

      expect(subject(hierarchy, ranks[0, 8]))
        .to match(species: 's', genus: 'g', family: 'f', order: 'o', class: 'c',
                  phylum: 'p', kingdom: 'k', superkingdom: 'sk')
    end

    it 'works with sparse hierarchies' do
      hierarchy = { kingdom: 'k', genus: 'g', superkingdom: 'sk', class: 'c' }
      ranks = %i[genus class kingdom superkingdom]

      expect(subject(hierarchy, ranks[0, 1])).to match(genus: 'g')

      expect(subject(hierarchy, ranks[0, 2])).to match(class: 'c', genus: 'g')

      expect(subject(hierarchy, ranks[0, 3]))
        .to match(class: 'c', genus: 'g', kingdom: 'k')

      expect(subject(hierarchy, ranks[0, 4]))
        .to match(class: 'c', genus: 'g', kingdom: 'k', superkingdom: 'sk')
    end

    it 'returns nil if passed in ranks is empty array' do
      hierarchy = { kingdom: 'k', genus: 'g', superkingdom: 'sk' }
      ranks = []

      expect(subject(hierarchy, ranks)).to eq(nil)
    end
  end

  describe '#filtered_ranks_by_number' do
    def subject(hierarchy, rank_count, skip_lowest = false)
      dummy_class.filtered_ranks_by_number(hierarchy, rank_count, skip_lowest)
    end

    it 'returns a ordered array of ranks for a given hierarchy and number' do
      hierarchy = { kingdom: 'k', genus: 'g', phylum: 'p', species: 's',
                    order: 'o', superkingdom: 'sk', family: 'f', class: 'c' }

      expect(subject(hierarchy, 8))
        .to eq(%i[species genus family order class phylum kingdom superkingdom])
      expect(subject(hierarchy, 7))
        .to eq(%i[species genus family order class phylum kingdom])
      expect(subject(hierarchy, 6))
        .to eq(%i[species genus family order class phylum])
      expect(subject(hierarchy, 5))
        .to eq(%i[species genus family order class])
      expect(subject(hierarchy, 4)).to eq(%i[species genus family order])
      expect(subject(hierarchy, 3)).to eq(%i[species genus family])
      expect(subject(hierarchy, 2)).to eq(%i[species genus])
      expect(subject(hierarchy, 1)).to eq([:species])
      expect(subject(hierarchy, 0)).to eq([])
    end

    it 'correctly handles sparse hierarchy' do
      hierarchy = { kingdom: 'k', genus: 'g',
                    order: 'o', superkingdom: 'sk', class: 'c' }

      expect(subject(hierarchy, 5))
        .to eq(%i[genus order class kingdom superkingdom])
      expect(subject(hierarchy, 4)).to eq(%i[genus order class kingdom])
      expect(subject(hierarchy, 3)).to eq(%i[genus order class])
      expect(subject(hierarchy, 2)).to eq(%i[genus order])
      expect(subject(hierarchy, 1)).to eq([:genus])
      expect(subject(hierarchy, 0)).to eq([])
    end

    context 'when skip_lowest is true' do
      it 'does not return lowest rank' do
        hierarchy = { kingdom: 'k', genus: 'g', phylum: 'p', species: 's',
                      order: 'o', superkingdom: 'sk', family: 'f', class: 'c' }

        expect(subject(hierarchy, 7, true))
          .to eq(%i[genus family order class phylum kingdom superkingdom])
        expect(subject(hierarchy, 6, true))
          .to eq(%i[genus family order class phylum kingdom])
        expect(subject(hierarchy, 5, true))
          .to eq(%i[genus family order class phylum])
        expect(subject(hierarchy, 4, true))
          .to eq(%i[genus family order class])
        expect(subject(hierarchy, 3, true)).to eq(%i[genus family order])
        expect(subject(hierarchy, 2, true)).to eq(%i[genus family])
        expect(subject(hierarchy, 1, true)).to eq(%i[genus])
        expect(subject(hierarchy, 0, true)).to eq([])
      end
    end
  end
end
