# frozen_string_literal: true

namespace :kobo_photos do
  require 'csv'

  desc 'add dimensions'
  task add_dimensions: :environment do
    require 'fastimage'

    KoboPhoto.where(height: nil).each do |photo|
      dimensions = FastImage.size(photo.source_url)
      photo.update(width: dimensions.first, height: dimensions.second)
    end
  end

  task remove_table_key_from_kobo_payload: :environment do
    KoboPhoto.all.each do |photo|
      next unless photo.kobo_payload['table'].present?
      puts photo.id
      photo.update(kobo_payload: photo.kobo_payload['table'])
    end
  end

  task upload_to_s3: :environment do
    include ProcessFileUploads

    path = "#{Rails.root}/db/data/private/kobo_photos.csv"

    CSV.foreach(path, headers: true) do |row|
      samples = Sample.where(kobo_id: row['submission_id'])
      kobo_photos = KoboPhoto.where(sample: samples)

      kobo_photos.each do |kobo_photo|
        puts row['path']
        photo_path = "#{Rails.root}/db/data/private/#{row['path']}"
        upload_image(kobo_photo.photo, photo_path)
      end
    end
  end
end
