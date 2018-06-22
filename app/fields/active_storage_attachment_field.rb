# frozen_string_literal: true

require 'administrate/field/base'

class ActiveStorageAttachmentField < Administrate::Field::Base
  def to_s
    data.attachment.present? ? data : ''
  end

  def filename
    data.attachment.present? ? data.blob.filename.to_s : ''
  end
end
