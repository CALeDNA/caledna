# frozen_string_literal: true

namespace :kobo_photos do
  desc 'add dimensions'
  task add_dimensions: :environment do
    require 'fastimage'

    KoboPhoto.where(height: nil).each do |photo|
      dimensions = FastImage.size(photo.source_url)
      photo.update(width: dimensions.first, height: dimensions.second)
    end
  end

  task upload_to_s3: :environment do
    require 'csv'
    include ProcessFileUploads

    path = "#{Rails.root}/db/data/private/kobo_photos.csv"

    CSV.foreach(path, headers: true) do |row|
      sample = Sample.find_by(kobo_id: row['submission_id'])
      kobo_photos = KoboPhoto.where(sample: sample)

      kobo_photos.each do |kobo_photo|
        puts row['path']
        photo_path = "#{Rails.root}/db/data/private/#{row['path']}"
        upload_image(kobo_photo.photo, photo_path)
      end
    end
  end
end
