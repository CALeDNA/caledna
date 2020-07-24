# frozen_string_literal: true

module ProcessFileUploads
  require 'open-uri'

  def attach_local_file_to(file_path, resource)
    image_name = create_file_name(file_path)

    resource.attach(io: File.open(file_path), filename: image_name)
  end

  def fetch_kobo_file_and_attach_to(url, resource)
    image_name = create_file_name(url)

    file = open_and_read(url)
    resource.attach(io: file, filename: image_name)
  end

  private

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
