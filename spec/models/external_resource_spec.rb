# frozen_string_literal: true

require 'rails_helper'

describe ExternalResource, type: :model do
  describe 'missing_links' do
    it 'returns records that have null attributes' do
      link = create(:external_resource, eol_id: nil, wikidata_image: 'a',
                                        bold_id: 1, calflora_id: 1, cites_id: 1,
                                        cnps_id: 1, gbif_id: 1,
                                        inaturalist_id: 1,
                                        itis_id: 1, iucn_id: 1, msw_id: 1,
                                        wikidata_entity: 'a', worms_id: 1)

      expect(ExternalResource.missing_links).to eq([link])
    end

    it 'does not return records that have all the attribures' do
      create(:external_resource, eol_id: 1, wikidata_image: 'a',
                                 bold_id: 1, calflora_id: 1, cites_id: 1,
                                 cnps_id: 1, gbif_id: 1, inaturalist_id: 1,
                                 itis_id: 1, iucn_id: 1, msw_id: 1,
                                 wikidata_entity: 'a', worms_id: 1)

      expect(ExternalResource.missing_links).to eq([])
    end
  end
end
