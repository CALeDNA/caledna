# frozen_string_literal: true

require 'rails_helper'

describe FormatTaxaSearchResult do
  describe '#common_names' do
    def subject(names)
      FormatTaxaSearchResult.new(nil).common_names(names)
    end

    it 'returns multiple common names if multiple names exists' do
      names = 'name1|name2'

      expect(subject(names)).to eq('(name1, name2)')
    end

    it 'returns one common name if one name exists' do
      names = 'name1'

      expect(subject(names)).to eq('(name1)')
    end
  end

  describe '#image' do
    def subject(search_result)
      FormatTaxaSearchResult.new(search_result).image
    end

    it '1 returns wikidata_image if it exists' do
      search_result = OpenStruct.new(
        wikidata_images: '{wikidata_image1}',
        inat_images: '{inat_image1}',
        eol_images: '{eol_image1}',
        inat_ids: '{1}',
        eol_ids: '{1}'
      )

      expect(subject(search_result).url).to eq('wikidata_image1')
      expect(subject(search_result).source).to eq('wikimedia')
    end

    it '2 returns inat_image if it exists' do
      search_result = OpenStruct.new(
        wikidata_images: '{NULL}',
        inat_images: '{inat_image1}',
        eol_images: '{eol_image1}',
        inat_ids: '{1}',
        eol_ids: '{1}'
      )

      expect(subject(search_result).url).to eq('inat_image1')
      expect(subject(search_result).source).to eq('iNaturalist')
    end

    it '3 returns eol_image if it exists' do
      search_result = OpenStruct.new(
        wikidata_images: '{NULL}',
        inat_images: '{NULL}',
        eol_images: '{eol_image1}',
        inat_ids: '{1}',
        eol_ids: '{1}'
      )

      expect(subject(search_result).url).to eq('eol_image1')
      expect(subject(search_result).source).to eq('Encyclopedia of Life')
    end

    it '6 returns nil if all image data is nil' do
      search_result = OpenStruct.new(
        wikidata_images: '{NULL}',
        inat_images: '{NULL}',
        eol_images: '{NULL}',
        inat_ids: '{NULL}',
        eol_ids: '{NULL}'
      )

      expect(subject(search_result)).to eq(nil)
    end
  end
end
