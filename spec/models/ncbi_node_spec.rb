# frozen_string_literal: true

require 'rails_helper'

describe NcbiNode do
  describe '#threatened?' do
    it 'returns true if taxon IUCN status belongs to THREATENED' do
      status = IucnStatus::THREATENED.values.first
      taxon = create(:ncbi_node, iucn_status: status)

      expect(taxon.threatened?).to eq(true)
    end

    it 'returns false if taxon does not belong to THREATENED' do
      status = 'random'
      taxon = create(:ncbi_node, iucn_status: status)

      expect(taxon.threatened?).to eq(false)
    end
  end

  describe '#image' do
    it '1 returns wikidata_image if it exists' do
      taxon = create(:ncbi_node, ncbi_id: 100)
      create(:external_resource, ncbi_id: taxon.ncbi_id,
                                 wikidata_image: 'wikidata_image',
                                 eol_image: 'eol_image',
                                 eol_image_attribution: 'eol_attribution',
                                 inat_image: 'inat_image',
                                 inat_image_attribution: 'inat_attribution',
                                 inaturalist_id: 1,
                                 eol_id: 1)

      expect(taxon.image.url).to eq('wikidata_image')
      expect(taxon.image.attribution).to eq('commons.wikimedia.org')
    end

    it '2 returns inat_image if it exists' do
      taxon = create(:ncbi_node, ncbi_id: 100)
      create(:external_resource, ncbi_id: taxon.ncbi_id,
                                 wikidata_image: nil,
                                 eol_image: 'eol_image',
                                 eol_image_attribution: 'eol_attribution',
                                 inat_image: 'inat_image',
                                 inat_image_attribution: 'inat_attribution',
                                 inaturalist_id: 1,
                                 eol_id: 1)

      expect(taxon.image.url).to eq('inat_image')
      expect(taxon.image.attribution).to eq('inat_attribution')
    end

    it '3 returns eol_image if it exists' do
      taxon = create(:ncbi_node, ncbi_id: 100)
      create(:external_resource, ncbi_id: taxon.ncbi_id,
                                 wikidata_image: nil,
                                 eol_image: 'eol_image',
                                 eol_image_attribution: 'eol_attribution',
                                 inat_image: nil,
                                 inat_image_attribution: nil,
                                 inaturalist_id: 1,
                                 eol_id: 1)

      expect(taxon.image.url).to eq('eol_image')
      expect(taxon.image.attribution).to eq('eol_attribution')
    end

    it '4 returns image if iNaturalist API image exists' do
      VCR.use_cassette 'NcbiNode inat api image' do
        taxon = create(:ncbi_node, ncbi_id: 100)
        create(:external_resource, ncbi_id: taxon.ncbi_id,
                                   wikidata_image: nil,
                                   eol_image: nil,
                                   eol_image_attribution: nil,
                                   inat_image: nil,
                                   inat_image_attribution: nil,
                                   inaturalist_id: 1,
                                   eol_id: 1)

        url = 'https://static.inaturalist.org/photos/169/medium.jpg?1545345841'
        expect(taxon.image.url).to eq(url)
        attrib = '(c) David Midgley, algunos derechos reservados (CC BY-NC-ND)'
        expect(taxon.image.attribution).to eq(attrib)
      end
    end

    it '4 returns nil if iNaturalist API image does not exist' do
      VCR.use_cassette 'NcbiNode inat api no image' do
        taxon = create(:ncbi_node, ncbi_id: 100)
        create(:external_resource, ncbi_id: taxon.ncbi_id,
                                   wikidata_image: nil,
                                   eol_image: nil,
                                   eol_image_attribution: nil,
                                   inat_image: nil,
                                   inat_image_attribution: nil,
                                   inaturalist_id: 697_557,
                                   eol_id: nil)

        expect(taxon.image).to eq(nil)
      end
    end

    it '5 returns image from EoL API if it exists' do
      VCR.use_cassette 'NcbiNode eol api image' do
        taxon = create(:ncbi_node, ncbi_id: 100)
        create(:external_resource, ncbi_id: taxon.ncbi_id,
                                   wikidata_image: nil,
                                   eol_image: nil,
                                   eol_image_attribution: nil,
                                   inat_image: nil,
                                   inat_image_attribution: nil,
                                   inaturalist_id: nil,
                                   eol_id: 1)

        url = 'https://content.eol.org/data/media/94/ad/14/' \
          '140.10899325a9e616256669b54425fad550.jpg'
        expect(taxon.image.url).to eq(url)
        attrib = 'Femorale'
        expect(taxon.image.attribution).to eq(attrib)
      end
    end

    it '5 returns nil if EoL API image does not exist' do
      VCR.use_cassette 'NcbiNode eol api no image' do
        taxon = create(:ncbi_node, ncbi_id: 100)
        create(:external_resource, ncbi_id: taxon.ncbi_id,
                                   wikidata_image: nil,
                                   eol_image: nil,
                                   eol_image_attribution: nil,
                                   inat_image: nil,
                                   inat_image_attribution: nil,
                                   inaturalist_id: nil,
                                   eol_id: 1_151_354)

        expect(taxon.image).to eq(nil)
      end
    end

    it '6 returns nil if all image data is nil' do
      taxon = create(:ncbi_node, ncbi_id: 100)
      create(:external_resource, ncbi_id: taxon.ncbi_id,
                                 wikidata_image: nil,
                                 eol_image: nil,
                                 eol_image_attribution: nil,
                                 inat_image: nil,
                                 inat_image_attribution: nil,
                                 inaturalist_id: nil,
                                 eol_id: nil)

      expect(taxon.image).to eq(nil)
    end
  end
end
