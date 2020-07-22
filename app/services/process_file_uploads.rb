# frozen_string_literal: true

module ProcessFileUploads
  require 'open-uri'
  require 'aws-sdk-s3'

  def attach_local_file_to(file_path, resource)
    image_name = create_file_name(file_path)

    resource.attach(io: File.open(file_path), filename: image_name)
  end

  def fetch_kobo_file_and_attach_to(url, resource)
    image_name = create_file_name(url)

    file = open_and_read(url)
    resource.attach(io: file, filename: image_name)
  end

  def s3_object(key)
    s3_resource.bucket(ENV.fetch('S3_BUCKET')).object(key)
  end

  private

  def s3_client
    Aws::S3::Client.new(
      region: ENV.fetch('S3_REGION'),
      access_key_id: ENV.fetch('S3_ACCESS_KEY_ID'),
      secret_access_key: ENV.fetch('S3_SECRET_ACCESS_KEY')
    )
  end

  def s3_resource
    Aws::S3::Resource.new(
      region: ENV.fetch('S3_REGION'),
      access_key_id: ENV.fetch('S3_ACCESS_KEY_ID'),
      secret_access_key: ENV.fetch('S3_SECRET_ACCESS_KEY')
    )
  end

  # https://github.com/rubocop-hq/rubocop/pull/6210/files
  # https://stackoverflow.com/a/264239
  # NOTE: application code allows URI.open;
  # rspec fails because URI.open is a private method
  def open_and_read(url)
    token = "Token #{ENV.fetch('KOBO_TOKEN')}"
    uri = URI.parse(url)
    uri.open('Authorization' => token)
  end

  def create_file_name(path)
    path.split('/').last
  end
end
