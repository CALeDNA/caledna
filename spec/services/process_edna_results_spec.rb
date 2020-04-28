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

    let(:id) { 100 }
    let(:ncbi_id) { 200 }
    let(:bold_id) { 300 }
    let(:ncbi_version_id) { create(:ncbi_version, id: 1).id }

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

    it 'returns a hash of taxon info when all ranks are present' do
      string = 'Phylum;Class;Order;Family;Genus;Species'
      hierarchy_names = {
        superkingdom: 'Superkingdom',
        kingdom: 'Kingdom',
        phylum: 'Phylum',
        class: 'Class',
        order: 'Order',
        family: 'Family',
        genus: 'Genus',
        species: 'Species'
      }

      create(:ncbi_node, canonical_name: 'Species', rank: 'species',
                         hierarchy_names: hierarchy_names, taxon_id: id,
                         ncbi_id: ncbi_id, bold_id: bold_id,
                         ncbi_version_id: ncbi_version_id)
      results = subject(string)

      expect(results[:original_taxonomy_string]).to eq([string])
      expect(results[:clean_taxonomy_string]).to eq(string)
      expect(results[:taxon_id]).to eq(id)
      expect(results[:ncbi_id]).to eq(ncbi_id)
      expect(results[:bold_id]).to eq(bold_id)
      expect(results[:ncbi_version_id]).to eq(ncbi_version_id)
      expect(results[:taxon_rank]).to eq('species')
      expect(results[:hierarchy]).to include(
        phylum: 'Phylum', class: 'Class',
        order: 'Order', family: 'Family', genus: 'Genus', species: 'Species'
      )
      expect(results[:canonical_name]).to eq('Species')
    end

    it 'returns a hash of taxon info when there are missing ranks' do
      string = ';Class;Order;;Genus;'
      hierarchy_names = {
        superkingdom: 'Superkingdom',
        kingdom: 'Kingdom',
        phylum: 'Phylum',
        class: 'Class',
        order: 'Order',
        family: 'Family',
        genus: 'Genus'
      }
      create(:ncbi_node, canonical_name: 'Genus', rank: 'genus',
                         hierarchy_names: hierarchy_names, taxon_id: id,
                         ncbi_id: ncbi_id, bold_id: bold_id,
                         ncbi_version_id: ncbi_version_id)
      results = subject(string)

      expect(results[:original_taxonomy_string]).to eq([string])
      expect(results[:clean_taxonomy_string]).to eq(string)
      expect(results[:taxon_id]).to eq(id)
      expect(results[:ncbi_id]).to eq(ncbi_id)
      expect(results[:bold_id]).to eq(bold_id)
      expect(results[:ncbi_version_id]).to eq(ncbi_version_id)
      expect(results[:taxon_rank]).to eq('genus')
      expect(results[:hierarchy]).to include(
        class: 'Class', order: 'Order', genus: 'Genus'
      )
      expect(results[:canonical_name]).to eq('Genus')
    end

    it 'returns a hash of taxon info when there are NA ranks' do
      string = 'NA;Class;Order;NA;Genus;'
      hierarchy_names = {
        superkingdom: 'Superkingdom',
        kingdom: 'Kingdom',
        class: 'Class',
        order: 'Order',
        genus: 'Genus'
      }
      create(:ncbi_node, canonical_name: 'Genus', rank: 'genus',
                         hierarchy_names: hierarchy_names, taxon_id: id,
                         ncbi_id: ncbi_id, bold_id: bold_id,
                         ncbi_version_id: ncbi_version_id)
      results = subject(string)

      expect(results[:original_taxonomy_string]).to eq([string])
      expect(results[:clean_taxonomy_string]).to eq(';Class;Order;;Genus;')
      expect(results[:taxon_id]).to eq(id)
      expect(results[:ncbi_id]).to eq(ncbi_id)
      expect(results[:bold_id]).to eq(bold_id)
      expect(results[:ncbi_version_id]).to eq(ncbi_version_id)
      expect(results[:taxon_rank]).to eq('genus')
      expect(results[:hierarchy]).to include(
        class: 'Class', order: 'Order', genus: 'Genus'
      )
      expect(results[:canonical_name]).to eq('Genus')
    end

    it 'returns a hash with nil taxon_id if taxa not found' do
      string = 'Phylum;;;;;'
      hierarchy_names = {
        superkingdom: 'Superkingdom',
        kingdom: 'Kingdom',
        phylum: 'Phylum2'
      }

      create(:ncbi_node, canonical_name: 'Phylum2', rank: 'phylum',
                         hierarchy_names: hierarchy_names, taxon_id: id,
                         ncbi_id: ncbi_id, bold_id: bold_id,
                         ncbi_version_id: ncbi_version_id)
      results = subject(string)

      expect(results[:original_taxonomy_string]).to eq([string])
      expect(results[:clean_taxonomy_string]).to eq(string)
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

    it 'returns a hash of taxon info when there is only one rank' do
      string = 'Phylum;;;;;'
      hierarchy_names = {
        superkingdom: 'Superkingdom',
        kingdom: 'Kingdom',
        phylum: 'Phylum'
      }

      create(:ncbi_node, canonical_name: 'Phylum', rank: 'phylum',
                         hierarchy_names: hierarchy_names, taxon_id: id,
                         ncbi_id: ncbi_id, bold_id: bold_id,
                         ncbi_version_id: ncbi_version_id)
      results = subject(string)

      expect(results[:original_taxonomy_string]).to eq([string])
      expect(results[:clean_taxonomy_string]).to eq(string)
      expect(results[:taxon_id]).to eq(id)
      expect(results[:ncbi_id]).to eq(ncbi_id)
      expect(results[:bold_id]).to eq(bold_id)
      expect(results[:ncbi_version_id]).to eq(ncbi_version_id)
      expect(results[:taxon_rank]).to eq('phylum')
      expect(results[:hierarchy]).to include(
        phylum: 'Phylum'
      )
      expect(results[:canonical_name]).to eq('Phylum')
    end

    it 'returns a hash with nil taxon_id if multiple taxa are found' do
      string = ';Class;Order;;Genus;'
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

      expect(results[:original_taxonomy_string]).to eq([string])
      expect(results[:clean_taxonomy_string]).to eq(string)
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
    def subject(hierarchy, rank)
      dummy_class.find_existing_taxa(hierarchy, rank)
    end

    context 'when canonical name match, but rank does not, ' do
      it 'and only one taxon with matching canonical name, returns the taxon' do
        name = 'Name'
        given_hierarchy = { superkingdom: 'Sk', class: 'C', family: name }
        given_rank = 'family'

        hierarchy = { superkingdom: 'Sk', class: 'C', sublass: name }
        rank = 'sublass'
        taxon = create(:ncbi_node, hierarchy_names: hierarchy, rank: rank,
                                   canonical_name: name)

        expect(subject(given_hierarchy, given_rank)).to eq([taxon])
      end
    end

    context 'when given hierarchy and rank exactly match existing taxa' do
      shared_examples_for 'hierarchy and rank exactly match' do |hier, rank|
        it 'returns matching taxa' do
          taxa = create(:ncbi_node, hierarchy_names: hier, rank: rank,
                                    canonical_name: hier[rank.to_sym])

          expect(subject(hier, rank)).to eq([taxa])
        end
      end

      hierarchy = {
        superkingdom: 'Superkingdom'
      }
      rank = 'superkingdom'
      it_behaves_like 'hierarchy and rank exactly match', hierarchy, rank

      hierarchy = {
        superkingdom: 'Superkingdom', phylum: 'Phylum'
      }
      rank = 'phylum'
      it_behaves_like 'hierarchy and rank exactly match', hierarchy, rank

      hierarchy = {
        superkingdom: 'Superkingdom', phylum: 'Phylum', class: 'Class'
      }
      rank = 'class'
      it_behaves_like 'hierarchy and rank exactly match', hierarchy, rank

      hierarchy = {
        superkingdom: 'Superkingdom', phylum: 'Phylum', class: 'Class',
        order: 'Order'
      }
      rank = 'order'
      it_behaves_like 'hierarchy and rank exactly match', hierarchy, rank

      hierarchy = {
        superkingdom: 'Superkingdom', phylum: 'Phylum', class: 'Class',
        order: 'Order', family: 'Family'
      }
      rank = 'family'
      it_behaves_like 'hierarchy and rank exactly match', hierarchy, rank

      hierarchy = {
        superkingdom: 'Superkingdom', phylum: 'Phylum', class: 'Class',
        order: 'Order', family: 'Family', genus: 'Genus'
      }
      rank = 'genus'
      it_behaves_like 'hierarchy and rank exactly match', hierarchy, rank

      hierarchy = {
        superkingdom: 'Superkingdom', phylum: 'Phylum', class: 'Class',
        order: 'Order', family: 'Family', genus: 'Genus', species: 'Species'
      }
      rank = 'species'
      it_behaves_like 'hierarchy and rank exactly match', hierarchy, rank

      it 'returns matching taxa for canonical name with single quotes' do
        hierarchy = { phylum: 'P', genus: 'G', species: "sp 'name'" }
        rank = 'species'
        taxa = create(:ncbi_node, hierarchy_names: hierarchy, rank: rank,
                                  canonical_name: hierarchy[rank.to_sym])

        expect(subject(hierarchy, rank)).to eq([taxa])
      end

      it 'returns matching taxa for canonical name with double quotes' do
        hierarchy = { phylum: 'P', genus: 'G', species: 'sp "name"' }
        rank = 'species'
        taxa = create(:ncbi_node, hierarchy_names: hierarchy, rank: rank,
                                  canonical_name: hierarchy[rank.to_sym])

        expect(subject(hierarchy, rank)).to eq([taxa])
      end
    end

    context 'when highest taxa, rank, and canonical name match' do
      shared_examples_for 'ignores non-matching middle ranks' do |given_hi, hi|
        it 'returns matching taxa' do
          rank = 'genus'
          taxa = create(:ncbi_node, hierarchy_names: hi, rank: rank,
                                    canonical_name: hi[rank.to_sym])

          expect(subject(given_hi, rank)).to eq([taxa])
        end
      end

      given_hier = { phylum: 'P', genus: 'G' }
      hier = { phylum: 'P', genus: 'G' }
      it_behaves_like 'ignores non-matching middle ranks', given_hier, hier

      given_hier = { phylum: 'P', class: 'C1', genus: 'G' }
      hier = { phylum: 'P', class: 'C2', genus: 'G' }
      it_behaves_like 'ignores non-matching middle ranks', given_hier, hier

      given_hier = { phylum: 'P', class: 'C1', order: 'O1', genus: 'G' }
      hier = { phylum: 'P', class: 'C2', order: 'O2', genus: 'G' }
      it_behaves_like 'ignores non-matching middle ranks', given_hier, hier

      given_hier = { phylum: 'P', class: 'C1', order: 'O1', family: 'F1',
                     genus: 'G' }
      hier = { phylum: 'P', class: 'C2', order: 'O2', family: 'F2', genus: 'G' }
      it_behaves_like 'ignores non-matching middle ranks', given_hier, hier
    end

    context "when highest taxa & rank match, but canonical name don't match" do
      it "returns matching taxa if hierarchy name doesn't have quotes, " \
        'but taxa name does have quote' do
        given_hierarchy = { genus: 'G', species: 'Species name' }
        hierarchy = { genus: 'G', species: "Species 'name'" }
        rank = 'species'
        taxa = create(:ncbi_node, hierarchy_names: hierarchy, rank: rank,
                                  canonical_name: hierarchy[rank.to_sym])

        expect(subject(given_hierarchy, rank)).to eq([taxa])
      end

      it 'returns matching taxa if hierarchy names matches taxa synonym' do
        given_hierarchy = { genus: 'G', species: 'alt3' }
        hierarchy = { genus: 'G', species: 'Species' }
        rank = 'species'
        taxon = create(:ncbi_node, hierarchy_names: hierarchy, rank: rank,
                                   ncbi_id: 100,
                                   canonical_name: hierarchy[rank.to_sym])
        create(:ncbi_name, name_class: 'synonym', name: 'alt3', taxon_id: 100)

        expect(subject(given_hierarchy, rank)).to eq([taxon.reload])
      end

      it 'returns empty array otherwise' do
        given_hierarchy = { phylum: 'P', family: 'F1' }
        hierarchy = { phylum: 'P', family: 'F2' }
        rank = 'family'
        create(:ncbi_node, hierarchy_names: hierarchy, rank: rank,
                           canonical_name: hierarchy[rank.to_sym])

        expect(subject(given_hierarchy, rank)).to eq([])
      end
    end

    context 'when hierarchy partially matches, canonical name & rank match, ' do
      it 'returns matching taxa' do
        given_hierarchy = { class: 'C', family: 'F' }
        hierarchy1 = given_hierarchy.merge(phylum: 'P1')
        hierarchy2 = given_hierarchy.merge(phylum: 'P2')
        rank = 'family'
        taxa1 = create(:ncbi_node, hierarchy_names: hierarchy1, rank: rank,
                                   canonical_name: hierarchy1[rank.to_sym])
        taxa2 = create(:ncbi_node, hierarchy_names: hierarchy2, rank: rank,
                                   canonical_name: hierarchy2[rank.to_sym])

        expect(subject(given_hierarchy, rank)).to match_array([taxa1, taxa2])
      end
    end

    context 'when highest taxa do not match' do
      it 'and highest taxa is superkingdom, returns matching taxa' do
        name = 'Name'
        given_hierarchy = { superkingdom: 'Sk1', order: 'O', family: name }
        hierarchy = { superkingdom: 'Sk2', order: 'O', family: name }
        rank = 'family'
        taxon = create(:ncbi_node, hierarchy_names: hierarchy, rank: rank,
                                   canonical_name: hierarchy[rank.to_sym])

        expect(subject(given_hierarchy, rank)).to eq([taxon])
      end

      it 'and highest taxa is phylum, returns matching taxa' do
        name = 'Name'
        given_hierarchy = { phylum: 'P1', order: 'O', family: name }
        hierarchy = { phylum: 'P2', order: 'O', family: name }
        rank = 'family'
        taxon = create(:ncbi_node, hierarchy_names: hierarchy, rank: rank,
                                   canonical_name: hierarchy[rank.to_sym])

        expect(subject(given_hierarchy, rank)).to eq([taxon])
      end

      it 'and highest taxa is class, returns matching taxa' do
        name = 'Name'
        given_hierarchy = { class: 'C1', genus: 'G', family: name }
        hierarchy = { class: 'C2', genus: 'G', family: name }
        rank = 'family'
        taxon = create(:ncbi_node, hierarchy_names: hierarchy, rank: rank,
                                   canonical_name: hierarchy[rank.to_sym])

        expect(subject(given_hierarchy, rank)).to eq([taxon])
      end

      it 'and highest taxa is order, returns matching taxa' do
        name = 'Name'
        given_hierarchy = { order: 'O1', genus: 'G', species: name }
        hierarchy = { order: 'O2', genus: 'G', species: name }
        rank = 'species'
        taxa = create(:ncbi_node, hierarchy_names: hierarchy, rank: rank,
                                  canonical_name: hierarchy[rank.to_sym])

        expect(subject(given_hierarchy, rank)).to eq([taxa])
      end

      it 'and highest taxa is family, returns matching taxa' do
        name = 'Name'
        given_hierarchy = { family: 'F1', genus: 'G', species: name }
        hierarchy = { family: 'F2', genus: 'G', species: name }
        rank = 'species'
        taxa = create(:ncbi_node, hierarchy_names: hierarchy, rank: rank,
                                  canonical_name: hierarchy[rank.to_sym])

        expect(subject(given_hierarchy, rank)).to eq([taxa])
      end

      it 'and highest taxa is genus, returns matching taxon' do
        name = 'Name'
        given_hierarchy = { genus: 'G1', species: name }
        hierarchy = { genus: 'G2', species: name }
        rank = 'species'
        taxon = create(:ncbi_node, hierarchy_names: hierarchy, rank: rank,
                                   canonical_name: hierarchy[rank.to_sym])

        expect(subject(given_hierarchy, rank)).to eq([taxon])
      end

      it 'and highest taxa is species, returns matching empty array' do
        given_hierarchy = { species: 'S1' }
        hierarchy = { species: 'S2' }
        rank = 'species'
        create(:ncbi_node, hierarchy_names: hierarchy, rank: rank,
                           canonical_name: hierarchy[rank.to_sym])

        expect(subject(given_hierarchy, rank)).to eq([])
      end
    end
  end

  describe '#filtered_ranks' do
    context 'when include lowest is true' do
      def subject(hierarchy)
        dummy_class.filtered_ranks(hierarchy, include_lowest: true)
      end

      it 'returns an array with one rank if hierarchy only has one rank' do
        hierarchy = { superkingdom: 'Sk' }
        expect(subject(hierarchy)).to match_array(%i[superkingdom])

        hierarchy = { phylum: 'P' }
        expect(subject(hierarchy)).to match_array(%i[phylum])

        hierarchy = { family: 'F' }
        expect(subject(hierarchy)).to match_array(%i[family])
      end

      it 'returns an array of phylum and lowest rank if hierarchy does not ' \
        'have superkingdom, but has phylum' do
        hierarchy = { phylum: 'P', class: 'C' }
        expect(subject(hierarchy)).to match_array(%i[phylum class])

        hierarchy = { phylum: 'P', class: 'C', order: 'O' }
        expect(subject(hierarchy)).to match_array(%i[phylum order])

        hierarchy = { phylum: 'P', class: 'C', order: 'O', family: 'F' }
        expect(subject(hierarchy)).to match_array(%i[phylum family])

        hierarchy = { phylum: 'P', class: 'C', order: 'O', family: 'F',
                      genus: 'G' }
        expect(subject(hierarchy)).to match_array(%i[phylum genus])

        hierarchy = { phylum: 'P', class: 'C', order: 'O', family: 'F',
                      genus: 'G', species: 'Sp' }
        expect(subject(hierarchy)).to match_array(%i[phylum species])
      end

      it 'returns an array of class and lowest rank if hierarchy does not ' \
        'have superkingdon or phylum, but has class' do
        hierarchy = { class: 'C', order: 'O' }
        expect(subject(hierarchy)).to match_array(%i[class order])

        hierarchy = { class: 'C', order: 'O', family: 'F' }
        expect(subject(hierarchy)).to match_array(%i[class family])

        hierarchy = { class: 'C', order: 'O', family: 'F',
                      genus: 'G' }
        expect(subject(hierarchy)).to match_array(%i[class genus])

        hierarchy = { class: 'C', order: 'O', family: 'F',
                      genus: 'G', species: 'Sp' }
        expect(subject(hierarchy)).to match_array(%i[class species])
      end

      it 'returns an array of superkingdom and lowest rank if hierarchy ' \
        'has superkingdom but does not have phylum' do
        hierarchy = { superkingdom: 'Sk', class: 'C' }
        expect(subject(hierarchy)).to match_array(%i[superkingdom class])

        hierarchy = { superkingdom: 'Sk', class: 'C', order: 'O' }
        expect(subject(hierarchy)).to match_array(%i[superkingdom order])

        hierarchy = { superkingdom: 'Sk', class: 'C', order: 'O', family: 'F' }
        expect(subject(hierarchy)).to match_array(%i[superkingdom family])

        hierarchy = { superkingdom: 'Sk', class: 'C', order: 'O', family: 'F',
                      genus: 'G' }
        expect(subject(hierarchy)).to match_array(%i[superkingdom genus])

        hierarchy = { superkingdom: 'Sk', class: 'C', order: 'O', family: 'F',
                      genus: 'G', species: 'Sp' }
        expect(subject(hierarchy)).to match_array(%i[superkingdom species])
      end

      it 'returns an array of two lowest ranks if hierarchy ' \
        'does not have superkingdom, phylum, or class' do
        hierarchy = { order: 'O', family: 'F', genus: 'G',
                      species: 'Sp' }
        expect(subject(hierarchy)).to match_array(%i[genus species])

        hierarchy = { order: 'O', family: 'F', genus: 'Sp' }
        expect(subject(hierarchy)).to match_array(%i[family genus])
      end

      context 'when rank is genus' do
        it 'and highest rank is superkingdom, it returns phylum' do
          hierarchy = { superkingdom: 'Sk', phylum: 'P', class: 'C', order: 'O',
                        family: 'F', genus: 'G' }
          expect(subject(hierarchy))
            .to match_array(%i[superkingdom phylum genus])
        end

        it 'and highest rank is phylum, it returns phylum' do
          hierarchy = { phylum: 'P', class: 'C', order: 'O', family: 'F',
                        genus: 'G' }
          expect(subject(hierarchy)).to match_array(%i[phylum genus])
        end

        it 'does not contain phylum otherwise' do
          hierarchy = { class: 'C', order: 'O', family: 'F', genus: 'G' }
          expect(subject(hierarchy)).to match_array(%i[class genus])

          hierarchy = { order: 'O', family: 'F', genus: 'G' }
          expect(subject(hierarchy)).to match_array(%i[family genus])

          hierarchy = { family: 'F', genus: 'G' }
          expect(subject(hierarchy)).to match_array(%i[family genus])
        end
      end
    end

    context 'when include lowest is false' do
      def subject(hierarchy)
        dummy_class.filtered_ranks(hierarchy, include_lowest: false)
      end

      it 'returns an array with one rank if hierarchy only has one rank' do
        hierarchy = { superkingdom: 'Sk' }
        expect(subject(hierarchy)).to match_array(%i[superkingdom])

        hierarchy = { phylum: 'P' }
        expect(subject(hierarchy)).to match_array(%i[phylum])

        hierarchy = { family: 'F' }
        expect(subject(hierarchy)).to match_array(%i[family])
      end

      it 'returns the phylum if hierarchy does not ' \
        'have superkingdom, but has phylum' do
        hierarchies = [
          { phylum: 'P', class: 'C' },
          { phylum: 'P', class: 'C', order: 'O' },
          { phylum: 'P', class: 'C', order: 'O', family: 'F' },
          { phylum: 'P', class: 'C', order: 'O', family: 'F',
            genus: 'G' },
          { phylum: 'P', class: 'C', order: 'O', family: 'F',
            genus: 'G', species: 'Sp' }
        ]

        hierarchies.each do |hierarchy|
          expect(subject(hierarchy)).to match_array(%i[phylum])
        end
      end

      it 'returns the class if hierarchy does not ' \
        'have superkingdon or phylum, but has class' do
        hierarchies = [
          { class: 'C', order: 'O' },
          { class: 'C', order: 'O', family: 'F' },
          { class: 'C', order: 'O', family: 'F',
            genus: 'G' },
          { class: 'C', order: 'O', family: 'F',
            genus: 'G', species: 'Sp' }
        ]

        hierarchies.each do |hierarchy|
          expect(subject(hierarchy)).to match_array(%i[class])
        end
      end

      it 'returns the superkingdom if hierarchy ' \
        'has superkingdom but does not have phylum' do
        hierarchies = [
          { superkingdom: 'Sk', class: 'C' },
          { superkingdom: 'Sk', class: 'C', order: 'O' },
          { superkingdom: 'Sk', class: 'C', order: 'O', family: 'F' },
          { superkingdom: 'Sk', class: 'C', order: 'O', family: 'F',
            genus: 'G' },
          { superkingdom: 'Sk', class: 'C', order: 'O', family: 'F',
            genus: 'G', species: 'Sp' }
        ]

        hierarchies.each do |hierarchy|
          expect(subject(hierarchy)).to match_array(%i[superkingdom])
        end
      end

      it 'returns an array of two lowest ranks if hierarchy ' \
        'does not have superkingdom, phylum, or class' do
        hierarchy = { order: 'O', family: 'F', genus: 'G',
                      species: 'Sp' }
        expect(subject(hierarchy)).to match_array(%i[genus])

        hierarchy = { order: 'O', family: 'F', genus: 'Sp' }
        expect(subject(hierarchy)).to match_array(%i[family])
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
        taxa = create(:result_taxon, clean_taxonomy_string: clean_string,
                                     normalized: true, taxon_rank: rank)

        expect(subject(taxonomy_string)).to eq(taxa)
      end

      it 'handles blank ranks and returns matching ResultTaxon' do
        taxonomy_string = 'Phylum;;Order;Family;;Species'
        clean_string = clean_string(taxonomy_string)
        rank = 'species'
        taxa = create(:result_taxon, clean_taxonomy_string: clean_string,
                                     normalized: true, taxon_rank: rank)

        expect(subject(taxonomy_string)).to eq(taxa)
      end

      it 'handles NA and returns matching ResultTaxon' do
        taxonomy_string = 'NA;NA;Order;Family;NA;Species'
        clean_string = clean_string(taxonomy_string)
        rank = 'species'
        taxa = create(:result_taxon, clean_taxonomy_string: clean_string,
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

        taxa = create(:result_taxon, clean_taxonomy_string: clean_string,
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
  end

  describe '#filtered_ranks_by_number' do
    def subject(hierarchy, rank_count)
      dummy_class.filtered_ranks_by_number(hierarchy, rank_count)
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
    end
  end

  describe '#find_low_to_high' do
    def subject(name, hierarchy, taxa, count)
      dummy_class.find_low_to_high(name, hierarchy, taxa, count)
    end

    let(:name1) { 'name1' }
    let(:name2) { 'name2' }
    let(:initial_taxa) { [] }
    let(:count) { 0 }

    it 'returns empty array when lowest names differ' do
      given_hier = { superkingdom: 'sk', family: name1 }

      hierarchy1 = { superkingdom: 'sk', class: name1, family: name2 }
      create(:ncbi_node, canonical_name: name2, hierarchy_names: hierarchy1)

      expect(subject(name1, given_hier, initial_taxa, count))
        .to match_array([])
    end

    context 'when there is one taxa that matches the lowest name' do
      it 'returns matching taxon' do
        given_hier = { superkingdom: 'sk', family: name1 }

        hierarchy1 = given_hier
        taxon = create(:ncbi_node, canonical_name: name1,
                                   hierarchy_names: hierarchy1)

        hierarchy2 = { superkingdom: 'sk', family: name2 }
        create(:ncbi_node, canonical_name: name2,
                           hierarchy_names: hierarchy2)

        expect(subject(name1, given_hier, initial_taxa, count))
          .to match_array([taxon])
      end

      it 'returns matching taxon regardless of rank' do
        given_hier = { superkingdom: 'sk', family: name1 }

        hierarchy1 = { superkingdom: 'sk', genus: name1 }
        taxon = create(:ncbi_node, canonical_name: name1,
                                   hierarchy_names: hierarchy1)

        hierarchy2 = { superkingdom: 'sk', family: name2 }
        create(:ncbi_node, canonical_name: name2,
                           hierarchy_names: hierarchy2)

        expect(subject(name1, given_hier, initial_taxa, count))
          .to match_array([taxon])
      end
    end

    context 'when there are multiple taxa that have same lowest name' do
      it 'and name has different ranks, returns taxa that match rank & name' do
        given_hier = { class: 'c', family: name1 }

        hierarchy1 = given_hier
        taxon1 = create(:ncbi_node, canonical_name: name1,
                                    hierarchy_names: hierarchy1)
        taxon2 = create(:ncbi_node, canonical_name: name1,
                                    hierarchy_names: hierarchy1)

        hierarchy2 = { class: 'c', genus: name1 }
        create(:ncbi_node, canonical_name: name1, hierarchy_names: hierarchy2)

        expect(subject(name1, given_hier, initial_taxa, count))
          .to match_array([taxon1, taxon2])
      end

      it 'and given hierarchy is an exact match, returns matching taxa' do
        given_hier = { phylum: 'p', class: 'c', order: 'o', family: name1 }

        hierarchy1 = given_hier
        taxon1 = create(:ncbi_node, canonical_name: name1,
                                    hierarchy_names: hierarchy1)
        taxon2 = create(:ncbi_node, canonical_name: name1,
                                    hierarchy_names: hierarchy1)

        hierarchy2 = { phylum: '-', class: 'c', order: 'o', family: name1 }
        create(:ncbi_node, canonical_name: name1, hierarchy_names: hierarchy2)

        hierarchy3 = { order: '-', family: name1 }
        create(:ncbi_node, canonical_name: name1, hierarchy_names: hierarchy3)

        expect(subject(name1, given_hier, initial_taxa, count))
          .to match_array([taxon1, taxon2])
      end

      it 'and given hierarchy matches the lower ranks, returns matching taxa' do
        given_hier = { class: 'c', order: 'o', family: name1 }

        hierarchy1 = given_hier.merge(phylum: 'p')
        taxon1 = create(:ncbi_node, canonical_name: name1,
                                    hierarchy_names: hierarchy1)

        hierarchy2 = given_hier.merge('kingdom' => 'k')
        taxon2 = create(:ncbi_node, canonical_name: name1,
                                    hierarchy_names: hierarchy2)

        hierarchy3 = { class: 'c', order: '-', family: name1 }
        create(:ncbi_node, canonical_name: name1, hierarchy_names: hierarchy3)

        expect(subject(name1, given_hier, initial_taxa, count))
          .to match_array([taxon1, taxon2])
      end

      it 'is not affected by no ranks' do
        given_hier = { class: 'c', order: 'o', family: name1 }

        hierarchy1 = given_hier.merge('no rank': 'nr')
        taxon1 = create(:ncbi_node, canonical_name: name1,
                                    hierarchy_names: hierarchy1)

        expect(subject(name1, given_hier, initial_taxa, count))
          .to match_array([taxon1])
      end
    end

    context 'when hierarchy has one item' do
      it 'and there are matches, returns all matching taxon' do
        hierarchy = { class: name1 }

        taxon1 = create(:ncbi_node, canonical_name: name1,
                                    hierarchy_names: hierarchy)
        taxon2 = create(:ncbi_node, canonical_name: name1,
                                    hierarchy_names: hierarchy)

        expect(subject(name1, hierarchy, initial_taxa, count))
          .to match_array([taxon1, taxon2])
      end

      it 'and there are no matches, returns empty array' do
        hierarchy = { class: name1 }

        create(:ncbi_node, canonical_name: name2)

        expect(subject(name1, hierarchy, initial_taxa, count)).to eq([])
      end
    end
  end
end
