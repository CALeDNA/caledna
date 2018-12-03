# frozen_string_literal: true

require 'rails_helper'

describe ImportCombineTaxa do
  let(:dummy_class) { Class.new { extend ImportCombineTaxa } }

  describe '#parse_taxon' do
    def subject(string)
      dummy_class.parse_taxon(string)
    end

    it 'returns hash with certain fields' do
      string = 'Rank Taxon'
      results = {
        name: 'Taxon',
        rank: 'rank',
        notes: nil,
        synonym: nil
      }

      expect(subject(string)).to eq(results)
    end

    it 'converts all uppercase name to  title case' do
      string = 'Rank TAXON'
      results = {
        name: 'Taxon',
        rank: 'rank',
        notes: nil,
        synonym: nil
      }

      expect(subject(string)).to eq(results)
    end

    it 'removes quotes from names' do
      string = 'Rank "Taxon"'
      results = {
        name: 'Taxon',
        rank: 'rank',
        notes: 'Rank "Taxon"',
        synonym: nil
      }

      expect(subject(string)).to eq(results)
    end

    it 'returns notes if it exists' do
      string = 'Rank Taxon (notes content)'
      results = {
        name: 'Taxon',
        rank: 'rank',
        notes: 'Rank Taxon (notes content)',
        synonym: nil
      }

      expect(subject(string)).to eq(results)
    end

    it 'returns synonym if it exists' do
      string = 'Rank Taxon [="Alternate name"]'
      results = {
        name: 'Taxon',
        rank: 'rank',
        notes: 'Rank Taxon [="Alternate name"]',
        synonym: 'Alternate name'
      }

      expect(subject(string)).to eq(results)
    end

    it 'converts all uppercase synonyms to  title case' do
      string = 'Rank TAXON [=FOO]'
      results = {
        name: 'Taxon',
        rank: 'rank',
        notes: 'Rank TAXON [=FOO]',
        synonym: 'Foo'
      }

      expect(subject(string)).to eq(results)
    end

    it 'returns nil if taxon name is only N.N.' do
      string = 'Rank N.N.'
      results = nil

      expect(subject(string)).to eq(results)
    end

    it 'returns note if taxon name has N.N. and note' do
      string = 'Rank N.N. (e.g., Taxon Name)'
      results = {
        name: nil,
        rank: nil,
        notes: 'Rank N.N. (e.g., Taxon Name)',
        synonym: nil
      }

      expect(subject(string)).to eq(results)
    end
  end

  describe '#create_combine_taxa_taxonomy_string' do
    def subject(hash)
      dummy_class.create_combine_taxa_taxonomy_string(hash)
    end

    it 'returns a taxonomy string with major taxon ranks' do
      data = {
        'superkingdom' => 'superkingdom',
        'kingdom' => 'kingdom',
        'subkingdom' => 'subkingdom',
        'infrakingdom' => 'infrakingdom',
        'superphylum' => 'superphylum',
        'phylum' => 'phylum',
        'subphylum' => 'subphylum',
        'infraphylum' => 'infraphylum',
        'superclass' => 'superclass',
        'class' => 'class',
        'subclass' => 'subclass',
        'infraclass' => 'infraclass',
        'superorder' => 'superorder',
        'order' => 'order',
        'suborder' => 'suborder',
        'infraorder' => 'infraorder',
        'superfamily' => 'superfamily',
        'family' => 'family',
        'subfamily' => 'subfamily',
        'infrafamily' => 'infrafamily',
        'supergenus' => 'supergenus',
        'genus' => 'genus',
        'subgenus' => 'subgenus',
        'infragenus' => 'infragenus',
        'species' => 'species'
      }
      result = 'superkingdom;kingdom;phylum;class;order;family;genus;species'

      expect(subject(data)).to eq(result)
    end

    it 'correctly parses hash with symbols' do
      data = {
        superkingdom: 'superkingdom',
        kingdom: 'kingdom',
        subkingdom: 'subkingdom',
        infrakingdom: 'infrakingdom',
        superphylum: 'superphylum',
        phylum: 'phylum',
        subphylum: 'subphylum',
        infraphylum: 'infraphylum',
        superclass: 'superclass',
        class: 'class',
        subclass: 'subclass',
        infraclass: 'infraclass',
        superorder: 'superorder',
        order: 'order',
        suborder: 'suborder',
        infraorder: 'infraorder',
        superfamily: 'superfamily',
        family: 'family',
        subfamily: 'subfamily',
        infrafamily: 'infrafamily',
        supergenus: 'supergenus',
        genus: 'genus',
        subgenus: 'subgenus',
        infragenus: 'infragenus',
        species: 'species'
      }
      result = 'superkingdom;kingdom;phylum;class;order;family;genus;species'

      expect(subject(data)).to eq(result)
    end
  end
end
