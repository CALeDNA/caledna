# frozen_string_literal: true

module ProcessFileUploads
  def create_image_name(photo_path)
    photo_path.split('/').last
  end

  def upload_image(resource, photo_path)
    image_name = create_image_name(photo_path)

    resource.attach(io: File.open(photo_path), filename: image_name)
  end

  private

  def extract_mime_type(photo_path)
    file_extension = extract_file_extenstion(photo_path)

    if %w[jpg jpeg].include?(file_extension)
      'image/jpeg'
    elsif file_extension == 'png'
      'image/png'
    end
  end

  def extract_file_extenstion(photo_path)
    photo_path.split('.').last.downcase
  end
end
