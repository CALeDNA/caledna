# frozen_string_literal: true

module ConnectAws
  require 'aws-sdk-s3'

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
end
