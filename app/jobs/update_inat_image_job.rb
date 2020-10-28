# frozen_string_literal: true

class UpdateInatImageJob < ApplicationJob
  queue_as :default

  def perform(inaturalist_id)
    inat_api = InatApi.new
    update_sql = <<~SQL
      UPDATE external_resources
      set inat_image = $1, inat_image_attribution = $2,
      inat_image_id = $3, updated_at = now()
      where active = true
      and inat_image is null
      and source = 'wikidata'
      and inaturalist_id = $4
    SQL

    photo_data = inat_api.default_photo(inaturalist_id)
    return if photo_data.blank?

    binding = [[nil, photo_data[:url]], [nil, photo_data[:attribution]],
               [nil, photo_data[:photo_id]], [nil, inaturalist_id]]
    ActiveRecord::Base.connection.exec_query(update_sql, 'q', binding)
  end
end
