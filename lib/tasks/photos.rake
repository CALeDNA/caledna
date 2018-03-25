# frozen_string_literal: true

namespace :photos do
  desc 'add dimensions'
  task add_dimensions: :environment do
    require 'fastimage'

    Photo.where(height: nil).each do |photo|
      dimensions = FastImage.size(photo.source_url)
      photo.update(width: dimensions.first, height: dimensions.second)
    end
  end
end
