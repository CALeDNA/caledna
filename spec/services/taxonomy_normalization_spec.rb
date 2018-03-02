# frozen_string_literal: true

require 'rails_helper'

describe TaxonomyNormalization do
  TaxonomyNormalization::PHYLUM_TO_KINGDOM = { Phylum: 'Kingdom' }.freeze
  let(:dummy_class) { Class.new { extend TaxonomyNormalization } }

  describe '#kingdom' do
    def subject(phylum)
      dummy_class.kingdom(phylum)
    end

    it 'returns a kingdom for valid phlyum' do
      expect(subject('Phylum')).to eq('Kingdom')
    end

    it 'accepts symbols' do
      expect(subject(:Phylum)).to eq('Kingdom')
    end

    it 'raises error for invalid phylum' do
      expect { subject('random') }
        .to raise_error(TaxaError, 'invalid kingdom')
    end
  end

  # describe '#phylum' do
  #   def subject(phylum)
  #     dummy_class.phylum(phylum)
  #   end

  #   it 'returns valid phylum' do
  #     expect(subject('Aquificae')).to eq('Aquificae')
  #   end

  #   it 'converts CALeDNA phylum' do
  #     expect(subject('Streptophyta')).to eq('Bryophyta')
  #   end

  #   it 'raises error for invalid phylum' do
  #     expect { subject('random') }
  #       .to raise_error(TaxaError, 'invalid phlyum')
  #   end
  # end

  describe '#getTaxonRank' do
    def subject(string)
      dummy_class.getTaxonRank(string)
    end

    it 'returns species if it exists' do
      string = 'Phylum;Class;Order;Family;Genus;Species'
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

    it 'ignores "uncultured"' do
      string = 'Phylum;Class;Order;Family;Genus;uncultured thing'
      expect(subject(string)).to eq('genus')
    end

    it 'ignores "NA"' do
      string = 'Phylum;Class;Order;Family;NA;NA'
      expect(subject(string)).to eq('family')
    end

    it 'retuns nil when entire string is "NA"' do
      string = 'NA'
      expect(subject(string)).to eq(nil)
    end

    it 'retuns nil when entire string is ";;;;;"' do
      string = ';;;;;'
      expect(subject(string)).to eq(nil)
    end

    it 'otherwise throw error' do
      string = 'NA;NA;NA;NA;NA;uncultured eukaryote'
      expect { subject(string) }
        .to raise_error(TaxaError, "invalid taxa rank: #{string}")
    end
  end

  describe '#getHierarchy' do
    def subject(string)
      dummy_class.getHierarchy(string)
    end

    it 'returns a hash of taxonomy names' do
      string = 'Phylum;Class;Order;Family;Genus;Species'

      expect(subject(string)[:kingdom]).to eq('Kingdom')
      expect(subject(string)[:phylum]).to eq('Phylum')
      expect(subject(string)[:class]).to eq('Class')
      expect(subject(string)[:order]).to eq('Order')
      expect(subject(string)[:family]).to eq('Family')
      expect(subject(string)[:genus]).to eq('Genus')
      expect(subject(string)[:species]).to eq('Species')
    end

    it 'returns nil for missing taxa' do
      string = 'Phylum;Class;;Family;Genus;'

      expect(subject(string)[:kingdom]).to eq('Kingdom')
      expect(subject(string)[:phylum]).to eq('Phylum')
      expect(subject(string)[:class]).to eq('Class')
      expect(subject(string)[:order]).to eq(nil)
      expect(subject(string)[:family]).to eq('Family')
      expect(subject(string)[:genus]).to eq('Genus')
      expect(subject(string)[:species]).to eq(nil)
    end

    it 'returns nil for "NA" taxa' do
      string = 'Phylum;Class;NA;Family;Genus;NA'

      expect(subject(string)[:kingdom]).to eq('Kingdom')
      expect(subject(string)[:phylum]).to eq('Phylum')
      expect(subject(string)[:class]).to eq('Class')
      expect(subject(string)[:order]).to eq(nil)
      expect(subject(string)[:family]).to eq('Family')
      expect(subject(string)[:genus]).to eq('Genus')
      expect(subject(string)[:species]).to eq(nil)
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
end
