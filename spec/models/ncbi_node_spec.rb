# frozen_string_literal: true

require 'rails_helper'

describe NcbiNode do
  describe '#conservation_status' do
    it 'returns IUCN status if status exists' do
      status = IucnStatus::CATEGORIES.values.first
      taxon = create(:ncbi_node)
      create(:external_resource, ncbi_id: taxon.id, iucn_status: status)

      expect(taxon.conservation_status).to eq(status)
    end

    it 'returns IUCN status when there is valid status & multiple nil status' do
      status = IucnStatus::CATEGORIES.values.first
      taxon = create(:ncbi_node)
      create(:external_resource, ncbi_id: taxon.id, iucn_status: nil)
      create(:external_resource, ncbi_id: taxon.id, iucn_status: status)
      create(:external_resource, ncbi_id: taxon.id, iucn_status: nil)

      expect(taxon.conservation_status).to eq(status)
    end

    it 'returns last IUCN status when there are multiple valid status' do
      taxon = create(:ncbi_node)
      create(:external_resource, ncbi_id: taxon.id, iucn_status: 'a')
      create(:external_resource, ncbi_id: taxon.id, iucn_status: 'c')
      create(:external_resource, ncbi_id: taxon.id, iucn_status: 'b')

      expect(taxon.conservation_status).to eq('b')
    end

    it 'returns null if IUCN status does not exists' do
      taxon = create(:ncbi_node)
      create(:external_resource, ncbi_id: taxon.id, iucn_status: nil)

      expect(taxon.conservation_status).to eq(nil)
    end
  end

  describe '#conservation_status?' do
    it 'returns true if taxon has IUCN status' do
      status = IucnStatus::CATEGORIES.values.first
      taxon = create(:ncbi_node)
      create(:external_resource, ncbi_id: taxon.id, iucn_status: status)

      expect(taxon.conservation_status?).to eq(true)
    end

    it 'returns false if taxon does not have IUCN status' do
      taxon = create(:ncbi_node)
      create(:external_resource, ncbi_id: taxon.id, iucn_status: nil)

      expect(taxon.conservation_status?).to eq(false)
    end
  end

  describe '#threatened?' do
    it 'returns true if taxon IUCN status belongs to THREATENED' do
      status = IucnStatus::THREATENED.values.first
      taxon = create(:ncbi_node)
      create(:external_resource, ncbi_id: taxon.id, iucn_status: status)

      expect(taxon.threatened?).to eq(true)
    end

    it 'returns false if taxon does not belong to THREATENED' do
      status = 'random'
      taxon = create(:ncbi_node)
      create(:external_resource, ncbi_id: taxon.id, iucn_status: status)

      expect(taxon.threatened?).to eq(false)
    end
  end

  describe '#image' do
    it '1 returns wikidata_image if it exists' do
      taxon = create(:ncbi_node)
      create(:external_resource, ncbi_id: taxon.id,
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
      taxon = create(:ncbi_node)
      create(:external_resource, ncbi_id: taxon.id,
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
      taxon = create(:ncbi_node)
      create(:external_resource, ncbi_id: taxon.id,
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
        taxon = create(:ncbi_node)
        create(:external_resource, ncbi_id: taxon.id,
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
        taxon = create(:ncbi_node)
        create(:external_resource, ncbi_id: taxon.id,
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
        taxon = create(:ncbi_node)
        create(:external_resource, ncbi_id: taxon.id,
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
        taxon = create(:ncbi_node)
        create(:external_resource, ncbi_id: taxon.id,
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
      taxon = create(:ncbi_node)
      create(:external_resource, ncbi_id: taxon.id,
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

  describe '#common_names_display' do
    def append_taxon(common_name)
      taxon = create(:ncbi_node)
      taxon.instance_eval { class << self; self end }
           .send(:attr_accessor, :common_names)
      taxon.common_names = common_name
      taxon
    end

    it 'raises an error if common_names is not set' do
      taxon = create(:ncbi_node)

      expect { taxon.common_names_display }
        .to raise_error(StandardError, 'must add common_names in sql query')
    end

    context 'default behavior' do
      it 'returns common names in parenthesis for 1 to 3 names' do
        results = [
          { input: ['name1'], expected: '(name1)' },
          { input: %w[name1 name2], expected: '(name1, name2)' },
          { input: %w[name1 name2 name3], expected: '(name1, name2, name3)' }
        ]

        results.each do |result|
          taxon = append_taxon(result[:input])
          expected = result[:expected]

          expect(taxon.common_names_display).to eq(expected)
        end
      end

      it 'returns truncated common names in parenthesis when over 3 names' do
        taxon = append_taxon(%w[name1 name2 name3 name4])
        expected = '(name1, name2, name3...)'

        expect(taxon.common_names_display).to eq(expected)
      end
    end

    context 'when parenthesis is false' do
      it 'returns common names for 1 to 3 names' do
        results = [
          { input: ['name1'], expected: 'name1' },
          { input: %w[name1 name2], expected: 'name1, name2' },
          { input: %w[name1 name2 name3], expected: 'name1, name2, name3' }
        ]

        results.each do |result|
          taxon = append_taxon(result[:input])
          expected = result[:expected]

          expect(taxon.common_names_display(parenthesis: false)).to eq(expected)
        end
      end

      it 'returns truncated common names when over 3 names' do
        taxon = append_taxon(%w[name1 name2 name3 name4])
        expected = 'name1, name2, name3...'

        expect(taxon.common_names_display(parenthesis: false)).to eq(expected)
      end
    end

    context 'when truncate is false' do
      it 'returns common names in parenthesis' do
        results = [
          { input: ['name1'], expected: '(name1)' },
          { input: %w[name1 name2], expected: '(name1, name2)' },
          { input: %w[name1 name2 name3], expected: '(name1, name2, name3)' },
          { input: %w[name1 name2 name3 name4],
            expected: '(name1, name2, name3, name4)' }
        ]

        results.each do |result|
          taxon = append_taxon(result[:input])
          expected = result[:expected]

          expect(taxon.common_names_display(truncate: false)).to eq(expected)
        end
      end
    end

    context 'when truncate and parenthesis are false' do
      it 'returns common names' do
        results = [
          { input: ['name1'], expected: 'name1' },
          { input: %w[name1 name2], expected: 'name1, name2' },
          { input: %w[name1 name2 name3], expected: 'name1, name2, name3' },
          { input: %w[name1 name2 name3 name4],
            expected: 'name1, name2, name3, name4' }
        ]

        results.each do |result|
          taxon = append_taxon(result[:input])
          expected = result[:expected]

          options = { truncate: false, parenthesis: false }
          expect(taxon.common_names_display(options)).to eq(expected)
        end
      end
    end
  end
end
