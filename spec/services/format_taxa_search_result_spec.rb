# frozen_string_literal: true

require 'rails_helper'

describe FormatTaxaSearchResult do
  describe '#common_names' do
    def subject(search_result)
      FormatTaxaSearchResult.new(search_result).common_names
    end

    it 'returns array of common names if multiple names exists' do
      record = OpenStruct.new(
        common_names: '{name1,name2}'
      )

      expect(subject(record)).to eq('(name1, name2)')
    end

    it 'returns array of common names if one name exists' do
      record = OpenStruct.new(
        common_names: '{name1}'
      )

      expect(subject(record)).to eq('(name1)')
    end

    it 'returns empty array if NULL' do
      record = OpenStruct.new(
        common_names: '{NULL}'
      )

      expect(subject(record)).to eq(nil)
    end

    it 'handles a mixture of valid names and NULL' do
      record = OpenStruct.new(
        common_names: '{name1,NULL,name2,NULL}'
      )

      expect(subject(record)).to eq('(name1, name2)')
    end

    it 'raises an error if common name not set' do
      record = OpenStruct.new

      expect { subject(record) }
        .to raise_error(StandardError, 'must add common_names in sql query')
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
        inat_image_attributions: '{inat_attribution1}',
        eol_images: '{eol_image1}',
        eol_image_attributions: '{\"eol attribution1\"}',
        inat_ids: '{1}',
        eol_ids: '{1}'
      )

      expect(subject(search_result).url).to eq('wikidata_image1')
      expect(subject(search_result).attribution).to eq('commons.wikimedia.org')
    end

    it '2 returns inat_image if it exists' do
      search_result = OpenStruct.new(
        wikidata_images: '{NULL}',
        inat_images: '{inat_image1}',
        inat_image_attributions: '{inat_attribution1}',
        eol_images: '{eol_image1}',
        eol_image_attributions: '{\"eol attribution1\"}',
        inat_ids: '{1}',
        eol_ids: '{1}'
      )

      expect(subject(search_result).url).to eq('inat_image1')
      expect(subject(search_result).attribution).to eq('inat_attribution1')
    end

    it '3 returns eol_image if it exists' do
      search_result = OpenStruct.new(
        wikidata_images: '{NULL}',
        inat_images: '{NULL}',
        inat_image_attributions: '{NULL}',
        eol_images: '{eol_image1}',
        eol_image_attributions: '{\"eol attribution1\"}',
        inat_ids: '{1}',
        eol_ids: '{1}'
      )

      expect(subject(search_result).url).to eq('eol_image1')
      expect(subject(search_result).attribution).to eq('eol attribution1')
    end

    it '4 returns image if iNaturalist API image exists' do
      VCR.use_cassette 'FormatTaxaSearchResult#image inat api' do
        search_result = OpenStruct.new(
          wikidata_images: '{NULL}',
          inat_images: '{NULL}',
          inat_image_attributions: '{NULL}',
          eol_images: '{NULL}',
          eol_image_attributions: '{NULL}',
          inat_ids: '{1}',
          eol_ids: '{1}'
        )

        url = 'https://static.inaturalist.org/photos/169/medium.jpg?1545345841'
        expect(subject(search_result).url).to eq(url)
        attr = '(c) David Midgley, some rights reserved (CC BY-NC-ND)'
        expect(subject(search_result).attribution).to eq(attr)
      end
    end

    it '4 returns nil if iNaturalist API image does not exist' do
      VCR.use_cassette 'FormatTaxaSearchResult#image inat api no image' do
        search_result = OpenStruct.new(
          wikidata_images: '{NULL}',
          inat_images: '{NULL}',
          inat_image_attributions: '{NULL}',
          eol_images: '{NULL}',
          eol_image_attributions: '{NULL}',
          inat_ids: '{697557}',
          eol_ids: '{NULL}'
        )

        expect(subject(search_result)).to eq(nil)
      end
    end

    it '5 returns image from EoL API if it exists' do
      VCR.use_cassette 'FormatTaxaSearchResult#image eol api' do
        search_result = OpenStruct.new(
          wikidata_images: '{NULL}',
          inat_images: '{NULL}',
          inat_image_attributions: '{NULL}',
          eol_images: '{NULL}',
          eol_image_attributions: '{NULL}',
          inat_ids: '{NULL}',
          eol_ids: '{1}'
        )

        url = 'https://content.eol.org/data/media/94/ad/14/' \
          '140.10899325a9e616256669b54425fad550.jpg'
        expect(subject(search_result).url).to eq(url)
        attr = 'Femorale'
        expect(subject(search_result).attribution).to eq(attr)
      end
    end

    it '5 returns nil if EoL API image does not exist' do
      VCR.use_cassette 'FormatTaxaSearchResult#image eol api no image' do
        search_result = OpenStruct.new(
          wikidata_images: '{NULL}',
          inat_images: '{NULL}',
          inat_image_attributions: '{NULL}',
          eol_images: '{NULL}',
          eol_image_attributions: '{NULL}',
          inat_ids: '{NULL}',
          eol_ids: '{1151354}'
        )

        expect(subject(search_result)).to eq(nil)
      end
    end

    it '6 returns nil if all image data is nil' do
      search_result = OpenStruct.new(
        wikidata_images: '{NULL}',
        inat_images: '{NULL}',
        inat_image_attributions: '{NULL}',
        eol_images: '{NULL}',
        eol_image_attributions: '{NULL}',
        inat_ids: '{NULL}',
        eol_ids: '{NULL}'
      )

      expect(subject(search_result)).to eq(nil)
    end
  end
end
