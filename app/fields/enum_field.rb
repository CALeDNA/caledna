# frozen_string_literal: true

require 'administrate/field/base'

class EnumField < Administrate::Field::Base
  def to_s
    data.to_s
  end

  def select_field_values(form_builder)
    field_name = attribute.to_s.sub('_cd', '')
    options = form_builder.object.class.public_send(field_name.pluralize)
    options.keys.map do |v|
      [v.titleize, v]
    end
  end
end
