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

  task find_photos_not_in_db: :environment do
    # array all all filenames downloaded from kobo api
    path = "#{Rails.root}/db/data/private/kobo_photos.csv"
    api_photos = CSV.foreach(path, headers: true)
    api_filenames = api_photos.map { |i| i['source_filename'] }

    # list of all filenames from the db
    path = "#{Rails.root}/db/data/private/existing_kobo_photos.csv"
    db_photos = CSV.foreach(path, headers: true)
    db_filenames = db_photos.map { |i| i['filename'] }

    # find filenames  from api that are not in the db
    missing_filenames = api_filenames - db_filenames

    # find all photos from api that are not in the db
    missing_photos = api_photos.select do |photo|
      missing_filenames.include? photo['source_filename']
    end

    # get list of kobi ids and check if any samples have does ideas
    missing_ids = missing_photos.map { |i| i['submission_id'].to_i }
    # we get nil results; which means there are photos from the api that
    # aren't associated with samples
    samples = Sample.where(kobi_id: missing_ids)
    samples.count
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
        attach_local_file_to(photo_path, kobo_photo.photo)
      end
    end
  end
end
